import 'package:flutter/cupertino.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/main.dart';

class NotificationTapHandler {
  static bool _isHandlingNavigation = false;

  static Future<void> handleNotification(Map<String, dynamic> data) async {
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
          await _navigateWithClearStack(
            context,
            AppRoutes.trackOrderScreen,
            arguments: {'orderId': data['orderId']},
          );
          break;

        case 'EMERGENCY_SERVICE':
          await _navigateWithClearStack(context, AppRoutes.ambulanceSearch);
          break;

        case 'NEW_ORDER':
          await _navigateWithHistory(
            context,
            AppRoutes.medicineOrder,
            arguments: {'orderId': data['orderId']},
          );
          break;

        case 'USER_PROFILE':
          await _navigateWithHistory(context, AppRoutes.userProfile);
          break;

        case 'NOTIFICATIONS':
          await _navigateWithHistory(context, AppRoutes.notification);
          break;

        case 'CART_SCREEN':
          await _navigateWithClearStack(context, AppRoutes.goToCart);
          break;

        case 'ORDER_HISTORY':
          await _navigateWithClearStack(context, AppRoutes.orderHistory);
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