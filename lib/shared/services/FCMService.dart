import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceRequestNotificationService.dart';
import 'package:vedika_healthcare/shared/utils/NotificationTapHandler.dart';  // Import NotificationTapHandler

class FCMService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl, // ✅ Using centralized API base URL
    headers: {'Content-Type': 'application/json'},
  ));

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Function(String)? onNotificationTap; // Callback for handling taps

  FCMService({this.onNotificationTap}) {
    _initializeNotifications();
    setupFCMListener();
  }

  /// Initialize local notifications
  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          onNotificationTap?.call(response.payload!); // Handle notification tap
          _handleNotificationTap(response.payload!);  // Handle the navigation after tap
        }
      },
    );
  }

  /// Show notification when a message arrives
  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Unique channel ID
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? "New Message",
      message.notification?.body ?? "You have a new notification",
      details,
      payload: jsonEncode(message.data), // 🔥 Pass notification data as payload
    );
  }

  /// Request notification permissions
  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');
    } else {
      print('❌ User denied notification permission');
    }
  }

  /// Fetch and send the FCM token to the backend (for normal users)
  Future<void> getTokenAndSend(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("🔹 FCM Token: $token");
      await sendTokenToServer(userId, token);
    }
  }

  /// Fetch and send the FCM token to the backend (for vendors)
  Future<void> getVendorTokenAndSend(String vendorId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("🔹 Vendor FCM Token: $token");
      await sendVendorTokenToServer(vendorId, token);
    }
  }

  /// Send the FCM token to the backend (for normal users)
  Future<void> sendTokenToServer(String userId, String token) async {
    print("ApiEndpoints.saveFcmToken ${ApiEndpoints.saveFcmToken}");
    try {
      Response response = await _dio.post(
        ApiEndpoints.saveFcmToken, // ✅ Correct API path
        data: jsonEncode({'userId': userId, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print("✅ FCM Token sent to server successfully");
      } else {
        print("❌ Failed to send FCM Token: ${response.data}");
      }
    } catch (e) {
      print("❌ Error sending FCM Token: $e");
    }
  }

  /// Send the FCM token to the backend (for vendors)
  Future<void> sendVendorTokenToServer(String vendorId, String token) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.saveVendorFcmToken, // ✅ Correct API path for vendor
        data: jsonEncode({'vendorId': vendorId, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print("✅ Vendor FCM Token sent to server successfully");
      } else {
        print("❌ Failed to send Vendor FCM Token: ${response.data}");
      }
    } catch (e) {
      print("❌ Error sending Vendor FCM Token: $e");
    }
  }

  /// Set up FCM message listeners
  void setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground message received: ${message.notification?.title}");
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 Notification tapped while app is in background: ${message.data}");
      _handleNotificationTap(jsonEncode(message.data));
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("📩 Notification tapped when app was closed: ${message.data}");
        _handleNotificationTap(jsonEncode(message.data));
      }
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  /// Handle the notification tap by passing the payload to NotificationTapHandler
  void _handleNotificationTap(String payload) {
    Map<String, dynamic> data = jsonDecode(payload);
    NotificationTapHandler.handleNotification(data, navigatorKey.currentContext!); // Pass the context for navigation
  }
}

/// Handle background notifications
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print("📩 Background message received: ${message.notification?.title}");
}
