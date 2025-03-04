class HealthRecord {
  final String id;
  final String name;
  final String type;
  final String fileUrl; // Google Drive link
  final DateTime uploadedAt;

  HealthRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.fileUrl,
    required this.uploadedAt,
  });

  // Convert JSON to Model
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      fileUrl: json['fileUrl'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
