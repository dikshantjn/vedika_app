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
    return DoctorClinicProfile(
      vendorId: json['vendorId'],
      generatedId: json['generatedId'],
      doctorName: json['doctorName'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      medicalLicenseFile: json['medicalLicenseFile'] is List 
          ? List<Map<String, String>>.from(json['medicalLicenseFile'] ?? [])
          : json['medicalLicenseFile'] != null && json['medicalLicenseFile'] != '' 
              ? [{'name': 'License', 'url': json['medicalLicenseFile']}] 
              : [],
      licenseNumber: json['licenseNumber'] ?? '',
      educationalQualifications: List<String>.from(json['educationalQualifications'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      experienceYears: json['experienceYears'] ?? 0,
      languageProficiency: List<String>.from(json['languageProficiency'] ?? []),
      hasTelemedicineExperience: json['hasTelemedicineExperience'] ?? false,
      consultationFeesRange: json['consultationFeesRange'] ?? '',
      consultationTimeSlots: List<Map<String, String>>.from(json['consultationTimeSlots'] ?? []),
      consultationDays: List<String>.from(json['consultationDays'] ?? []),
      consultationTypes: List<String>.from(json['consultationTypes'] ?? []),
      insurancePartners: List<String>.from(json['insurancePartners'] ?? []),
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      nearbyLandmark: json['nearbyLandmark'] ?? '',
      floor: json['floor'] ?? '',
      hasLiftAccess: json['hasLiftAccess'] ?? false,
      hasWheelchairAccess: json['hasWheelchairAccess'] ?? false,
      hasParking: json['hasParking'] ?? false,
      otherFacilities: List<String>.from(json['otherFacilities'] ?? []),
      clinicPhotos: List<Map<String, String>>.from(json['clinicPhotos'] ?? []),
      location: json['location'] ?? '',
    );
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