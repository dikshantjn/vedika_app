class Prescription {
  final String prescriptionId;
  final String vendorId;
  final String userId;
  final String? userName;
  final String? userPhone;
  final List<String> prescriptionFiles;
  final String? quantityPreference;
  final String? skipNotes;
  final String status;
  final String? vendorNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.prescriptionId,
    required this.vendorId,
    required this.userId,
    this.userName,
    this.userPhone,
    required this.prescriptionFiles,
    this.quantityPreference,
    this.skipNotes,
    required this.status,
    this.vendorNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    // Extract user information from the user object (lowercase)
    final userData = json['user'] as Map<String, dynamic>?;
    
    return Prescription(
      prescriptionId: json['prescriptionId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      userId: json['userId'] ?? '',
      userName: userData?['name'],
      userPhone: userData?['phone_number'],
      prescriptionFiles: List<String>.from(json['prescriptionFiles'] ?? []),
      quantityPreference: json['quantityPreference'],
      skipNotes: json['skipNotes'],
      status: json['status'] ?? 'pending',
      vendorNote: json['vendorNote'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionId': prescriptionId,
      'vendorId': vendorId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'prescriptionFiles': prescriptionFiles,
      'quantityPreference': quantityPreference,
      'skipNotes': skipNotes,
      'status': status,
      'vendorNote': vendorNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Prescription copyWith({
    String? prescriptionId,
    String? vendorId,
    String? userId,
    String? userName,
    String? userPhone,
    List<String>? prescriptionFiles,
    String? quantityPreference,
    String? skipNotes,
    String? status,
    String? vendorNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      prescriptionFiles: prescriptionFiles ?? this.prescriptionFiles,
      quantityPreference: quantityPreference ?? this.quantityPreference,
      skipNotes: skipNotes ?? this.skipNotes,
      status: status ?? this.status,
      vendorNote: vendorNote ?? this.vendorNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
