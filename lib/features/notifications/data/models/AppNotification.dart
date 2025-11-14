import 'dart:convert';

class AppNotification {
  final String id;

  final String title;

  final String body;

  final String dataJson; // Store data as JSON string

  final DateTime timestamp;

  final String type;

  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required Map<String, dynamic> data,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  }) : dataJson = json.encode(data);

  Map<String, dynamic> get data => json.decode(dataJson) as Map<String, dynamic>;

  factory AppNotification.fromJson(Map<String, dynamic> jsonMap) {
    final data = (jsonMap['data'] ?? {}) as Map<String, dynamic>;
    final ts = jsonMap['timestamp'];
    return AppNotification(
      id: jsonMap['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: jsonMap['title']?.toString() ?? '',
      body: jsonMap['body']?.toString() ?? '',
      data: data,
      timestamp: ts is String ? DateTime.tryParse(ts) ?? DateTime.now() : (ts is int ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now()),
      type: jsonMap['type']?.toString() ?? 'General',
      isRead: (jsonMap['isRead'] as bool?) ?? (jsonMap['read'] as bool?) ?? false,
    );
  }

  factory AppNotification.fromPayload(Map<String, dynamic> payload) {
    final notification = payload['notification'] as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>;
    
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification['title'] ?? '',
      body: notification['body'] ?? '',
      data: data,
      timestamp: DateTime.now(),
      type: data['type'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }
} 