import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestService.dart' as VendorLab;
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductCartService.dart';
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicService.dart';

typedef PushNamed = void Function(String route, {Object? arguments});

class IntentActionOutcome {
  final bool closeOverlay;
  final String? route;
  final Object? arguments;
  final bool showEmergencyDialog;
  final String? doctorNumber;
  final String? ambulanceNumber;
  final String? bloodBankNumber;
  const IntentActionOutcome({
    this.closeOverlay = true,
    this.route,
    this.arguments,
    this.showEmergencyDialog = false,
    this.doctorNumber,
    this.ambulanceNumber,
    this.bloodBankNumber,
  });
}

bool shouldAutoNavigateForIntent(String upperIntent) {
  switch (upperIntent) {
    case 'BOOK_HOSPITAL_BED':
    case 'BOOK_BED':
    case 'BOOK_LAB_TEST':
      return false; // present list first
    default:
      return true;
  }
}

Future<IntentActionOutcome> handleIntentAction(
  BuildContext context,
  dynamic resultItem,
  Map action,
  PushNamed pushNamed,
) async {
  try {
    final dynamic a = action['action'] ?? action;
    final String type = (a['type'] ?? '').toString().toUpperCase();
    final String resultType = (resultItem is Map && resultItem['type'] != null)
        ? resultItem['type'].toString().toUpperCase()
        : '';
    print('intent type: $type');
    switch (type) {
      case 'NAVIGATE_SEARCH_AMBULANCE':
      case 'CALL_EMERGENCY':
        if (resultType == 'EMERGENCY') {
          final String phone = (a is Map && a['phone'] != null) ? a['phone'].toString() : '108';
          return IntentActionOutcome(
            closeOverlay: true,
            showEmergencyDialog: true,
            doctorNumber: phone,
            ambulanceNumber: phone,
            bloodBankNumber: phone,
          );
        }
        return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.ambulanceSearch);

      case 'BOOK_BLOOD':
      case 'BOOK_BLOOD_BANK':
      case 'NAVIGATE_SEARCH_BLOOD':
        return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.bloodBank);

      case 'BOOK_BED':
      case 'BOOK_HOSPITAL_BED': {
        try {
          String? vendorId;
          if (resultItem is Map) {
            if (resultItem['vendorId'] != null) {
              vendorId = resultItem['vendorId'].toString();
            } else if (resultItem['hospitalDetails'] is Map && (resultItem['hospitalDetails'] as Map)['vendorId'] != null) {
              vendorId = (resultItem['hospitalDetails'] as Map)['vendorId'].toString();
            }
          }
          // Some responses provide hospitalId in action; treat as vendorId
          if (vendorId == null && a is Map && a['hospitalId'] != null) {
            vendorId = a['hospitalId'].toString();
          }

          if (vendorId != null && vendorId.isNotEmpty) {
            final hospitalService = HospitalVendorService();
            final profile = await hospitalService.getHospitalProfile(vendorId);
            return IntentActionOutcome(closeOverlay: true, route: AppRoutes.bookAppointment, arguments: profile);
          }
          return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.hospital);
        } catch (_) {
          return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.hospital);
        }
      }

      case 'BOOK_DOCTOR':
      case 'BOOK_APPOINTMENT': {
        try {
          String? vendorId;
          if (resultItem is Map && resultItem['vendorId'] != null) {
            vendorId = resultItem['vendorId'].toString();
          }
          DoctorClinicProfile? doctorArg;
          if (vendorId != null && vendorId.isNotEmpty) {
            final doctorService = DoctorClinicService();
            final fetched = await doctorService.getClinicProfile(vendorId);
            if (fetched is DoctorClinicProfile) {
              doctorArg = fetched;
            }
          }
          if (doctorArg == null && resultItem is Map) {
            // Fallback: map minimal fields from result item
            final String subtitle = (resultItem['subtitle'] ?? '').toString();
            String city = '';
            String state = '';
            List<String> languages = <String>[];
            if (subtitle.isNotEmpty) {
              final partsDot = subtitle.split('•');
              final locPart = partsDot.isNotEmpty ? partsDot.first.trim() : '';
              final langPart = partsDot.length > 1 ? partsDot[1].trim() : '';
              if (locPart.isNotEmpty) {
                final locPieces = locPart.split(',');
                if (locPieces.isNotEmpty) city = locPieces[0].trim();
                if (locPieces.length > 1) state = locPieces[1].trim();
              }
              if (langPart.isNotEmpty) {
                languages = langPart
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
              }
            }
            final List<String> specList = (resultItem['specializations'] is List)
                ? List<String>.from((resultItem['specializations'] as List).map((e) => e.toString()))
                : <String>[];
            final List<String> badges = (resultItem['badges'] is List)
                ? List<String>.from((resultItem['badges'] as List).map((e) => e.toString()))
                : <String>[];
            final bool hasTele = badges
                .map((e) => e.toLowerCase())
                .any((b) => b.contains('online') || b.contains('tele'));
            final List<String> consultationTypes = badges.map((b) {
              final low = b.toLowerCase();
              if (low.contains('tele')) return 'Online';
              if (low.contains('online')) return 'Online';
              if (low.contains('in-person') || low.contains('offline')) return 'Offline';
              return b;
            }).toList();
            final int expYears = int.tryParse(((resultItem['experience'] ?? '').toString()).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            final Map<String, dynamic> dj = {
              'vendorId': vendorId ?? resultItem['vendorId']?.toString(),
              'doctorName': (resultItem['title'] ?? '').toString(),
              'profilePicture': (resultItem['profile_picture'] ?? '').toString(),
              'specializations': specList,
              'experienceYears': expYears,
              'languageProficiency': languages,
              'hasTelemedicineExperience': hasTele,
              'consultationTypes': consultationTypes.isNotEmpty ? consultationTypes : <String>['Offline'],
              'state': state,
              'city': city,
            };
            try {
              doctorArg = DoctorClinicProfile.fromJson(dj);
            } catch (_) {}
          }
          if (doctorArg != null) {
            // Require explicit mode selection. If missing, do not navigate yet.
            final String mode = ((a is Map ? a['mode'] : null) ?? '').toString().toUpperCase();
            if (mode.isEmpty) {
              return const IntentActionOutcome(closeOverlay: false);
            }
            final String route = mode == 'ONLINE' ? AppRoutes.onlineDoctorDetail : AppRoutes.bookClinicAppointment;
            return IntentActionOutcome(closeOverlay: true, route: route, arguments: doctorArg);
          }
          return const IntentActionOutcome(closeOverlay: false);
        } catch (_) {
          return const IntentActionOutcome(closeOverlay: false);
        }
      }

      case 'BOOK_LAB_TEST': {
        DiagnosticCenter? center;
        try {
          if (resultItem is Map && (resultItem['labDetails'] is Map || resultItem['diagnosticCenter'] is Map || resultItem['center'] is Map)) {
            final src = (resultItem['labDetails'] ?? resultItem['diagnosticCenter'] ?? resultItem['center']) as Map;
            center = DiagnosticCenter.fromJson(Map<String, dynamic>.from(src));
          }
        } catch (_) {}
        if (center == null) {
          // Prefer id from result item if present
          String? labId = (resultItem is Map && resultItem['id'] != null) ? resultItem['id'].toString() : null;
          labId ??= (a is Map && (a['labId'] != null)) ? a['labId'].toString() : null;
          if (labId != null && labId.isNotEmpty) {
            try {
              final vendorService = VendorLab.LabTestService();
              center = await vendorService.getLabProfile(labId);
            } catch (_) {}
          }
        }
        if (center != null) {
          return IntentActionOutcome(closeOverlay: true, route: AppRoutes.bookLabTestAppointment, arguments: center);
        }
        return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.labTest);
      }

      case 'ORDER_MEDICINE':
      case 'ORDER_MEDICINE_PRESCRIPTION':
        return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.medicineOrder);

      case 'ADD_TO_CART': {
        String? productId = a['productId']?.toString();
        if (productId == null && resultItem is Map) {
          if (resultItem['productId'] != null) productId = resultItem['productId'].toString();
          if (productId == null && resultItem['product'] is Map && (resultItem['product'] as Map)['productId'] != null) {
            productId = (resultItem['product'] as Map)['productId'].toString();
          }
        }
        if (productId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No product specified to add to cart')));
          return const IntentActionOutcome(closeOverlay: false);
        }
        try {
          final userId = await StorageService.getUserId();
          if (userId == null) throw Exception('User not logged in');
          final service = ProductCartService(Dio());
          final item = ProductCart(
            cartId: '',
            userId: userId,
            productId: productId,
            quantity: 1,
            addedAt: DateTime.now(),
          );
          await service.addToCart(cartItem: item);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
        }
        return const IntentActionOutcome(closeOverlay: false);
      }

      case 'TRACK':
        return const IntentActionOutcome(closeOverlay: true, route: AppRoutes.trackOrderScreen);

      default:
        return const IntentActionOutcome(closeOverlay: false);
    }
  } catch (_) {
    return const IntentActionOutcome(closeOverlay: false);
  }
}


