class PersonalProfile {
  String? userId;
  String name;
  String photoUrl;
  String phoneNumber;
  String abhaId;
  String email;
  DateTime dateOfBirth;
  String gender;
  String bloodGroup;
  double height;
  double weight;
  String emergencyContactNumber;
  String location;

  PersonalProfile({
    this.userId, // Made optional
    required this.name,
    required this.photoUrl,
    required this.phoneNumber,
    required this.abhaId,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.emergencyContactNumber,
    required this.location,
  });

  // Convert JSON to Model
  factory PersonalProfile.fromJson(Map<String, dynamic> json) {
    return PersonalProfile(
      userId: json['userId'],
      name: json['name'] ?? '',
      photoUrl: json['photo'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      abhaId: json['ABHA_ID'] ?? '',
      email: json['emailId'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : DateTime.now(),
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      height: json['height'] != null ? (json['height'] as num).toDouble() : 0.0,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 0.0,
      emergencyContactNumber: json['emergencyContactNumber'] ?? '',
      location: json['location'] ?? '',
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) "userId": userId, // Include only if not null
      "name": name,
      "photo": photoUrl,
      "phone_number": phoneNumber,
      "ABHA_ID": abhaId,
      "emailId": email,
      "dateOfBirth": dateOfBirth.toIso8601String(),
      "gender": gender,
      "bloodGroup": bloodGroup,
      "height": height,
      "weight": weight,
      "emergencyContactNumber": emergencyContactNumber,
      "location": location,
    };
  }
}
