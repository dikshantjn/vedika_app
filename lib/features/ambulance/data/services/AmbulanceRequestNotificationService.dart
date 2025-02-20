import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulancePaymentDialog.dart';
import 'package:vedika_healthcare/main.dart';

// Define a global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AmbulanceRequestNotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("[Notification Clicked] Handling foreground click event...");
        handleNotificationClick(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    print("[Notification Service] Initialized successfully");
  }

  // Show notification when ambulance request is accepted
  static Future<void> showAmbulanceRequestNotification({
    required String ambulanceName,
    required String contact,
    required double totalDistance,
    required double baseFare,
    required double distanceCharge,
    required double totalAmount,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ambulance_channel',
      'Ambulance Requests',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1, // Notification ID
      "Ambulance Request Accepted!",
      "Your request has been accepted by $ambulanceName. Tap to proceed with payment.",
      details,
      payload:
      "$ambulanceName|$contact|$totalDistance|$baseFare|$distanceCharge|$totalAmount",
    );

    print("[Notification Sent] Ambulance request notification shown.");
  }

  // Handle notification click
  static void handleNotificationClick(String? payload) {
    print("[Notification Click] Payload: $payload");

    if (payload != null) {
      final data = payload.split('|');
      final ambulanceName = data[0];
      final contact = data[1];
      final totalDistance = double.parse(data[2]);
      final baseFare = double.parse(data[3]);
      final distanceCharge = double.parse(data[4]);
      final totalAmount = double.parse(data[5]);

      print("[Navigation] Opening AmbulanceSearchPage...");
      print("Current Context: ${navigatorKey.currentContext}");

      // Use the navigatorKey to navigate
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => AmbulanceSearchPage(),
        ),
            (route) => false, // Removes all previous routes
      ).then((_) {
        // Delay to ensure the context is available
        Future.delayed(Duration(milliseconds: 500), () {
          if (navigatorKey.currentContext != null) {
            print("[Dialog] Opening AmbulancePaymentDialog...");
            showDialog(
              context: navigatorKey.currentContext!,
              builder: (context) => AmbulancePaymentDialog(
                providerName: ambulanceName,
                baseFare: baseFare,
                distanceCharge: distanceCharge,
                totalAmount: totalAmount,
                totalDistance: totalDistance,
                onPaymentSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment Successful! Booking Confirmed.")),
                  );
                },
              ),
            );
          } else {
            print("[Error] navigatorKey.currentContext is NULL! Cannot show dialog.");
          }
        });
      }).catchError((error) {
        print("[Navigation Error] $error");
      });
    } else {
      print("[Error] Notification payload is NULL!");
    }
  }
}