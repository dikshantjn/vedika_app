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
  const IntentActionOutcome({this.closeOverlay = true});
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

    switch (type) {
      case 'BOOK_AMBULANCE':
      case 'CALL_EMERGENCY':
        Future.delayed(const Duration(milliseconds: 120), () {
          pushNamed(AppRoutes.ambulanceSearch);
        });
        return const IntentActionOutcome(closeOverlay: true);

      case 'BOOK_BLOOD':
        Future.delayed(const Duration(milliseconds: 120), () {
          pushNamed(AppRoutes.bloodBank);
        });
        return const IntentActionOutcome(closeOverlay: true);

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
            Future.delayed(const Duration(milliseconds: 120), () {
              pushNamed(AppRoutes.bookAppointment, arguments: profile);
            });
          } else {
            Future.delayed(const Duration(milliseconds: 120), () {
              pushNamed(AppRoutes.hospital);
            });
          }
        } catch (_) {
          Future.delayed(const Duration(milliseconds: 120), () {
            pushNamed(AppRoutes.hospital);
          });
        }
        return const IntentActionOutcome(closeOverlay: true);
      }

      case 'BOOK_DOCTOR': {
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
            Future.delayed(const Duration(milliseconds: 120), () {
              pushNamed(AppRoutes.bookClinicAppointment, arguments: doctorArg);
            });
            return const IntentActionOutcome(closeOverlay: true);
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
          final String? labId = (a is Map && (a['labId'] != null)) ? a['labId'].toString() : null;
          if (labId != null && labId.isNotEmpty) {
            try {
              final vendorService = VendorLab.LabTestService();
              center = await vendorService.getLabProfile(labId);
            } catch (_) {}
          }
        }
        if (center != null) {
          Future.delayed(const Duration(milliseconds: 120), () {
            pushNamed(AppRoutes.bookLabTestAppointment, arguments: center);
          });
        } else {
          Future.delayed(const Duration(milliseconds: 120), () {
            pushNamed(AppRoutes.labTest);
          });
        }
        return const IntentActionOutcome(closeOverlay: true);
      }

      case 'ORDER_MEDICINE':
        Future.delayed(const Duration(milliseconds: 120), () {
          pushNamed(AppRoutes.medicineOrder);
        });
        return const IntentActionOutcome(closeOverlay: true);

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
        Future.delayed(const Duration(milliseconds: 120), () {
          pushNamed(AppRoutes.trackOrderScreen);
        });
        return const IntentActionOutcome(closeOverlay: true);

      default:
        return const IntentActionOutcome(closeOverlay: false);
    }
  } catch (_) {
    return const IntentActionOutcome(closeOverlay: false);
  }
}


