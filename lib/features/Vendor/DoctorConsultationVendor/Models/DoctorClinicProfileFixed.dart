import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class DoctorClinicProfileFixed {
  static DoctorClinicProfile fromJson(Map<String, dynamic> json) {
    // Handle problematic fields by forcing type conversion

    // Handle medicalLicenseFile
    List<Map<String, String>> convertedMedicalLicenseFile = [];
    if (json['medicalLicenseFile'] is List) {
      final List rawList = json['medicalLicenseFile'];
      for (var item in rawList) {
        if (item is Map) {
          Map<String, String> stringMap = {};
          item.forEach((key, value) {
            stringMap[key.toString()] = value.toString();
          });
          convertedMedicalLicenseFile.add(stringMap);
        }
      }
    } else if (json['medicalLicenseFile'] != null && json['medicalLicenseFile'] != '') {
      convertedMedicalLicenseFile = [{'name': 'License', 'url': json['medicalLicenseFile'].toString()}];
    }

    // Handle consultationTimeSlots
    List<Map<String, String>> convertedTimeSlots = [];
    if (json['consultationTimeSlots'] is List) {
      final List rawList = json['consultationTimeSlots'];
      for (var item in rawList) {
        if (item is Map) {
          Map<String, String> stringMap = {};
          // Handle the API format with 'start' and 'end' keys
          if (item.containsKey('start') && item.containsKey('end')) {
            stringMap['startTime'] = item['start'].toString();
            stringMap['endTime'] = item['end'].toString();
            stringMap['day'] = item['day']?.toString() ?? 'Monday'; // Default to Monday if day is not provided
          } else if (item.containsKey('startTime') && item.containsKey('endTime')) {
            // Handle the existing format if it's already in the right structure
            item.forEach((key, value) {
              stringMap[key.toString()] = value.toString();
            });
          } else {
            // If keys don't match expected patterns, try to convert all keys/values to strings
            item.forEach((key, value) {
              stringMap[key.toString()] = value.toString();
            });
          }
          convertedTimeSlots.add(stringMap);
        }
      }
    }

    // Handle clinicPhotos
    List<Map<String, String>> convertedClinicPhotos = [];
    if (json['clinicPhotos'] is List) {
      final List rawList = json['clinicPhotos'];
      for (var item in rawList) {
        if (item is Map) {
          Map<String, String> stringMap = {};
          item.forEach((key, value) {
            stringMap[key.toString()] = value.toString();
          });
          convertedClinicPhotos.add(stringMap);
        }
      }
    }

    // Handle string lists
    List<String> getStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Create DoctorClinicProfile with converted values
    return DoctorClinicProfile(
      vendorId: json['vendorId'],
      generatedId: json['generatedId'],
      doctorName: json['doctorName']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      confirmPassword: json['confirmPassword']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString() ?? '',
      medicalLicenseFile: convertedMedicalLicenseFile,
      licenseNumber: json['licenseNumber']?.toString() ?? '',
      educationalQualifications: getStringList(json['educationalQualifications']),
      specializations: getStringList(json['specializations']),
      experienceYears: json['experienceYears'] is int 
          ? json['experienceYears'] 
          : (json['experienceYears'] != null 
              ? int.tryParse(json['experienceYears'].toString()) ?? 0 
              : 0),
      languageProficiency: getStringList(json['languageProficiency']),
      hasTelemedicineExperience: json['hasTelemedicineExperience'] is bool 
          ? json['hasTelemedicineExperience'] 
          : json['hasTelemedicineExperience']?.toString() == 'true',
      consultationFeesRange: json['consultationFeesRange']?.toString() ?? '',
      consultationTimeSlots: convertedTimeSlots,
      consultationDays: getStringList(json['consultationDays']),
      consultationTypes: getStringList(json['consultationTypes']),
      insurancePartners: getStringList(json['insurancePartners']),
      address: json['address']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      nearbyLandmark: json['nearbyLandmark']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      hasLiftAccess: json['hasLiftAccess'] is bool 
          ? json['hasLiftAccess'] 
          : json['hasLiftAccess']?.toString() == 'true',
      hasWheelchairAccess: json['hasWheelchairAccess'] is bool 
          ? json['hasWheelchairAccess'] 
          : json['hasWheelchairAccess']?.toString() == 'true',
      hasParking: json['hasParking'] is bool 
          ? json['hasParking'] 
          : json['hasParking']?.toString() == 'true',
      otherFacilities: getStringList(json['otherFacilities']),
      clinicPhotos: convertedClinicPhotos,
      location: json['location']?.toString() ?? '',
    );
  }
} 