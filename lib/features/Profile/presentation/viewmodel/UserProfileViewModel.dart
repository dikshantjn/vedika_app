import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Profile/data/models/MedicalProfile.dart';
import 'package:vedika_healthcare/features/Profile/data/models/PersonalProfile.dart';

class UserProfileViewModel extends ChangeNotifier {
  // Initial data for personal and medical profiles
  PersonalProfile _personalProfile = PersonalProfile(
    name: 'John Doe',
    photoUrl: 'https://example.com/photo.jpg',
    contactNumber: '+1234567890',
    abhaId: 'ABHA123456',
    email: 'john.doe@example.com',
    dateOfBirth: DateTime(1990, 1, 1),
    gender: 'Male',
    bloodGroup: 'O+',
    height: 175,
    weight: 70,
    emergencyContactNumber: '+9876543210',
    location: 'New York',
  );

  MedicalProfile _medicalProfile = MedicalProfile(
    medicalProfileId: 'MP123456',  // Example ID
    userProfileId: 'UP123456',  // Example ID
    isDiabetic: false,
    allergies: ['Peanuts'],
    eyePower: 1.5,
    currentMedication: ['Aspirin'],
    pastMedication: ['Paracetamol'],
    chronicConditions: ['Hypertension'],
    injuries: ['Fractured leg'],
    surgeries: ['Appendectomy'],
  );

  // Getters for personal and medical profiles
  PersonalProfile get personalProfile => _personalProfile;
  MedicalProfile get medicalProfile => _medicalProfile;

  // Method to update personal profile
  void updatePersonalProfile(PersonalProfile updatedProfile) {
    _personalProfile = updatedProfile;
    notifyListeners();
  }

  // Method to update medical profile
  void updateMedicalProfile(MedicalProfile updatedProfile) {
    _medicalProfile = updatedProfile;
    notifyListeners();
  }

  // Date formatting for birthdate
  String get formattedDateOfBirth {
    return DateFormat('M/d/yyyy').format(_personalProfile.dateOfBirth);
  }

  // Getter methods for medical profile fields
  bool get isDiabetic => _medicalProfile.isDiabetic;
  List<String> get allergies => _medicalProfile.allergies;
  double get eyePower => _medicalProfile.eyePower;
  List<String> get currentMedication => _medicalProfile.currentMedication;
  List<String> get pastMedication => _medicalProfile.pastMedication;
  List<String> get chronicConditions => _medicalProfile.chronicConditions;
  List<String> get injuries => _medicalProfile.injuries;
  List<String> get surgeries => _medicalProfile.surgeries;

  // Setter methods for medical profile fields (if needed)
  void setIsDiabetic(bool value) {
    _medicalProfile.isDiabetic = value;
    notifyListeners();
  }

  void setAllergies(List<String> value) {
    _medicalProfile.allergies = value;
    notifyListeners();
  }

  void setEyePower(double value) {
    _medicalProfile.eyePower = value;
    notifyListeners();
  }

  void setCurrentMedication(List<String> value) {
    _medicalProfile.currentMedication = value;
    notifyListeners();
  }

  void setPastMedication(List<String> value) {
    _medicalProfile.pastMedication = value;
    notifyListeners();
  }

  void setChronicConditions(List<String> value) {
    _medicalProfile.chronicConditions = value;
    notifyListeners();
  }

  void setInjuries(List<String> value) {
    _medicalProfile.injuries = value;
    notifyListeners();
  }

  void setSurgeries(List<String> value) {
    _medicalProfile.surgeries = value;
    notifyListeners();
  }

  // Calculate the profile completion percentage
  double calculateProfileCompletion() {
    int completedFields = 0;

    if (_personalProfile.name.isNotEmpty) completedFields++;
    if (_personalProfile.email.isNotEmpty) completedFields++;
    if (_personalProfile.contactNumber.isNotEmpty) completedFields++;
    if (_personalProfile.location.isNotEmpty) completedFields++;
    if (_personalProfile.dateOfBirth != null) completedFields++;
    if (_personalProfile.gender.isNotEmpty) completedFields++;
    if (_personalProfile.bloodGroup.isNotEmpty) completedFields++;
    if (_personalProfile.height != null) completedFields++;
    if (_personalProfile.weight != null) completedFields++;
    if (_personalProfile.emergencyContactNumber.isNotEmpty) completedFields++;

    return completedFields / 10.0; // Total fields are 10
  }

  // Check if the profile is complete
  bool isProfileComplete() {
    return _personalProfile.name.isNotEmpty &&
        _personalProfile.email.isNotEmpty &&
        _personalProfile.contactNumber.isNotEmpty &&
        _personalProfile.location.isNotEmpty &&
        _personalProfile.dateOfBirth != null &&
        _personalProfile.gender.isNotEmpty &&
        _personalProfile.bloodGroup.isNotEmpty &&
        _personalProfile.height != null &&
        _personalProfile.weight != null &&
        _personalProfile.emergencyContactNumber.isNotEmpty;
  }
}
