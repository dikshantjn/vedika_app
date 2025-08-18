import 'dart:convert';

class DoctorClinicProfile {
  final String? vendorId;
  final String? generatedId;
  final String doctorName;
  final String gender;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String profilePicture; // URL or base64
  final List<Map<String, String>> medicalLicenseFile; // Changed to list of maps with name and url
  final String licenseNumber;
  final List<String> educationalQualifications;
  final List<String> specializations;
  final int experienceYears;
  final List<String> languageProficiency;
  final bool hasTelemedicineExperience;
  final String consultationFeesRange;
  final List<Map<String, String>> consultationTimeSlots;
  final List<String> consultationDays;
  final List<String> consultationTypes; // Online, Offline, Chat
  final List<String> insurancePartners;
  final String address;
  final String state;
  final String city;
  final String pincode;
  final String nearbyLandmark;
  final String floor;
  final bool hasLiftAccess;
  final bool hasWheelchairAccess;
  final bool hasParking;
  final List<String> otherFacilities;
  final List<Map<String, String>> clinicPhotos;
  final String location; // Google Maps location as string

  DoctorClinicProfile({
    this.vendorId,
    this.generatedId,
    required this.doctorName,
    required this.gender,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    required this.profilePicture,
    required this.medicalLicenseFile,
    required this.licenseNumber,
    required this.educationalQualifications,
    required this.specializations,
    required this.experienceYears,
    required this.languageProficiency,
    required this.hasTelemedicineExperience,
    required this.consultationFeesRange,
    required this.consultationTimeSlots,
    required this.consultationDays,
    required this.consultationTypes,
    required this.insurancePartners,
    required this.address,
    required this.state,
    required this.city,
    required this.pincode,
    required this.nearbyLandmark,
    required this.floor,
    required this.hasLiftAccess,
    required this.hasWheelchairAccess,
    required this.hasParking,
    required this.otherFacilities,
    required this.clinicPhotos,
    required this.location,
  });

  DoctorClinicProfile copyWith({
    String? doctorName,
    String? gender,
    String? email,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
    String? profilePicture,
    List<Map<String, String>>? medicalLicenseFile,
    String? licenseNumber,
    List<String>? educationalQualifications,
    List<String>? specializations,
    int? experienceYears,
    List<String>? languageProficiency,
    bool? hasTelemedicineExperience,
    String? consultationFeesRange,
    List<Map<String, String>>? consultationTimeSlots,
    List<String>? consultationDays,
    List<String>? consultationTypes,
    List<String>? insurancePartners,
    String? address,
    String? state,
    String? city,
    String? pincode,
    String? nearbyLandmark,
    String? floor,
    bool? hasLiftAccess,
    bool? hasWheelchairAccess,
    bool? hasParking,
    List<String>? otherFacilities,
    List<Map<String, String>>? clinicPhotos,
    String? location,
  }) {
    return DoctorClinicProfile(
      vendorId: vendorId,
      generatedId: generatedId,
      doctorName: doctorName ?? this.doctorName,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      medicalLicenseFile: medicalLicenseFile ?? this.medicalLicenseFile,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      educationalQualifications: educationalQualifications ?? this.educationalQualifications,
      specializations: specializations ?? this.specializations,
      experienceYears: experienceYears ?? this.experienceYears,
      languageProficiency: languageProficiency ?? this.languageProficiency,
      hasTelemedicineExperience: hasTelemedicineExperience ?? this.hasTelemedicineExperience,
      consultationFeesRange: consultationFeesRange ?? this.consultationFeesRange,
      consultationTimeSlots: consultationTimeSlots ?? this.consultationTimeSlots,
      consultationDays: consultationDays ?? this.consultationDays,
      consultationTypes: consultationTypes ?? this.consultationTypes,
      insurancePartners: insurancePartners ?? this.insurancePartners,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      nearbyLandmark: nearbyLandmark ?? this.nearbyLandmark,
      floor: floor ?? this.floor,
      hasLiftAccess: hasLiftAccess ?? this.hasLiftAccess,
      hasWheelchairAccess: hasWheelchairAccess ?? this.hasWheelchairAccess,
      hasParking: hasParking ?? this.hasParking,
      otherFacilities: otherFacilities ?? this.otherFacilities,
      clinicPhotos: clinicPhotos ?? this.clinicPhotos,
      location: location ?? this.location,
    );
  }

