import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/notifications/data/models/AppNotification.dart';
import 'package:vedika_healthcare/features/notifications/data/repositories/NotificationRepository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String _searchQuery = '';

  NotificationViewModel(this._repository) {
    _init();
  }

  List<AppNotification> get notifications => _searchQuery.isEmpty
      ? _notifications
      : _repository.searchNotifications(_searchQuery);

  bool get isLoading => _isLoading;
  int get unreadCount => _repository.unreadCount;

  Future<void> _init() async {
    await _repository.init();
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = _repository.getAllNotifications();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    await _repository.saveNotification(notification);
    await fetchNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await fetchNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    await fetchNotifications();
  }

  Future<void> clearAllNotifications() async {
    await _repository.clearAllNotifications();
    await fetchNotifications();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
