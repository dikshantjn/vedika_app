import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';


class NotificationTapHandler {
  /// Centralize all the navigation logic here based on notification data
  static void handleNotification(Map<String, dynamic> data, BuildContext context) {
    // Checking the type of the notification
    String type = data['type'];

    switch (type) {
      case 'TRACK_ORDER':
        String orderId = data['orderId'];
        navigateToTrackOrderScreen(context, orderId);
        break;

      case 'EMERGENCY_SERVICE':
        navigateToEmergencyScreen(context);
        break;

      case 'NEW_ORDER':
        String orderId = data['orderId'];
        navigateToOrderDetailsScreen(context, orderId);
        break;

      case 'USER_PROFILE':
        navigateToUserProfileScreen(context);
        break;

      case 'NOTIFICATIONS':
        navigateToNotificationScreen(context);
        break;

    // Add more cases as needed
      default:
        print("Unknown notification type: $type");
        break;
    }
  }

  // Navigation methods for specific screens using AppRoutes

  static void navigateToTrackOrderScreen(BuildContext context, String orderId) {
    Navigator.pushNamed(
      context,
      AppRoutes.trackOrderScreen,
    );
  }

  static void navigateToEmergencyScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.ambulanceSearch);
  }

  static void navigateToOrderDetailsScreen(BuildContext context, String orderId) {
    Navigator.pushNamed(
      context,
      AppRoutes.medicineOrder,
      arguments: {'orderId': orderId},
    );
  }

  static void navigateToUserProfileScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  static void navigateToNotificationScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.notification);
  }
}
