// Personal Profile Model
class PersonalProfile {
  String name;
  String photoUrl;
  String contactNumber;
  String abhaId;
  String email;
  DateTime dateOfBirth;
  String gender;
  String bloodGroup;
  double height;
  double weight;
  String emergencyContactNumber;
  String location; // Can be city, state, etc.

  PersonalProfile({
    required this.name,
    required this.photoUrl,
    required this.contactNumber,
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

// You can also add methods to update the profile if necessary
}

