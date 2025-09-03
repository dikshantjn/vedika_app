import 'package:flutter/cupertino.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/main.dart';

class NotificationTapHandler {
  static bool _isHandlingNavigation = false;
  static String? _lastNotificationId;
  static DateTime? _lastNavigationTime;

  static Future<void> handleNotification(Map<String, dynamic> data, {bool isAppLaunch = false}) async {
    // Optimized timeout for faster response - much shorter wait
    if (_isHandlingNavigation) {
      debugPrint("⚠️ Navigation already in progress, waiting briefly...");

      // Much shorter wait for notifications - only 200ms max
      int attempts = 0;
      while (_isHandlingNavigation && attempts < 4) {
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }

      // If still busy, don't wait longer - let the notification proceed
      // This allows notifications to be handled faster
      if (_isHandlingNavigation) {
        debugPrint("⚠️ Previous navigation still in progress, proceeding with new notification");
        // Don't reset the flag - let both navigations complete
        // Just proceed with the current notification
      }
    } else {
      _isHandlingNavigation = true;
    }

    // Create notification ID for duplicate detection
    String currentNotificationId = '${data['type']?.toString() ?? 'UNKNOWN'}_${data['orderId'] ?? data['id'] ?? 'unknown'}';

    // Check if this is a repeated notification (same type and data)
    bool isRepeatedNotification = _lastNotificationId == currentNotificationId &&
                                  _lastNavigationTime != null &&
                                  DateTime.now().difference(_lastNavigationTime!).inSeconds < 5; // Reduced from 30 to 5 seconds

    if (isRepeatedNotification) {
      debugPrint("🔄 Repeated notification detected - optimizing for faster response");
    }

    String type = data['type']?.toString() ?? 'UNKNOWN';
    print("Notification Type: $type");

    // Update tracking for this notification
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
              arguments: {'initialTab': 2}, // 2 is the index for Bookings tab
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.bloodBank,
              arguments: {'initialTab': 2}, // 2 is the index for Bookings tab
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

        case 'MEDICINE_ORDERS':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorMedicalStoreDashBoard,
              arguments: {'initialIndex': 1}, // 1 is the index for Orders tab
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorMedicalStoreDashBoard,
              arguments: {'initialIndex': 1}, // 1 is the index for Orders tab
            );
          }
          break;

        case 'ProductPartnerOrders':
          if (isAppLaunch) {
            await _navigateWithClearStack(
              context,
              AppRoutes.VendorProductPartnerDashBoard,
              arguments: {'initialTab': 2}, // 2 is the index for Orders tab
            );
          } else {
            await _navigateWithHistory(
              context,
              AppRoutes.VendorProductPartnerDashBoard,
              arguments: {'initialTab': 2}, // 2 is the index for Orders tab
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
            await Future.delayed(const Duration(milliseconds: 50));
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
            await Future.delayed(const Duration(milliseconds: 50));
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
            await Future.delayed(const Duration(milliseconds: 50));
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

        case 'NEW_BOOKING':
          if (isAppLaunch) {
            // First navigate to home screen
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            // Then navigate to AmbulanceAgencyMainScreen with Requests tab selected
            await _navigateWithHistory(
              context,
              AppRoutes.AmbulanceAgencyDashboard,
              arguments: {'initialTab': 1}, // 1 is the index for Requests tab
            );
          } else {
            // If app is already running, navigate to AmbulanceAgencyMainScreen with Requests tab
            await _navigateWithHistory(
              context,
              AppRoutes.AmbulanceAgencyDashboard,
              arguments: {'initialTab': 1}, // 1 is the index for Requests tab
            );
          }
          break;

        case 'LAB_TEST_BOOKING':
          if (isAppLaunch) {
            // First navigate to home screen
            await _navigateWithClearStack(
              context,
              AppRoutes.home,
            );
            await Future.delayed(const Duration(milliseconds: 50));
            // Then navigate to LabTestDashboardScreen with Bookings tab selected
            await _navigateWithHistory(
              context,
              AppRoutes.VendorPathologyDashBoard,
              arguments: {'initialTab': 1}, // 1 is the index for Bookings tab
            );
          } else {
            // If app is already running, navigate to LabTestDashboardScreen with Bookings tab
            await _navigateWithHistory(
              context,
              AppRoutes.VendorPathologyDashBoard,
              arguments: {'initialTab': 1}, // 1 is the index for Bookings tab
            );
          }
          break;

        default:
          print("Unknown notification type: $type");
      }
    } catch (e) {
      print("Navigation error: $e");
    } finally {
      // Only reset flag if it was set by this instance
      // This prevents resetting flag for concurrent notifications
      if (_isHandlingNavigation) {
        _isHandlingNavigation = false;
      }
    }
  }

  /// For screens where we want to maintain back navigation
  static Future<void> _navigateWithHistory(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) async {
    // Skip the route name check for faster navigation
    // Just proceed with navigation - the notification should navigate regardless
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
    // Skip the route name check for faster navigation
    // Just proceed with navigation - the notification should navigate regardless
    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false, // Remove all previous routes
      arguments: arguments,
    );
  }
}