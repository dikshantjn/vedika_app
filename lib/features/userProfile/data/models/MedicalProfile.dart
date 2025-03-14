class MedicalProfile {
  final String medicalProfileId; // Unique ID for the medical profile
  final String userId; // Reference to the associated user profile ID
  final bool isDiabetic;
  final List<String> allergies;
  final double eyePower;
  final List<String> currentMedication;
  final List<String> pastMedication;
  final List<String> chronicConditions;
  final List<String> injuries;
  final List<String> surgeries;

  MedicalProfile({
    required this.medicalProfileId,
    required this.userId,
    required this.isDiabetic,
    required this.allergies,
    required this.eyePower,
    required this.currentMedication,
    required this.pastMedication,
    required this.chronicConditions,
    required this.injuries,
    required this.surgeries,
  });

  // Factory method to create a MedicalProfile object from a JSON map
  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      medicalProfileId: json['medicalProfileId'] ?? '',
      userId: json['userId'] ?? '',
      isDiabetic: json['isDiabetic'] ?? false,
      allergies: List<String>.from(json['allergies'] ?? []),
      eyePower: (json['eyePower'] ?? 0.0).toDouble(),
      currentMedication: List<String>.from(json['currentMedication'] ?? []),
      pastMedication: List<String>.from(json['pastMedication'] ?? []),
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      injuries: List<String>.from(json['injuries'] ?? []),
      surgeries: List<String>.from(json['surgeries'] ?? []),
    );
  }

  // Convert MedicalProfile object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'medicalProfileId': medicalProfileId,
      'userId': userId,
      'isDiabetic': isDiabetic,
      'allergies': allergies,
      'eyePower': eyePower,
      'currentMedication': currentMedication,
      'pastMedication': pastMedication,
      'chronicConditions': chronicConditions,
      'injuries': injuries,
      'surgeries': surgeries,
    };
  }

  // CopyWith method to create a new instance with updated values
  MedicalProfile copyWith({
    String? medicalProfileId,
    String? userId,
    bool? isDiabetic,
    List<String>? allergies,
    double? eyePower,
    List<String>? currentMedication,
    List<String>? pastMedication,
    List<String>? chronicConditions,
    List<String>? injuries,
    List<String>? surgeries,
  }) {
    return MedicalProfile(
      medicalProfileId: medicalProfileId ?? this.medicalProfileId,
      userId: userId ?? this.userId,
      isDiabetic: isDiabetic ?? this.isDiabetic,
      allergies: allergies ?? this.allergies,
      eyePower: eyePower ?? this.eyePower,
      currentMedication: currentMedication ?? this.currentMedication,
      pastMedication: pastMedication ?? this.pastMedication,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      injuries: injuries ?? this.injuries,
      surgeries: surgeries ?? this.surgeries,
    );
  }
}
