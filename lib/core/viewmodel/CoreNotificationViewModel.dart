import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/models/NotificationModel.dart';
import 'package:vedika_healthcare/core/services/NotificationService.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class CoreNotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<NotificationModel> _notifications = [];
  bool _isUserNotifications = true; // true for user, false for vendor
  String? _userId;
  String? _vendorId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<NotificationModel> get notifications => _notifications;
  bool get isUserNotifications => _isUserNotifications;

  // Computed getters
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;
  int get totalCount => _notifications.length;
  List<NotificationModel> get unreadNotifications => _notifications.where((notification) => !notification.isRead).toList();
  List<NotificationModel> get readNotifications => _notifications.where((notification) => notification.isRead).toList();

  // Initialize with user or vendor ID
  void initializeForUser(String userId) {
    _userId = userId;
    _vendorId = null;
    _isUserNotifications = true;
    clearError();
  }

  void initializeForVendor(String vendorId) {
    _vendorId = vendorId;
    _userId = null;
    _isUserNotifications = false;
    clearError();
  }

  // Load notifications
  Future<void> loadNotifications() async {
    if ((_userId == null && _vendorId == null)) {
      _error = 'No user or vendor ID provided';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      NotificationResponse response;
      if (_isUserNotifications && _userId != null) {
        response = await _notificationService.getUserNotifications(_userId!);
      } else if (!_isUserNotifications && _vendorId != null) {
        response = await _notificationService.getVendorNotifications(_vendorId!);
      } else {
        throw Exception('Invalid configuration');
      }

      _notifications = response.notifications;
      // Sort notifications by creation date (newest first)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh notifications (alias for loadNotifications)
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        // Update local notification state
        final index = _notifications.indexWhere((notification) => notification.notificationId == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to mark notification as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      bool allSuccess = true;
      for (final notification in _notifications.where((n) => !n.isRead)) {
        final success = await _notificationService.markAsRead(notification.notificationId);
        if (!success) {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        // Update all notifications locally
        _notifications = _notifications.map((notification) =>
            notification.copyWith(isRead: true)).toList();
        notifyListeners();
      }

      return allSuccess;
    } catch (e) {
      _error = 'Failed to mark all notifications as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        // Remove from local list
        _notifications.removeWhere((notification) => notification.notificationId == notificationId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete notification: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get notification by ID
  NotificationModel? getNotificationById(String notificationId) {
    try {
      return _notifications.firstWhere((notification) => notification.notificationId == notificationId);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all notifications
  void clearNotifications() {
    _notifications = [];
    _error = null;
    notifyListeners();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  // Get unread notifications by type
  List<NotificationModel> getUnreadNotificationsByType(String type) {
    return _notifications.where((notification) =>
        notification.type == type && !notification.isRead).toList();
  }

  // Toggle notification read status (for UI interactions)
  void toggleReadStatus(String notificationId) {
    final index = _notifications.indexWhere((notification) => notification.notificationId == notificationId);
    if (index != -1) {
      final currentStatus = _notifications[index].isRead;
      _notifications[index] = _notifications[index].copyWith(isRead: !currentStatus);
      notifyListeners();
    }
  }

  // Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
