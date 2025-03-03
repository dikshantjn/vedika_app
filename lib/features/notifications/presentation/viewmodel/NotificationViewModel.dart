import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/notifications/data/models/NotificationModel.dart';
import 'package:vedika_healthcare/features/notifications/data/repositories/NotificationRepository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  List<NotificationModel> _notifications = [];

  NotificationViewModel(this._notificationRepository);

  List<NotificationModel> get notifications => _notifications;

  // Fetch notifications from the repository
  Future<void> fetchNotifications() async {
    try {
      // Fetch notifications from the repository
      _notifications = await _notificationRepository.fetchNotifications();
      notifyListeners(); // Notify listeners to update the UI
    } catch (error) {
      // Handle any errors that occur during fetching
      print("Error fetching notifications: $error");
    }
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final notification =
    _notifications.firstWhere((n) => n.id == notificationId);
    notification.markAsRead();
    notifyListeners();
  }
}
