import 'package:hive/hive.dart';
import 'dart:convert';

@HiveType(typeId: 0)
class AppNotification {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String dataJson; // Store data as JSON string

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String type;

  @HiveField(6)
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