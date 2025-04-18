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
  final String location;

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
    required this.location,
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
      'location': location,
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
      location: json['location'],
    );
  }
} 