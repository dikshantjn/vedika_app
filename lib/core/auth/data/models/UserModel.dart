class UserModel {
  final String userId;
  final String? name;
  final String? photo;
  final String? phoneNumber;
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
  final String? password;
  final bool status; // Boolean field for active/inactive
  final String? platform; // Add this line

  UserModel({
    required this.userId,
    this.name,
    this.photo,
    this.phoneNumber,
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
    this.password,
    required this.status,
    this.platform, // Add this line
  });


  factory UserModel.empty() {
    return UserModel(
      userId: '',
      name: 'Unknown',
      photo: null,
      phoneNumber: null,
      abhaId: null,
      emailId: null,
      dateOfBirth: null,
      gender: null,
      bloodGroup: null,
      height: null,
      weight: null,
      emergencyContactNumber: null,
      location: null,
      city: null,
      createdAt: DateTime.now(),
      password: null,
      status: false,
      platform: null, // Add this
    );
  }

  // ✅ Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      name: json['name'],
      photo: json['photo'],
      phoneNumber: json['phone_number'],
      abhaId: json['ABHA_ID'],
      emailId: json['emailId'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      emergencyContactNumber: json['emergencyContactNumber'],
      location: json['location'],
      city: json['city'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      password: json['password'],
      status: json['status'] == 1 || json['status'] == true, // Supports both `1/0` and `true/false`
      platform: json['platform'],

    );
  }

  // ✅ Convert UserModel to JSON
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
      "password": password,
      "status": status ? 1 : 0, // Converts boolean to `1/0` for API consistency
      "platform": platform,

    };
  }
}
