import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/notifications/data/models/AppNotification.dart';
import 'package:vedika_healthcare/features/notifications/data/repositories/NotificationRepository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String _searchQuery = '';

  NotificationViewModel(this._repository) {
    _init();
    // Listen to changes in the notifications box
    Hive.box<AppNotification>('notifications').listenable().addListener(_onNotificationsChanged);
  }

  List<AppNotification> get notifications => _searchQuery.isEmpty
      ? _notifications
      : _repository.searchNotifications(_searchQuery);

  bool get isLoading => _isLoading;
  int get unreadCount => _repository.unreadCount;

  void _onNotificationsChanged() {
    fetchNotifications();
  }

  @override
  void dispose() {
    // Clean up the listener when the ViewModel is disposed
    Hive.box<AppNotification>('notifications').listenable().removeListener(_onNotificationsChanged);
    super.dispose();
  }

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
    // No need to call fetchNotifications() here as the box listener will handle it
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    // No need to call fetchNotifications() here as the box listener will handle it
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    // No need to call fetchNotifications() here as the box listener will handle it
  }

  Future<void> clearAllNotifications() async {
    await _repository.clearAllNotifications();
    // No need to call fetchNotifications() here as the box listener will handle it
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
