class UserModel {
  final String userId;
  final String? name;
  final String? photo;
  final String phoneNumber;
  final String? abhaId;
  final String? emailId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final double? height;
  final double? weight;
  final String? emergencyContactNumber;
  final String? location;
  final String? city;
  final DateTime createdAt;
  final String? password;  // Added password field
  final bool status;        // Added status field

  UserModel({
    required this.userId,
    this.name,
    this.photo,
    required this.phoneNumber,
    this.abhaId,
    this.emailId,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.height,
    this.weight,
    this.emergencyContactNumber,
    this.location,
    this.city,
    required this.createdAt,
    this.password,          // Initialize password
    required this.status,    // Initialize status
  });

  // Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      photo: json['photo'],
      phoneNumber: json['phone_number'],
      abhaId: json['ABHA_ID'],
      emailId: json['emailId'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      emergencyContactNumber: json['emergencyContactNumber'],
      location: json['location'],
      city: json['city'],
      createdAt: DateTime.parse(json['createdAt']),
      password: json['password'], // Assign password if present in JSON
      status: json['status'] ?? true,  // Default to true if status is not provided
    );
  }

  // Convert UserModel to JSON (for API requests if needed)
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "photo": photo,
      "phone_number": phoneNumber,
      "ABHA_ID": abhaId,
      "emailId": emailId,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "gender": gender,
      "bloodGroup": bloodGroup,
      "height": height,
      "weight": weight,
      "emergencyContactNumber": emergencyContactNumber,
      "location": location,
      "city": city,
      "createdAt": createdAt.toIso8601String(),
      "password": password,     // Include password in JSON
      "status": status,         // Include status in JSON
    };
  }
}
