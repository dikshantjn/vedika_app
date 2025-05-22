import 'package:hive/hive.dart';
import 'package:vedika_healthcare/features/notifications/data/models/AppNotification.dart';

class NotificationRepository {
  static const String _boxName = 'notifications';
  late Box<AppNotification> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<AppNotification>(_boxName);
    } else {
      _box = Hive.box<AppNotification>(_boxName);
    }
  }

  Future<void> saveNotification(AppNotification notification) async {
    await _box.put(notification.id, notification);
  }

  Future<void> markAsRead(String id) async {
    final notification = _box.get(id);
    if (notification != null) {
      notification.isRead = true;
      await _box.put(id, notification);
    }
  }

  Future<void> deleteNotification(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAllNotifications() async {
    await _box.clear();
  }

  List<AppNotification> getAllNotifications() {
    return _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<AppNotification> searchNotifications(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((notification) {
      return notification.title.toLowerCase().contains(lowercaseQuery) ||
          notification.body.toLowerCase().contains(lowercaseQuery) ||
          notification.type.toLowerCase().contains(lowercaseQuery);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int get unreadCount => _box.values.where((n) => !n.isRead).length;
}
