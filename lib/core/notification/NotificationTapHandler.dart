import 'package:flutter/cupertino.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';

class NotificationTapHandler {
  static bool _isHandlingNavigation = false;
  static String? _lastNotificationId;
  static DateTime? _lastNavigationTime;

  static Future<void> handleNotification(Map<String, dynamic> data, {bool isAppLaunch = false}) async {
    if (_isHandlingNavigation) {
      debugPrint("⚠️ Navigation already in progress, waiting briefly...");
      int attempts = 0;
      while (_isHandlingNavigation && attempts < 4) {
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }
      if (_isHandlingNavigation) {
        debugPrint("⚠️ Previous navigation still in progress, proceeding with new notification");
      }
    } else {
      _isHandlingNavigation = true;
    }

    String currentNotificationId = '${data['type']?.toString() ?? 'UNKNOWN'}_${data['orderId'] ?? data['id'] ?? 'unknown'}';

    bool isRepeatedNotification = _lastNotificationId == currentNotificationId &&
        _lastNavigationTime != null &&
        DateTime.now().difference(_lastNavigationTime!).inSeconds < 5;

    if (isRepeatedNotification) {
      debugPrint("🔄 Repeated notification detected - optimizing for faster response");
    }

    String type = data['type']?.toString() ?? 'UNKNOWN';
    print("Notification Type: $type");

    _lastNotificationId = currentNotificationId;
    _lastNavigationTime = DateTime.now();

    BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      print("Context not available");
      _isHandlingNavigation = false;
      return;
    }

    try {
      switch (type) {
        case 'TRACK_ORDER':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.trackOrderScreen,
              arguments: {'orderId': data['orderId']},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.trackOrderScreen,
              arguments: {'orderId': data['orderId']},
            );
          }
          break;

        case 'EMERGENCY_SERVICE':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(context, AppRoutes.ambulanceSearch);
          } else {
            await _navigateWithHistory(context, AppRoutes.ambulanceSearch);
          }
          break;

        case 'NEW_ORDER':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.medicineOrder,
              arguments: {'orderId': data['orderId']},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.medicineOrder,
              arguments: {'orderId': data['orderId']},
            );
          }
          break;

        case 'AmbulancePage':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(context, AppRoutes.ambulanceSearch);
          } else {
            await _navigateWithHistory(context, AppRoutes.ambulanceSearch);
          }
          break;

        case 'NOTIFICATIONS':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(context, AppRoutes.notification);
          } else {
            await _navigateWithHistory(context, AppRoutes.notification);
          }
          break;

        case 'CART_SCREEN':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(context, AppRoutes.newCartScreen);
          } else {
            await _navigateWithHistory(context, AppRoutes.newCartScreen);
          }
          break;

        case 'ORDER_HISTORY':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(context, AppRoutes.orderHistory);
          } else {
            await _navigateWithHistory(context, AppRoutes.orderHistory);
          }
          break;

        case 'BLOOD_BANK_REQUEST':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.VendorBloodBankDashBoard,
              arguments: {'initialTab': 2},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorBloodBankDashBoard,
              arguments: {'initialTab': 2},
            );
          }
          break;

        case 'BLOOD_BANK_BOOKING':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBank,
              arguments: {'initialTab': 2},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBank,
              arguments: {'initialTab': 2},
            );
          }
          break;

        case 'BLOOD_BANK_ORDER_HISTORY':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.orderHistory,
              arguments: {'initialTab': 4},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.orderHistory,
              arguments: {'initialTab': 4},
            );
          }
          break;

        case 'BLOOD_BANK_BOOKING_PAYMENT_RQUIRED':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBank,
              arguments: {'initialTab': 2},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBank,
              arguments: {'initialTab': 2},
            );
          }
          break;

        case 'BLOOD_PAYMENT_COMPLETED':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBankBooking,
              arguments: {'initialTab': 3},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBankBooking,
              arguments: {'initialTab': 3},
            );
          }
          break;

        case 'MEDICINE_ORDERS':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorMedicalStoreDashBoard,
              arguments: {'initialIndex': 1},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorMedicalStoreDashBoard,
              arguments: {'initialIndex': 1},
            );
          }
          break;

        case 'ProductPartnerOrders':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorProductPartnerDashBoard,
              arguments: {'initialTab': 2},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorProductPartnerDashBoard,
              arguments: {'initialTab': 2},
            );
          }
          break;

        case 'VIEW_BED_BOOKING':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorHospitalDashBoard,
              arguments: {'initialIndex': 1},
            );
          } else {
            if (ModalRoute.of(context)?.settings.name != AppRoutes.VendorHospitalDashBoard) {
              await _navigateWithClearStack(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 1},
              );
            } else {
              await _navigateWithClearStack(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 1},
              );
            }
          }
          break;

        case 'BED_BOOKING_ACCEPTED':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          }
          break;

        case 'BED_BOOKING_PAYMENT_REQUEST':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          }
          break;

        case 'BED_PAYMENT_COMPLETED':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.VendorHospitalDashBoard,
              arguments: {'initialIndex': 2},
            );
            await _navigateWithHistory(
              context,
              AppRoutes.VendorHospitalDashBoard,
              arguments: {'initialIndex': 0},
            );
          } else {
            if (ModalRoute.of(context)?.settings.name != AppRoutes.VendorHospitalDashBoard) {
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 2},
              );
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 0},
              );
            } else {
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 2},
              );
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 0},
              );
            }
          }
          break;

        case 'NEW_BOOKING':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.AmbulanceAgencyDashboard,
              arguments: {'initialTab': 1},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.AmbulanceAgencyDashboard,
              arguments: {'initialTab': 1},
            );
          }
          break;

        case 'LAB_TEST_BOOKING':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.VendorPathologyDashBoard,
              arguments: {'initialTab': 1},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorPathologyDashBoard,
              arguments: {'initialTab': 1},
            );
          }
          break;

        case 'CLINIC_APPOINTMENT':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorClinicDashBoard,
              arguments: {'initialIndex': 1},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorClinicDashBoard,
              arguments: {'initialIndex': 1},
            );
          }
          break;

        case 'CLINIC_APPOINTMENT_ORDER_HISTORY':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            await _navigateWithHistory(
              context,
              AppRoutes.orderHistory,
              arguments: {'initialTab': 5},
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.orderHistory,
              arguments: {'initialTab': 5},
            );
          }
          break;

        default:
          print("Unknown notification type: $type");
      }
    } catch (e) {
      print("Navigation error: $e");
    } finally {
      if (_isHandlingNavigation) {
        _isHandlingNavigation = false;
      }
    }
  }

  static Future<void> _navigateWithHistory(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<void> _navigateWithClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}


