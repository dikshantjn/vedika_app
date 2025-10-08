import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/models/NotificationModel.dart';

class NotificationService {
  final Dio _dio;

  NotificationService() : _dio = Dio() {
    // Configure Dio
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // 📌 Get notifications for user
  Future<NotificationResponse> getUserNotifications(String userId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getNotifications,
        queryParameters: {'userId': userId},
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return NotificationResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load user notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching user notifications: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching user notifications: $e');
    }
  }

  // 📌 Get notifications for vendor
  Future<NotificationResponse> getVendorNotifications(String vendorId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getNotifications,
        queryParameters: {'vendorId': vendorId},
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return NotificationResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load vendor notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching vendor notifications: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching vendor notifications: $e');
    }
  }

  // 📌 Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.markNotificationAsRead(notificationId),
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error marking notification as read: ${e.message}');
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // 📌 Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteNotification(notificationId),
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error deleting notification: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  // 📌 Get unread count for user
  Future<int> getUserUnreadCount(String userId) async {
    try {
      final response = await getUserNotifications(userId);
      return response.notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      return 0; // Return 0 on error
    }
  }

  // 📌 Get unread count for vendor
  Future<int> getVendorUnreadCount(String vendorId) async {
    try {
      final response = await getVendorNotifications(vendorId);
      return response.notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      return 0; // Return 0 on error
    }
  }
}
