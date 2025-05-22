import 'dart:convert';
import 'package:hive/hive.dart';

class MapAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 1;

  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final jsonString = reader.readString();
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeString(json.encode(obj));
  }
} 