import 'package:dio/dio.dart';
import 'package:vedika_healthcare/features/notifications/data/models/AppNotification.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class NotificationRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));
  final List<AppNotification> _cache = [];

  Future<void> init() async {
    // No-op: Hive removed
  }

  Future<void> fetchNotifications({String? userId, String? vendorId}) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) queryParams['userId'] = userId;
    if (vendorId != null) queryParams['vendorId'] = vendorId;
    final response = await _dio.get(ApiEndpoints.getNotifications, queryParameters: queryParams);
    final data = response.data;
    if (data is List) {
      _cache
        ..clear()
        ..addAll(data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
      _cache.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  Future<void> saveNotification(AppNotification notification) async {
    // In-memory only
    final index = _cache.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      _cache[index] = notification;
    } else {
      _cache.add(notification);
      _cache.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  Future<void> markAsRead(String id) async {
    await _dio.put(ApiEndpoints.markNotificationAsRead(id));
    final idx = _cache.indexWhere((n) => n.id == id);
    if (idx >= 0) _cache[idx].isRead = true;
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete(ApiEndpoints.deleteNotification(id));
    _cache.removeWhere((n) => n.id == id);
  }

  Future<void> clearAllNotifications() async {
    _cache.clear();
  }

  List<AppNotification> getAllNotifications() {
    return List<AppNotification>.unmodifiable(_cache);
  }

  List<AppNotification> searchNotifications(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _cache.where((notification) {
      return notification.title.toLowerCase().contains(lowercaseQuery) ||
          notification.body.toLowerCase().contains(lowercaseQuery) ||
          notification.type.toLowerCase().contains(lowercaseQuery);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int get unreadCount => _cache.where((n) => !n.isRead).length;
}