  factory DoctorClinicProfile.fromJson(Map<String, dynamic> json) {
    try {
      // Parse medical license files
      List<Map<String, String>> parseMedicalLicenseFile(dynamic licenses) {
        if (licenses == null) return [];
        
        try {
          if (licenses is List) {
            return List<Map<String, String>>.from(licenses.map((license) {
              if (license is Map) {
                // Convert all values to strings to ensure type safety
                return {
                  'url': license['url']?.toString() ?? '',
                  'name': license['name']?.toString() ?? 'License',
                };
              }
              return {'url': license.toString(), 'name': 'License'};
            }));
          }
          
          if (licenses is String) {
            if (licenses.isNotEmpty) {
              // Try parsing as JSON string
              if (licenses.startsWith('[') && licenses.endsWith(']')) {
                try {
                  final List<dynamic> parsed = jsonDecode(licenses);
                  return List<Map<String, String>>.from(parsed.map((license) {
                    if (license is Map) {
                      return {
                        'url': license['url']?.toString() ?? '',
                        'name': license['name']?.toString() ?? 'License',
                      };
                    }
                    return {'url': license.toString(), 'name': 'License'};
                  }));
                } catch (e) {
                  print('Error parsing medical license as JSON: $e');
                }
              }
              
              // If it's a single URL
              return [{'url': licenses, 'name': 'License'}];
            }
          }
        } catch (e) {
          print('Error parsing medical license files: $e');
        }
        
        return [];
      }
      
      // Handle consultation time slots with special parsing
      List<Map<String, String>> parseConsultationTimeSlots(dynamic slots) {
        if (slots == null) return [];
        
        if (slots is List) {
          return List<Map<String, String>>.from(slots.map((slot) {
            if (slot is Map) {
              // Check for the new format with day, startTime, endTime
              if (slot.containsKey('day') && slot.containsKey('startTime') && slot.containsKey('endTime')) {
                return {
                  'day': slot['day']?.toString() ?? '',
                  'startTime': slot['startTime']?.toString() ?? '',
                  'endTime': slot['endTime']?.toString() ?? '',
                };
              }
              // Old format with start, end
              return {
                'start': slot['start']?.toString() ?? '',
                'end': slot['end']?.toString() ?? '',
              };
            }
            return {'start': '', 'end': ''};
          }));
        }
        
        // If it's a string, try to parse it
        if (slots is String) {
          try {
            if (slots.isNotEmpty) {
              // Handle case if it's a JSON string
              if (slots.startsWith('[') && slots.endsWith(']')) {
                final List<dynamic> parsed = jsonDecode(slots);
                return List<Map<String, String>>.from(parsed.map((slot) {
                  // Check for the new format
                  if (slot is Map && slot.containsKey('day') && slot.containsKey('startTime') && slot.containsKey('endTime')) {
                    return {
                      'day': slot['day']?.toString() ?? '',
                      'startTime': slot['startTime']?.toString() ?? '',
                      'endTime': slot['endTime']?.toString() ?? '',
                    };
                  }
                  // Old format
                  return {
                    'start': slot['start']?.toString() ?? '',
                    'end': slot['end']?.toString() ?? '',
                  };
                }));
              }
              
              // Split by comma if it's a simple string
              return slots.split(',').map((slot) => {
                'start': slot.trim(),
                'end': (int.tryParse(slot.split(':')[0].trim()) ?? 0 + 1).toString() + ':00',
              }).toList();
            }
          } catch (e) {
            print('Error parsing consultation time slots: $e');
          }
        }
        return [];
      }
      
      // Handle clinic photos with special parsing
      List<Map<String, String>> parseClinicPhotos(dynamic photos) {
        if (photos == null) return [];
        
        if (photos is List) {
          return List<Map<String, String>>.from(photos.map((photo) {
            if (photo is Map) {
              return {
                'url': photo['url']?.toString() ?? '',
                'caption': photo['caption']?.toString() ?? 'Clinic Photo',
              };
            } else if (photo is String) {
              return {'url': photo, 'caption': 'Clinic Photo'};
            }
            return {'url': '', 'caption': ''};
          }));
        }
        
        // If it's a string, try to parse it
        if (photos is String) {
          try {
            if (photos.isNotEmpty) {
              // Try parsing as JSON
              if (photos.startsWith('[') && photos.endsWith(']')) {
                final List<dynamic> parsed = jsonDecode(photos);
                return List<Map<String, String>>.from(parsed.map((photo) {
                  if (photo is Map) {
                    return {
                      'url': photo['url']?.toString() ?? '',
                      'caption': photo['caption']?.toString() ?? 'Clinic Photo',
                    };
                  } else if (photo is String) {
                    return {'url': photo, 'caption': 'Clinic Photo'};
                  }
                  return {'url': '', 'caption': ''};
                }));
              }
              
              // If it's a single URL
              return [{'url': photos, 'caption': 'Clinic Photo'}];
            }
          } catch (e) {
            print('Error parsing clinic photos: $e');
          }
        }
        return [];
      }
      
      // Handle consultation types with special parsing
      List<String> parseConsultationTypes(dynamic types) {
        if (types == null) return ['Offline']; // Default to offline
        
        if (types is List) {
          return List<String>.from(types.map((t) => t.toString()));
        }
        
        if (types is String) {
          if (types.isNotEmpty) {
            // Try parsing as JSON
            if (types.startsWith('[') && types.endsWith(']')) {
              try {
                final List<dynamic> parsed = jsonDecode(types);
                return List<String>.from(parsed.map((t) => t.toString()));
              } catch (e) {
                print('Error parsing consultation types as JSON: $e');
              }
            }
            
            // Split by comma if it's a simple string
            return types.split(',').map((t) => t.trim()).toList();
          }
        }
        
        return ['Offline']; // Default to offline
      }
      
      return DoctorClinicProfile(
        vendorId: json['vendorId']?.toString() ?? json['id']?.toString(),
        generatedId: json['generatedId']?.toString(),
        doctorName: json['doctorName']?.toString() ?? json['name']?.toString() ?? 'Unknown Doctor',
        gender: json['gender']?.toString() ?? 'Not Specified',
        email: json['email']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        confirmPassword: json['confirmPassword']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
        profilePicture: json['profilePicture']?.toString() ?? json['photo']?.toString() ?? '',
        medicalLicenseFile: parseMedicalLicenseFile(json['medicalLicenseFile']),
        licenseNumber: json['licenseNumber']?.toString() ?? '',
        educationalQualifications: json['educationalQualifications'] is List 
            ? List<String>.from(json['educationalQualifications'] ?? [])
            : json['educationalQualifications']?.toString()?.split(',') ?? [],
        specializations: json['specializations'] is List 
            ? List<String>.from(json['specializations'] ?? [])
            : json['specializations']?.toString()?.split(',') ?? [],
        experienceYears: json['experienceYears'] is int 
            ? json['experienceYears'] 
            : int.tryParse(json['experienceYears']?.toString() ?? '0') ?? 0,
        languageProficiency: json['languageProficiency'] is List 
            ? List<String>.from(json['languageProficiency'] ?? [])
            : json['languageProficiency']?.toString()?.split(',') ?? [],
        hasTelemedicineExperience: json['hasTelemedicineExperience'] is bool 
            ? json['hasTelemedicineExperience'] 
            : json['hasTelemedicineExperience']?.toString()?.toLowerCase() == 'true' || false,
        consultationFeesRange: json['consultationFeesRange']?.toString() ?? '0',
        consultationTimeSlots: parseConsultationTimeSlots(json['consultationTimeSlots']),
        consultationDays: json['consultationDays'] is List 
            ? List<String>.from(json['consultationDays'] ?? [])
            : json['consultationDays']?.toString()?.split(',') ?? [],
        consultationTypes: parseConsultationTypes(json['consultationTypes']),
        insurancePartners: json['insurancePartners'] is List 
            ? List<String>.from(json['insurancePartners'] ?? []) 
            : json['insurancePartners']?.toString()?.split(',') ?? [],
        address: json['address']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        pincode: json['pincode']?.toString() ?? '',
        nearbyLandmark: json['nearbyLandmark']?.toString() ?? '',
        floor: json['floor']?.toString() ?? '',
        hasLiftAccess: json['hasLiftAccess'] is bool 
            ? json['hasLiftAccess'] 
            : json['hasLiftAccess']?.toString()?.toLowerCase() == 'true' || false,
        hasWheelchairAccess: json['hasWheelchairAccess'] is bool 
            ? json['hasWheelchairAccess'] 
            : json['hasWheelchairAccess']?.toString()?.toLowerCase() == 'true' || false,
        hasParking: json['hasParking'] is bool 
            ? json['hasParking'] 
            : json['hasParking']?.toString()?.toLowerCase() == 'true' || false,
        otherFacilities: json['otherFacilities'] is List 
            ? List<String>.from(json['otherFacilities'] ?? [])
            : json['otherFacilities']?.toString()?.split(',') ?? [],
        clinicPhotos: parseClinicPhotos(json['clinicPhotos']),
        location: json['location']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ Error parsing DoctorClinicProfile: $e');
      // Return a minimal valid object instead of throwing
      return DoctorClinicProfile(
        doctorName: 'Error parsing profile',
        gender: '',
        email: '',
        password: '',
        confirmPassword: '',
        phoneNumber: '',
        profilePicture: '',
        medicalLicenseFile: [],
        licenseNumber: '',
        educationalQualifications: [],
        specializations: [],
        experienceYears: 0,
        languageProficiency: [],
        hasTelemedicineExperience: false,
        consultationFeesRange: '',
        consultationTimeSlots: [],
        consultationDays: [],
        consultationTypes: ['Offline'],
        insurancePartners: [],
        address: '',
        state: '',
        city: '',
        pincode: '',
        nearbyLandmark: '',
        floor: '',
        hasLiftAccess: false,
        hasWheelchairAccess: false,
        hasParking: false,
        otherFacilities: [],
        clinicPhotos: [],
        location: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'generatedId': generatedId,
      'doctorName': doctorName,
      'gender': gender,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'medicalLicenseFile': medicalLicenseFile,
      'licenseNumber': licenseNumber,
      'educationalQualifications': educationalQualifications,
      'specializations': specializations,
      'experienceYears': experienceYears,
      'languageProficiency': languageProficiency,
      'hasTelemedicineExperience': hasTelemedicineExperience,
      'consultationFeesRange': consultationFeesRange,
      'consultationTimeSlots': consultationTimeSlots,
      'consultationDays': consultationDays,
      'consultationTypes': consultationTypes,
      'insurancePartners': insurancePartners,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pincode,
      'nearbyLandmark': nearbyLandmark,
      'floor': floor,
      'hasLiftAccess': hasLiftAccess,
      'hasWheelchairAccess': hasWheelchairAccess,
      'hasParking': hasParking,
      'otherFacilities': otherFacilities,
      'clinicPhotos': clinicPhotos,
      'location': location,
    };
  }
} 