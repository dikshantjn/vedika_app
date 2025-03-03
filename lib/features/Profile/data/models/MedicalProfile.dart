// Medical Profile Model
class MedicalProfile {
  String medicalProfileId;  // Unique ID for the medical profile
  String userProfileId;  // Reference to the associated user profile ID
  bool isDiabetic;
  List<String> allergies;  // List of allergies
  double eyePower; // For example, left and right eye power
  List<String> currentMedication;  // List of current medications
  List<String> pastMedication;  // List of past medications
  List<String> chronicConditions;  // List of chronic conditions
  List<String> injuries;  // List of past injuries
  List<String> surgeries;  // List of past surgeries

  MedicalProfile({
    required this.medicalProfileId,
    required this.userProfileId,
    required this.isDiabetic,
    required this.allergies,
    required this.eyePower,
    required this.currentMedication,
    required this.pastMedication,
    required this.chronicConditions,
    required this.injuries,
    required this.surgeries,
  });

// Methods to update medical profile could also be added
}
