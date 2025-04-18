import 'dart:convert';

class HospitalProfile {
  final String? vendorId;
  final String? generatedId;
  final String name;
  final String gstNumber;
  final String panNumber;
  final String address;
  final String landmark;
  final String ownerName;
  final List<Map<String, String>> certifications;
  final List<Map<String, String>> licenses;
  final List<String> specialityTypes;
  final List<String> servicesOffered;
  final int bedsAvailable;
  final List<Map<String, dynamic>> doctors;
  final String workingTime;
  final String workingDays;
  final String contactNumber;
  final String email;
  final String? website;
  final bool hasLiftAccess;
  final bool hasParking;
  final bool providesAmbulanceService;
  final String about;
  final bool hasWheelchairAccess;
  final bool providesOnlineConsultancy;
  final String feesRange;
  final List<String> otherFacilities;
  final List<String> insuranceCompanies;
  final List<Map<String, String>> photos;
  final String state;
  final String city;
  final String pincode;
  final bool isActive;

  HospitalProfile({
    this.vendorId,
    this.generatedId,
    required this.name,
    required this.gstNumber,
    required this.panNumber,
    required this.address,
    required this.landmark,
    required this.ownerName,
    required this.certifications,
    required this.licenses,
    required this.specialityTypes,
    required this.servicesOffered,
    required this.bedsAvailable,
    required this.doctors,
    required this.workingTime,
    required this.workingDays,
    required this.contactNumber,
    required this.email,
    this.website,
    required this.hasLiftAccess,
    required this.hasParking,
    required this.providesAmbulanceService,
    required this.about,
    required this.hasWheelchairAccess,
    required this.providesOnlineConsultancy,
    required this.feesRange,
    required this.otherFacilities,
    required this.insuranceCompanies,
    required this.photos,
    required this.state,
    required this.city,
    required this.pincode,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'generatedId': generatedId,
      'name': name,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'address': address,
      'landmark': landmark,
      'ownerName': ownerName,
      'certifications': certifications,
      'licenses': licenses,
      'specialityTypes': specialityTypes,
      'servicesOffered': servicesOffered,
      'bedsAvailable': bedsAvailable,
      'doctors': doctors,
      'workingTime': workingTime,
      'workingDays': workingDays,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'hasLiftAccess': hasLiftAccess,
      'hasParking': hasParking,
      'providesAmbulanceService': providesAmbulanceService,
      'about': about,
      'hasWheelchairAccess': hasWheelchairAccess,
      'providesOnlineConsultancy': providesOnlineConsultancy,
      'feesRange': feesRange,
      'otherFacilities': otherFacilities,
      'insuranceCompanies': insuranceCompanies,
      'photos': photos,
      'state': state,
      'city': city,
      'pincode': pincode,
      'isActive': isActive,
    };
  }

  factory HospitalProfile.fromJson(Map<String, dynamic> json) {
    return HospitalProfile(
      vendorId: json['vendorId'],
      generatedId: json['generatedId'],
      name: json['name'],
      gstNumber: json['gstNumber'],
      panNumber: json['panNumber'],
      address: json['address'],
      landmark: json['landmark'],
      ownerName: json['ownerName'],
      certifications: List<Map<String, String>>.from(json['certifications']),
      licenses: List<Map<String, String>>.from(json['licenses']),
      specialityTypes: List<String>.from(json['specialityTypes']),
      servicesOffered: List<String>.from(json['servicesOffered']),
      bedsAvailable: json['bedsAvailable'],
      doctors: List<Map<String, dynamic>>.from(json['doctors']),
      workingTime: json['workingTime'],
      workingDays: json['workingDays'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      website: json['website'],
      hasLiftAccess: json['hasLiftAccess'],
      hasParking: json['hasParking'],
      providesAmbulanceService: json['providesAmbulanceService'],
      about: json['about'],
      hasWheelchairAccess: json['hasWheelchairAccess'],
      providesOnlineConsultancy: json['providesOnlineConsultancy'],
      feesRange: json['feesRange'],
      otherFacilities: List<String>.from(json['otherFacilities']),
      insuranceCompanies: List<String>.from(json['insuranceCompanies']),
      photos: List<Map<String, String>>.from(json['photos']),
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      isActive: json['isActive'] ?? false,
    );
  }

  HospitalProfile copyWith({
    String? vendorId,
    String? generatedId,
    String? name,
    String? gstNumber,
    String? panNumber,
    String? address,
    String? landmark,
    String? ownerName,
    List<Map<String, String>>? certifications,
    List<Map<String, String>>? licenses,
    List<String>? specialityTypes,
    List<String>? servicesOffered,
    int? bedsAvailable,
    List<Map<String, dynamic>>? doctors,
    String? workingTime,
    String? workingDays,
    String? contactNumber,
    String? email,
    String? website,
    bool? hasLiftAccess,
    bool? hasParking,
    bool? providesAmbulanceService,
    String? about,
    bool? hasWheelchairAccess,
    bool? providesOnlineConsultancy,
    String? feesRange,
    List<String>? otherFacilities,
    List<String>? insuranceCompanies,
    List<Map<String, String>>? photos,
    String? state,
    String? city,
    String? pincode,
    bool? isActive,
  }) {
    return HospitalProfile(
      vendorId: vendorId ?? this.vendorId,
      generatedId: generatedId ?? this.generatedId,
      name: name ?? this.name,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      ownerName: ownerName ?? this.ownerName,
      certifications: certifications ?? this.certifications,
      licenses: licenses ?? this.licenses,
      specialityTypes: specialityTypes ?? this.specialityTypes,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      bedsAvailable: bedsAvailable ?? this.bedsAvailable,
      doctors: doctors ?? this.doctors,
      workingTime: workingTime ?? this.workingTime,
      workingDays: workingDays ?? this.workingDays,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      hasLiftAccess: hasLiftAccess ?? this.hasLiftAccess,
      hasParking: hasParking ?? this.hasParking,
      providesAmbulanceService: providesAmbulanceService ?? this.providesAmbulanceService,
      about: about ?? this.about,
      hasWheelchairAccess: hasWheelchairAccess ?? this.hasWheelchairAccess,
      providesOnlineConsultancy: providesOnlineConsultancy ?? this.providesOnlineConsultancy,
      feesRange: feesRange ?? this.feesRange,
      otherFacilities: otherFacilities ?? this.otherFacilities,
      insuranceCompanies: insuranceCompanies ?? this.insuranceCompanies,
      photos: photos ?? this.photos,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      isActive: isActive ?? this.isActive,
    );
  }
} 