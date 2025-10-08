// 📌 Usage Example:
//
// ```dart
// // Initialize ViewModel for user
// final notificationViewModel = NotificationViewModel();
// notificationViewModel.initializeForUser('user123');
// await notificationViewModel.loadNotifications();
//
// // Initialize ViewModel for vendor
// notificationViewModel.initializeForVendor('vendor456');
// await notificationViewModel.loadNotifications();
//
// // Mark notification as read
// await notificationViewModel.markAsRead('notification-id');
//
// // Delete notification
// await notificationViewModel.deleteNotification('notification-id');
// ```

// 📌 Notification Response Model
class NotificationResponse {
  final bool success;
  final List<NotificationModel> notifications;

  NotificationResponse({
    required this.success,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((notification) => NotificationModel.fromJson(notification))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'notifications': notifications.map((notification) => notification.toJson()).toList(),
    };
  }
}

// 📌 Notification Model
// Converted from JavaScript/Sequelize model to Flutter/Dart

class NotificationModel {
  final String notificationId;
  final String? userId;
  final String? vendorId;
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.notificationId,
    this.userId,
    this.vendorId,
    required this.title,
    required this.body,
    this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating instance from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'],
      vendorId: json['vendorId'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'],
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'vendorId': vendorId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? vendorId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'NotificationModel(notificationId: $notificationId, title: $title, isRead: $isRead)';
  }

  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;
}
