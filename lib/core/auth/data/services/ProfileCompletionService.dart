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

      if (!isComplete) {
        final missingFields = getMissingFields(user, serviceType);
      }
      return isComplete;
    } catch (e, stackTrace) {
      print('Error checking profile completion: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  bool _checkAmbulanceProfile(UserModel user) {

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.emergencyContactNumber?.isNotEmpty == true;

    return isComplete;
  }

  bool _checkHospitalProfile(UserModel user) {

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.dateOfBirth != null &&
        user.bloodGroup?.isNotEmpty == true &&
        user.emergencyContactNumber?.isNotEmpty == true;

    return isComplete;
  }

  bool _checkBloodBankProfile(UserModel user) {

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.bloodGroup?.isNotEmpty == true &&
        user.dateOfBirth != null;

    return isComplete;
  }

  bool _checkLabTestProfile(UserModel user) {

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.dateOfBirth != null;

    return isComplete;
  }

  bool _checkMedicineDeliveryProfile(UserModel user) {

    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true;

    return isComplete;
  }

  bool _checkClinicProfile(UserModel user) {


    final isComplete = user.name?.isNotEmpty == true &&
        user.phoneNumber?.isNotEmpty == true &&
        user.location?.isNotEmpty == true &&
        user.dateOfBirth != null &&
        user.bloodGroup?.isNotEmpty == true;

    return isComplete;
  }

  Map<String, String> getMissingFields(UserModel user, ServiceType serviceType) {
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

    return missingFields;
  }
} 