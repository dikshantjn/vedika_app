import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/main.dart';
import 'package:vedika_healthcare/shared/utils/NotificationTapHandler.dart';

@pragma('vm:entry-point')
class FCMService {
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  FCMService()
      : _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    headers: {'Content-Type': 'application/json'},
  )),
        _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
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
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          // Add delay to ensure app is fully ready
          await Future.delayed(Duration(milliseconds: 300));
          if (navigatorKey.currentContext != null && navigatorKey.currentContext!.mounted) {
            handleNotificationTap(response.payload!, navigatorKey.currentContext!);
          }
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Unique channel ID
      'High Importance Notifications', // Name of the channel
      description: 'This channel is used for high importance notifications.',
      importance: Importance.max, // Maximum importance
      playSound: true, // Enable sound
      enableVibration: true, // Enable vibration
    );

    // Initialize the FlutterLocalNotificationsPlugin with the created channel
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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
    } else {
      print('❌ User denied notification permission');
    }
  }

  /// Fetch and send the FCM token to the backend (for normal users)
  Future<void> getTokenAndSend(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await sendTokenToServer(userId, token);
    }
  }

  /// Fetch and send the FCM token to the backend (for vendors)
  Future<void> getVendorTokenAndSend(String vendorId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await sendVendorTokenToServer(vendorId, token);
    }
  }

  /// Send the FCM token to the backend (for normal users)
  Future<void> sendTokenToServer(String userId, String token) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.saveFcmToken, // ✅ Correct API path
        data: jsonEncode({'userId': userId, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
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
      } else {
        print("❌ Failed to send Vendor FCM Token: ${response.data}");
      }
    } catch (e) {
      print("❌ Error sending Vendor FCM Token: $e");
    }
  }

  /// Set up FCM message listeners
  void setupFCMListener() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received");
      showNotification(message);
    });

    // Background/terminated messages (when app is brought to foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App opened from background via notification");

      if (navigatorKey.currentContext != null) {
        // Add a short delay to ensure navigation executes properly
        Future.delayed(Duration(milliseconds: 300), () {
          handleNotificationTap(jsonEncode(message.data), navigatorKey.currentContext!);
        });
      }else{
        debugPrint("navigatorKey.currentContext is null");
      }
    });


    // Background handler for when app is completely closed
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  /// Handle the notification tap
  void handleNotificationTap(String payload, BuildContext context) {
    debugPrint("Notification Payload: $payload");
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      NotificationTapHandler.handleNotification(data);  // Delegate to NotificationTapHandler
    } catch (e) {
      debugPrint("Error handling notification: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint("Background message received: ${message.notification?.title}");

    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: androidInitSettings),
    );

    // Process the message
    if (message.data.isNotEmpty) {
      final payload = jsonEncode(message.data);

      // Store the notification data to be processed when app opens
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new notification',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    }
  }

  Future<void> safeNavigate(String route, {BuildContext? context, Object? arguments}) async {
    context ??= navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      print("Cannot navigate - context not available");
      return;
    }

    try {
      await Navigator.pushNamed(context, route, arguments: arguments);
    } catch (e) {
      print("Navigation failed: $e");
    }
  }

  /// Delete the FCM token from the backend (for normal users)
  Future<void> deleteTokenFromServer(String userId) async {
    try {
      Response response = await _dio.delete(
        ApiEndpoints.removeFcmToken,  // ✅ Using DELETE instead of POST
        data: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
      } else {
        print("❌ Failed to delete User FCM Token: ${response.data}");
      }
    } catch (e) {
      print("❌ Error deleting User FCM Token: $e");
    }
  }

  /// Delete the FCM token from the backend (for vendors)
  Future<void> deleteVendorTokenFromServer(String vendorId) async {
    try {
      Response response = await _dio.delete(
        ApiEndpoints.removeVendorFcmToken,  // ✅ Using DELETE instead of POST
        data: jsonEncode({'vendorId': vendorId}),
      );

      if (response.statusCode == 200) {
      } else {
        print("❌ Failed to delete Vendor FCM Token: ${response.data}");
      }
    } catch (e) {
      print("❌ Error deleting Vendor FCM Token: $e");
    }
  }
}
