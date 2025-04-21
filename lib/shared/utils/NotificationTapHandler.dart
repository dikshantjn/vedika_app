import 'package:flutter/cupertino.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/main.dart';

class NotificationTapHandler {
  static bool _isHandlingNavigation = false;

  static Future<void> handleNotification(Map<String, dynamic> data, {bool isAppLaunch = false}) async {
    if (_isHandlingNavigation) return;
    _isHandlingNavigation = true;

    String type = data['type']?.toString() ?? 'UNKNOWN';
    print("Notification Type: $type");

    BuildContext? context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
            await _navigateWithHistory(context, AppRoutes.goToCart);
          } else {
            await _navigateWithHistory(context, AppRoutes.goToCart);
          }
          break;

        case 'ORDER_HISTORY':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
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
            await Future.delayed(const Duration(milliseconds: 100));
            await _navigateWithHistory(
              context,
              AppRoutes.orderHistory,
              arguments: {'initialTab': 4}, // 4 is the index for Blood Bank tab
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.orderHistory,
              arguments: {'initialTab': 4}, // 4 is the index for Blood Bank tab
            );
          }
          break;

        case 'BLOOD_PAYMENT_COMPLETED':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 100));
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBankBooking,
              arguments: {'initialTab': 3}, // 1 is the index for Completed tab
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBankBooking,
              arguments: {'initialTab': 3}, // 1 is the index for Completed tab
            );
          }
          break;

        case 'VIEW_BED_BOOKING':
          if (isAppLaunch) {
            // First navigate to HospitalDashboardScreen to ensure drawer and bottom nav are available
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorHospitalDashBoard,
              arguments: {'initialIndex': 1}, // 1 is the index for Appointments tab
            );
          } else {
            // Check if we're already on HospitalDashboardScreen
            if (ModalRoute.of(context)?.settings.name != AppRoutes.VendorHospitalDashBoard) {
              // If not, navigate to HospitalDashboardScreen first with appointments tab selected
              await _navigateWithClearStack(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 1}, // 1 is the index for Appointments tab
              );
            } else {
              // If already on dashboard, navigate to the same screen with updated index
              await _navigateWithClearStack(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 1}, // 1 is the index for Appointments tab
              );
            }
          }
          break;

        case 'BED_BOOKING_ACCEPTED':
          if (isAppLaunch) {
            // First navigate to home screen
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 100));
            // Then navigate to HospitalSearchPage
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          } else {
            // If app is already running, navigate to HospitalSearchPage
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          }
          break;

        case 'BED_BOOKING_PAYMENT_REQUEST':
          if (isAppLaunch) {
            // First navigate to home screen
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 100));
            // Then navigate to HospitalSearchPage
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          } else {
            // If app is already running, navigate to HospitalSearchPage
            await _navigateWithHistory(
              context,
              AppRoutes.hospital,
            );
          }
          break;

        case 'BED_PAYMENT_COMPLETED':
          if (isAppLaunch) {
            // First navigate to home screen
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 100));
            // Then navigate to HospitalDashboardScreen with History tab selected
            await _navigateWithHistory(
              context,
              AppRoutes.VendorHospitalDashBoard,
              arguments: {'initialIndex': 2}, // 2 is the index for History tab
            );
            // Add a route that will be shown when back is pressed
            await _navigateWithHistory(
              context,
              AppRoutes.VendorHospitalDashBoard,
              arguments: {'initialIndex': 0}, // 0 is the index for Dashboard tab
            );
          } else {
            // Check if we're already on HospitalDashboardScreen
            if (ModalRoute.of(context)?.settings.name != AppRoutes.VendorHospitalDashBoard) {
              // If not, navigate to HospitalDashboardScreen with History tab selected
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 2}, // 2 is the index for History tab
              );
              // Add a route that will be shown when back is pressed
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 0}, // 0 is the index for Dashboard tab
              );
            } else {
              // If already on dashboard, navigate to the same screen with updated index
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 2}, // 2 is the index for History tab
              );
              // Add a route that will be shown when back is pressed
              await _navigateWithHistory(
                context,
                AppRoutes.VendorHospitalDashBoard,
                arguments: {'initialIndex': 0}, // 0 is the index for Dashboard tab
              );
            }
          }
          break;

        default:
          print("Unknown notification type: $type");
      }
    } catch (e) {
      print("Navigation error: $e");
    } finally {
      _isHandlingNavigation = false;
    }
  }

  /// For screens where we want to maintain back navigation
  static Future<void> _navigateWithHistory(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) async {
    // Check if we're already on this screen
    if (ModalRoute.of(context)?.settings.name == routeName) {
      return;
    }

    await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// For screens where we want a fresh navigation stack
  static Future<void> _navigateWithClearStack(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) async {
    // Check if we're already on this screen
    if (ModalRoute.of(context)?.settings.name == routeName) {
      return;
    }

    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false, // Remove all previous routes
      arguments: arguments,
    );
  }
}