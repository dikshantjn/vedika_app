class BloodBankAgency {
  String agencyName;
  String gstNumber;
  String panNumber;
  String ownerName;
  String completeAddress;
  String nearbyLandmark;
  String emergencyContactNumber;
  String phoneNumber;
  String state;
  String city;
  String pincode;
  String email;
  String? website;
  String languageProficiency;
  List<String> deliveryOperationalAreas;
  int distanceLimitations;
  bool is24x7Operational;
  bool isAllDaysWorking;
  List<String> bloodServicesProvided;
  List<String> plateletServicesProvided;
  List<String> otherServicesProvided;
  bool acceptsOnlinePayment;

  List<Map<String, String>> agencyPhotos;
  List<Map<String, String>> licenseFiles;
  List<Map<String, String>> registrationCertificateFiles;
  String googleMapsLocation;

  // ✅ Newly added optional fields
  String? vendorId;
  String? generatedId;

  BloodBankAgency({
    required this.agencyName,
    required this.gstNumber,
    required this.panNumber,
    required this.ownerName,
    required this.completeAddress,
    required this.nearbyLandmark,
    required this.emergencyContactNumber,
    required this.phoneNumber,
    required this.state,
    required this.city,
    required this.pincode,
    required this.email,
    this.website,
    required this.languageProficiency,
    required this.deliveryOperationalAreas,
    required this.distanceLimitations,
    required this.is24x7Operational,
    required this.isAllDaysWorking,
    required this.bloodServicesProvided,
    required this.plateletServicesProvided,
    required this.otherServicesProvided,
    required this.acceptsOnlinePayment,
    required this.agencyPhotos,
    required this.licenseFiles,
    required this.registrationCertificateFiles,
    required this.googleMapsLocation,
    this.vendorId,         // ✅ optional
    this.generatedId,      // ✅ optional
  });

  Map<String, dynamic> toJson() {
    return {
      'agencyName': agencyName,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'ownerName': ownerName,
      'completeAddress': completeAddress,
      'nearbyLandmark': nearbyLandmark,
      'emergencyContactNumber': emergencyContactNumber,
      'phoneNumber': phoneNumber,
      'state': state,
      'city': city,
      'pincode': pincode,
      'email': email,
      'website': website,
      'languageProficiency': languageProficiency,
      'deliveryOperationalAreas': deliveryOperationalAreas,
      'distanceLimitations': distanceLimitations,
      'is24x7Operational': is24x7Operational,
      'isAllDaysWorking': isAllDaysWorking,
      'bloodServicesProvided': bloodServicesProvided,
      'plateletServicesProvided': plateletServicesProvided,
      'otherServicesProvided': otherServicesProvided,
      'acceptsOnlinePayment': acceptsOnlinePayment,
      'agencyPhotos': agencyPhotos,
      'licenseFiles': licenseFiles,
      'registrationCertificateFiles': registrationCertificateFiles,
      'googleMapsLocation': googleMapsLocation,
      'vendorId': vendorId,           // ✅ included in toJson
      'generatedId': generatedId,     // ✅ included in toJson
    };
  }

  factory BloodBankAgency.fromJson(Map<String, dynamic> json) {
    return BloodBankAgency(
      agencyName: json['agencyName'],
      gstNumber: json['gstNumber'],
      panNumber: json['panNumber'],
      ownerName: json['ownerName'],
      completeAddress: json['completeAddress'],
      nearbyLandmark: json['nearbyLandmark'],
      emergencyContactNumber: json['emergencyContactNumber'],
      phoneNumber: json['phoneNumber'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      email: json['email'],
      website: json['website'],
      languageProficiency: json['languageProficiency'],
      deliveryOperationalAreas: List<String>.from(json['deliveryOperationalAreas']),
      distanceLimitations: json['distanceLimitations'],
      is24x7Operational: json['is24x7Operational'],
      isAllDaysWorking: json['isAllDaysWorking'],
      bloodServicesProvided: List<String>.from(json['bloodServicesProvided']),
      plateletServicesProvided: List<String>.from(json['plateletServicesProvided']),
      otherServicesProvided: List<String>.from(json['otherServicesProvided']),
      acceptsOnlinePayment: json['acceptsOnlinePayment'],
      agencyPhotos: List<Map<String, String>>.from(
          json['agencyPhotos'].map((item) => Map<String, String>.from(item))),
      licenseFiles: List<Map<String, String>>.from(
          json['licenseFiles'].map((item) => Map<String, String>.from(item))),
      registrationCertificateFiles: List<Map<String, String>>.from(
          json['registrationCertificateFiles'].map((item) => Map<String, String>.from(item))),
      googleMapsLocation: json['googleMapsLocation'],
      vendorId: json['vendorId'],         // ✅ safe since it's nullable
      generatedId: json['generatedId'],   // ✅ safe since it's nullable
    );
  }
}
