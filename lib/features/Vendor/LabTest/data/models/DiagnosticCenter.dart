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
    try {
      // Print the entire JSON for debugging
      print('Parsing DiagnosticCenter from JSON: $json');
      
      // Helper function to safely convert to List<String>
      List<String> safeStringList(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((item) => item.toString()).toList();
        }
        return [];
      }
      
      // Helper function to safely convert to Map<String, String>
      Map<String, String> safeStringMap(dynamic value) {
        if (value == null) return {};
        if (value is Map) {
          Map<String, String> result = {};
          value.forEach((key, val) {
            result[key.toString()] = val.toString();
          });
          return result;
        }
        return {};
      }
      
      // Helper function for List<Map<String, String>>
      List<Map<String, String>> safeMapList(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((item) {
            if (item is Map) {
              Map<String, String> result = {};
              item.forEach((key, val) {
                result[key.toString()] = val.toString();
              });
              return result;
            }
            return <String, String>{};
          }).toList();
        }
        return [];
      }
      
      final center = DiagnosticCenter(
        name: json['name']?.toString() ?? '',
        gstNumber: json['gstNumber']?.toString() ?? '',
        panNumber: json['panNumber']?.toString() ?? '',
        ownerName: json['ownerName']?.toString() ?? '',
        regulatoryComplianceUrl: safeStringMap(json['regulatoryComplianceUrl']),
        qualityAssuranceUrl: safeStringMap(json['qualityAssuranceUrl']),
        sampleCollectionMethod: json['sampleCollectionMethod']?.toString() ?? '',
        testTypes: safeStringList(json['testTypes']),
        businessTimings: json['businessTimings']?.toString() ?? '',
        businessDays: safeStringList(json['businessDays']),
        homeCollectionGeoLimit: json['homeCollectionGeoLimit']?.toString() ?? '',
        emergencyHandlingFastTrack: json['emergencyHandlingFastTrack'] == true,
        address: json['address']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        pincode: json['pincode']?.toString() ?? '',
        nearbyLandmark: json['nearbyLandmark']?.toString() ?? '',
        floor: json['floor']?.toString() ?? '',
        parkingAvailable: json['parkingAvailable'] == true,
        wheelchairAccess: json['wheelchairAccess'] == true,
        liftAccess: json['liftAccess'] == true,
        ambulanceServiceAvailable: json['ambulanceServiceAvailable'] == true,
        mainContactNumber: json['mainContactNumber']?.toString() ?? '',
        emergencyContactNumber: json['emergencyContactNumber']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        website: json['website']?.toString() ?? '',
        languagesSpoken: safeStringList(json['languagesSpoken']),
        centerPhotosUrl: json['centerPhotosUrl']?.toString() ?? '',
        googleMapsLocationUrl: json['googleMapsLocationUrl']?.toString() ?? '',
        vendorId: json['vendorId']?.toString(),
        generatedId: json['generatedId']?.toString(),
        password: json['password']?.toString() ?? '',
        filesAndImages: safeMapList(json['filesAndImages']),
        location: json['location']?.toString() ?? '',
      );
      
      print('Successfully parsed DiagnosticCenter: ${center.name}');
      return center;
    } catch (e, stackTrace) {
      print('Error parsing DiagnosticCenter: $e');
      print('Stack trace: $stackTrace');
      print('Original JSON: $json');
      
      // Create a default object rather than crashing
      return DiagnosticCenter(
        name: '',
        gstNumber: '',
        panNumber: '',
        ownerName: '',
        regulatoryComplianceUrl: {},
        qualityAssuranceUrl: {},
        sampleCollectionMethod: '',
        testTypes: [],
        businessTimings: '',
        businessDays: [],
        homeCollectionGeoLimit: '',
        emergencyHandlingFastTrack: false,
        address: '',
        state: '',
        city: '',
        pincode: '',
        nearbyLandmark: '',
        floor: '',
        parkingAvailable: false,
        wheelchairAccess: false,
        liftAccess: false,
        ambulanceServiceAvailable: false,
        mainContactNumber: '',
        emergencyContactNumber: '',
        email: '',
        website: '',
        languagesSpoken: [],
        centerPhotosUrl: '',
        googleMapsLocationUrl: '',
        password: '',
        filesAndImages: [],
        location: '',
      );
    }
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
