import 'package:hive/hive.dart';
import 'package:vedika_healthcare/features/notifications/data/models/AppNotification.dart';
import 'dart:convert';

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 0;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      data: json.decode(fields[3] as String) as Map<String, dynamic>,
      timestamp: fields[4] as DateTime,
      type: fields[5] as String,
      isRead: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.dataJson)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.isRead);
  }
} 