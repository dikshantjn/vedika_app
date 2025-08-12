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
      isDiabetic: _ensureBool(json['isDiabetic']),
      allergies: _ensureListOfStrings(json['allergies']),
      eyePower: _ensureDouble(json['eyePower']),
      currentMedication: _ensureListOfStrings(json['currentMedication']),
      pastMedication: _ensureListOfStrings(json['pastMedication']),
      chronicConditions: _ensureListOfStrings(json['chronicConditions']),
      injuries: _ensureListOfStrings(json['injuries']),
      surgeries: _ensureListOfStrings(json['surgeries']),
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

  // Parsing helpers to make the model resilient to backend variations
  static List<String> _ensureListOfStrings(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return <String>[];
      // If comma-separated, split; else wrap as single-item list
      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return <String>[trimmed];
    }
    return <String>[];
  }

  static double _ensureDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    return parsed ?? 0.0;
  }

  static bool _ensureBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    final s = value.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
}
