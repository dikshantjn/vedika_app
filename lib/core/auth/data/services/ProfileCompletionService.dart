import 'package:vedika_healthcare/core/auth/data/services/UserService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

enum ServiceType {
  ambulance,
  hospital,
  bloodBank,
  labTest,
  medicineDelivery,
  clinic
}

class ProfileCompletionService {
  final UserService _userService = UserService();

  Future<bool> isProfileComplete(String userId, ServiceType serviceType) async {
    try {
      print('Checking profile completion for userId: $userId and service: $serviceType');
      final user = await _userService.getUserById(userId);
      if (user == null) {
        print('User not found');
        return false;
      }

      bool isComplete = false;
      switch (serviceType) {
        case ServiceType.ambulance:
          isComplete = _checkAmbulanceProfile(user);
          break;
        case ServiceType.hospital:
          isComplete = _checkHospitalProfile(user);
          break;
        case ServiceType.bloodBank:
          isComplete = _checkBloodBankProfile(user);
          break;
        case ServiceType.labTest:
          isComplete = _checkLabTestProfile(user);
          break;
        case ServiceType.medicineDelivery:
          isComplete = _checkMedicineDeliveryProfile(user);
          break;
        case ServiceType.clinic:
          isComplete = _checkClinicProfile(user);
          break;
      }

      print('Profile completion result for $serviceType: $isComplete');
      if (!isComplete) {
        final missingFields = getMissingFields(user, serviceType);
        print('Missing fields: $missingFields');
      }
      return isComplete;
    } catch (e, stackTrace) {
      print('Error checking profile completion: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  bool _checkAmbulanceProfile(UserModel user) {
    print('Checking ambulance profile fields:');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Location: ${user.location}');
    print('Emergency Contact: ${user.emergencyContactNumber}');

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.emergencyContactNumber?.isNotEmpty == true;

    print('Ambulance profile complete: $isComplete');
    return isComplete;
  }

  bool _checkHospitalProfile(UserModel user) {
    print('Checking hospital profile fields:');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Location: ${user.location}');
    print('DOB: ${user.dateOfBirth}');
    print('Blood Group: ${user.bloodGroup}');
    print('Emergency Contact: ${user.emergencyContactNumber}');

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.dateOfBirth != null &&
        user.bloodGroup?.isNotEmpty == true &&
        user.emergencyContactNumber?.isNotEmpty == true;

    print('Hospital profile complete: $isComplete');
    return isComplete;
  }

  bool _checkBloodBankProfile(UserModel user) {
    print('Checking blood bank profile fields:');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Location: ${user.location}');
    print('DOB: ${user.dateOfBirth}');
    print('Blood Group: ${user.bloodGroup}');

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.bloodGroup?.isNotEmpty == true &&
        user.dateOfBirth != null;

    print('Blood bank profile complete: $isComplete');
    return isComplete;
  }

  bool _checkLabTestProfile(UserModel user) {
    print('Checking lab test profile fields:');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Location: ${user.location}');
    print('DOB: ${user.dateOfBirth}');

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.dateOfBirth != null;

    print('Lab test profile complete: $isComplete');
    return isComplete;
  }

  bool _checkMedicineDeliveryProfile(UserModel user) {
    print('Checking medicine delivery profile fields:');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Location: ${user.location}');

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true;

    print('Medicine delivery profile complete: $isComplete');
    return isComplete;
  }

  bool _checkClinicProfile(UserModel user) {
    print('Checking clinic profile fields:');
    print('Name: ${user.name}');
    print('Phone: ${user.phoneNumber}');
    print('Location: ${user.location}');
    print('DOB: ${user.dateOfBirth}');
    print('Blood Group: ${user.bloodGroup}');

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.dateOfBirth != null &&
        user.bloodGroup?.isNotEmpty == true;

    print('Clinic profile complete: $isComplete');
    return isComplete;
  }

  Map<String, String> getMissingFields(UserModel user, ServiceType serviceType) {
    print('Getting missing fields for service: $serviceType');
    Map<String, String> missingFields = {};

    switch (serviceType) {
      case ServiceType.ambulance:
        if (user.name?.isNotEmpty != true) missingFields['name'] = 'Full Name';
        if (user.location?.isNotEmpty != true) missingFields['location'] = 'Location';
        if (user.emergencyContactNumber?.isNotEmpty != true) missingFields['emergencyContactNumber'] = 'Emergency Contact';
        break;

      case ServiceType.hospital:
        if (user.name?.isNotEmpty != true) missingFields['name'] = 'Full Name';
        if (user.location?.isNotEmpty != true) missingFields['location'] = 'Location';
        if (user.dateOfBirth == null) missingFields['dateOfBirth'] = 'Date of Birth';
        if (user.bloodGroup?.isNotEmpty != true) missingFields['bloodGroup'] = 'Blood Group';
        if (user.emergencyContactNumber?.isNotEmpty != true) missingFields['emergencyContactNumber'] = 'Emergency Contact';
        break;

      case ServiceType.bloodBank:
        if (user.name?.isNotEmpty != true) missingFields['name'] = 'Full Name';
        if (user.location?.isNotEmpty != true) missingFields['location'] = 'Location';
        if (user.dateOfBirth == null) missingFields['dateOfBirth'] = 'Date of Birth';
        if (user.bloodGroup?.isNotEmpty != true) missingFields['bloodGroup'] = 'Blood Group';
        break;

      case ServiceType.labTest:
        if (user.name?.isNotEmpty != true) missingFields['name'] = 'Full Name';
        if (user.location?.isNotEmpty != true) missingFields['location'] = 'Location';
        if (user.dateOfBirth == null) missingFields['dateOfBirth'] = 'Date of Birth';
        break;

      case ServiceType.medicineDelivery:
        if (user.name?.isNotEmpty != true) missingFields['name'] = 'Full Name';
        if (user.location?.isNotEmpty != true) missingFields['location'] = 'Location';
        break;

      case ServiceType.clinic:
        if (user.name?.isNotEmpty != true) missingFields['name'] = 'Full Name';
        if (user.location?.isNotEmpty != true) missingFields['location'] = 'Location';
        if (user.dateOfBirth == null) missingFields['dateOfBirth'] = 'Date of Birth';
        if (user.bloodGroup?.isNotEmpty != true) missingFields['bloodGroup'] = 'Blood Group';
        break;
    }

    print('Missing fields: $missingFields');
    return missingFields;
  }
} 