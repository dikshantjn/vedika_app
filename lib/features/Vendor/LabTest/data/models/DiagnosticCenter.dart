class DiagnosticCenter {
  String name;
  String gstNumber;
  String panNumber;
  String ownerName;
  Map<String, String> regulatoryComplianceUrl; // Changed to Map for name and URL
  Map<String, String> qualityAssuranceUrl; // Changed to Map for name and URL
  String sampleCollectionMethod; // At Center / At Home / Both
  List<String> testTypes; // Types of tests/services offered
  String businessTimings;
  List<String> businessDays; // List of days the business is open
  String homeCollectionGeoLimit; // Geographical limit for home collection
  bool emergencyHandlingFastTrack; // Whether fast-track services are offered
  String address;
  String state; // Added state field
  String city; // Added city field
  String pincode; // Added pincode field
  String nearbyLandmark;
  String floor;
  bool parkingAvailable;
  bool wheelchairAccess;
  bool liftAccess;
  bool ambulanceServiceAvailable;
  String mainContactNumber;
  String emergencyContactNumber;
  String email;
  String website;
  List<String> languagesSpoken; // Languages spoken by staff
  String centerPhotosUrl; // URL for uploaded photos
  String googleMapsLocationUrl; // URL for Google Maps precise location
  String? vendorId; // Nullable vendor ID
  String? generatedId; // Nullable generated ID
  String password; // Password for registration
  List<Map<String, String>> filesAndImages; // For handling file/image uploads
  String location; // For precise location string (e.g., coordinates or address)

  DiagnosticCenter({
    required this.name,
    required this.gstNumber,
    required this.panNumber,
    required this.ownerName,
    required this.regulatoryComplianceUrl,
    required this.qualityAssuranceUrl,
    required this.sampleCollectionMethod,
    required this.testTypes,
    required this.businessTimings,
    required this.businessDays,
    required this.homeCollectionGeoLimit,
    required this.emergencyHandlingFastTrack,
    required this.address,
    required this.state,
    required this.city,
    required this.pincode,
    required this.nearbyLandmark,
    required this.floor,
    required this.parkingAvailable,
    required this.wheelchairAccess,
    required this.liftAccess,
    required this.ambulanceServiceAvailable,
    required this.mainContactNumber,
    required this.emergencyContactNumber,
    required this.email,
    required this.website,
    required this.languagesSpoken,
    required this.centerPhotosUrl,
    required this.googleMapsLocationUrl,
    this.vendorId,
    this.generatedId,
    required this.password,
    required this.filesAndImages,
    required this.location,
  });

  // Add toJson method for API calls
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'ownerName': ownerName,
      'regulatoryComplianceUrl': regulatoryComplianceUrl,
      'qualityAssuranceUrl': qualityAssuranceUrl,
      'sampleCollectionMethod': sampleCollectionMethod,
      'testTypes': testTypes,
      'businessTimings': businessTimings,
      'businessDays': businessDays,
      'homeCollectionGeoLimit': homeCollectionGeoLimit,
      'emergencyHandlingFastTrack': emergencyHandlingFastTrack,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pincode,
      'nearbyLandmark': nearbyLandmark,
      'floor': floor,
      'parkingAvailable': parkingAvailable,
      'wheelchairAccess': wheelchairAccess,
      'liftAccess': liftAccess,
      'ambulanceServiceAvailable': ambulanceServiceAvailable,
      'mainContactNumber': mainContactNumber,
      'emergencyContactNumber': emergencyContactNumber,
      'email': email,
      'website': website,
      'languagesSpoken': languagesSpoken,
      'centerPhotosUrl': centerPhotosUrl,
      'googleMapsLocationUrl': googleMapsLocationUrl,
      'vendorId': vendorId,
      'generatedId': generatedId,
      'password': password,
      'filesAndImages': filesAndImages,
      'location': location,
    };
  }

  // Add fromJson factory constructor
  factory DiagnosticCenter.fromJson(Map<String, dynamic> json) {
    return DiagnosticCenter(
      name: json['name'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      ownerName: json['ownerName'] ?? '',
      regulatoryComplianceUrl: Map<String, String>.from(json['regulatoryComplianceUrl'] ?? {}),
      qualityAssuranceUrl: Map<String, String>.from(json['qualityAssuranceUrl'] ?? {}),
      sampleCollectionMethod: json['sampleCollectionMethod'] ?? '',
      testTypes: List<String>.from(json['testTypes'] ?? []),
      businessTimings: json['businessTimings'] ?? '',
      businessDays: List<String>.from(json['businessDays'] ?? []),
      homeCollectionGeoLimit: json['homeCollectionGeoLimit'] ?? '',
      emergencyHandlingFastTrack: json['emergencyHandlingFastTrack'] ?? false,
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      nearbyLandmark: json['nearbyLandmark'] ?? '',
      floor: json['floor'] ?? '',
      parkingAvailable: json['parkingAvailable'] ?? false,
      wheelchairAccess: json['wheelchairAccess'] ?? false,
      liftAccess: json['liftAccess'] ?? false,
      ambulanceServiceAvailable: json['ambulanceServiceAvailable'] ?? false,
      mainContactNumber: json['mainContactNumber'] ?? '',
      emergencyContactNumber: json['emergencyContactNumber'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      languagesSpoken: List<String>.from(json['languagesSpoken'] ?? []),
      centerPhotosUrl: json['centerPhotosUrl'] ?? '',
      googleMapsLocationUrl: json['googleMapsLocationUrl'] ?? '',
      vendorId: json['vendorId'],
      generatedId: json['generatedId'],
      password: json['password'] ?? '',
      filesAndImages: List<Map<String, String>>.from(json['filesAndImages'] ?? []),
      location: json['location'] ?? '',
    );
  }

  // Add copyWith method for immutable updates
  DiagnosticCenter copyWith({
    String? name,
    String? gstNumber,
    String? panNumber,
    String? ownerName,
    Map<String, String>? regulatoryComplianceUrl,
    Map<String, String>? qualityAssuranceUrl,
    String? sampleCollectionMethod,
    List<String>? testTypes,
    String? businessTimings,
    List<String>? businessDays,
    String? homeCollectionGeoLimit,
    bool? emergencyHandlingFastTrack,
    String? address,
    String? state,
    String? city,
    String? pincode,
    String? nearbyLandmark,
    String? floor,
    bool? parkingAvailable,
    bool? wheelchairAccess,
    bool? liftAccess,
    bool? ambulanceServiceAvailable,
    String? mainContactNumber,
    String? emergencyContactNumber,
    String? email,
    String? website,
    List<String>? languagesSpoken,
    String? centerPhotosUrl,
    String? googleMapsLocationUrl,
    String? vendorId,
    String? generatedId,
    String? password,
    List<Map<String, String>>? filesAndImages,
    String? location,
  }) {
    return DiagnosticCenter(
      name: name ?? this.name,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      ownerName: ownerName ?? this.ownerName,
      regulatoryComplianceUrl: regulatoryComplianceUrl ?? this.regulatoryComplianceUrl,
      qualityAssuranceUrl: qualityAssuranceUrl ?? this.qualityAssuranceUrl,
      sampleCollectionMethod: sampleCollectionMethod ?? this.sampleCollectionMethod,
      testTypes: testTypes ?? this.testTypes,
      businessTimings: businessTimings ?? this.businessTimings,
      businessDays: businessDays ?? this.businessDays,
      homeCollectionGeoLimit: homeCollectionGeoLimit ?? this.homeCollectionGeoLimit,
      emergencyHandlingFastTrack: emergencyHandlingFastTrack ?? this.emergencyHandlingFastTrack,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      nearbyLandmark: nearbyLandmark ?? this.nearbyLandmark,
      floor: floor ?? this.floor,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      wheelchairAccess: wheelchairAccess ?? this.wheelchairAccess,
      liftAccess: liftAccess ?? this.liftAccess,
      ambulanceServiceAvailable: ambulanceServiceAvailable ?? this.ambulanceServiceAvailable,
      mainContactNumber: mainContactNumber ?? this.mainContactNumber,
      emergencyContactNumber: emergencyContactNumber ?? this.emergencyContactNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      centerPhotosUrl: centerPhotosUrl ?? this.centerPhotosUrl,
      googleMapsLocationUrl: googleMapsLocationUrl ?? this.googleMapsLocationUrl,
      vendorId: vendorId ?? this.vendorId,
      generatedId: generatedId ?? this.generatedId,
      password: password ?? this.password,
      filesAndImages: filesAndImages ?? this.filesAndImages,
      location: location ?? this.location,
    );
  }

// Add methods for validation, file upload, or other operations if necessary
}
