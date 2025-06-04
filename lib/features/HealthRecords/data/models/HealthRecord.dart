class HealthRecord {
  final String healthRecordId;
  final String userId;
  final String name;
  final String type;
  final String fileUrl; // Google Drive link
  final DateTime uploadedAt;

  HealthRecord({
    required this.healthRecordId,
    required this.userId,
    required this.name,
    required this.type,
    required this.fileUrl,
    required this.uploadedAt,
  });

  // Convert JSON to Model
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      healthRecordId: json['healthRecordId'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      fileUrl: json['fileUrl'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'healthRecordId': healthRecordId,
      'userId': userId,
      'name': name,
      'type': type,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
