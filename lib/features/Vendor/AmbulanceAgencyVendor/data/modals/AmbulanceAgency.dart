class AmbulanceAgency {
  final String agencyName;
  final String gstNumber;
  final String panNumber;
  final String ownerName;
  final String registrationNumber;
  final String address;
  final String landmark;
  final String contactNumber;
  final String email;
  final String website;
  final int numOfAmbulances;
  final bool driverKYC;
  final bool driverTrained;
  final List<String> ambulanceTypes;
  final bool gpsTrackingAvailable;
  final List<String> ambulanceEquipment;
  final List<Map<String, String>> trainingCertifications;
  final List<String> languageProficiency;
  final List<String> operationalAreas;
  final bool is24x7Available;
  final double distanceLimit;
  final bool isOnlinePaymentAvailable;
  final List<Map<String, String>> officePhotos;
  final String preciseLocation;
  final String vendorId;
  final String generatedId;
  final String driverLicense;
  final String state;
  final String city;
  final String pinCode;
  final bool isLive;

  AmbulanceAgency({
    required this.agencyName,
    required this.gstNumber,
    required this.panNumber,
    required this.ownerName,
    required this.registrationNumber,
    required this.address,
    required this.landmark,
    required this.contactNumber,
    required this.email,
    required this.website,
    required this.numOfAmbulances,
    required this.driverKYC,
    required this.driverTrained,
    required this.ambulanceTypes,
    required this.gpsTrackingAvailable,
    required this.ambulanceEquipment,
    required this.trainingCertifications,
    required this.languageProficiency,
    required this.operationalAreas,
    required this.is24x7Available,
    required this.distanceLimit,
    required this.isOnlinePaymentAvailable,
    required this.officePhotos,
    required this.preciseLocation,
    required this.vendorId,
    required this.generatedId,
    required this.driverLicense,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.isLive,
  });

  AmbulanceAgency copyWith({
    String? agencyName,
    String? gstNumber,
    String? panNumber,
    String? ownerName,
    String? registrationNumber,
    String? address,
    String? landmark,
    String? contactNumber,
    String? email,
    String? website,
    int? numOfAmbulances,
    bool? driverKYC,
    bool? driverTrained,
    List<String>? ambulanceTypes,
    bool? gpsTrackingAvailable,
    List<String>? ambulanceEquipment,
    List<Map<String, String>>? trainingCertifications,
    List<String>? languageProficiency,
    List<String>? operationalAreas,
    bool? is24x7Available,
    double? distanceLimit,
    bool? isOnlinePaymentAvailable,
    List<Map<String, String>>? officePhotos,
    String? preciseLocation,
    String? vendorId,
    String? generatedId,
    String? driverLicense,
    String? state,
    String? city,
    String? pinCode,
    bool? isLive,
  }) {
    return AmbulanceAgency(
      agencyName: agencyName ?? this.agencyName,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      ownerName: ownerName ?? this.ownerName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      numOfAmbulances: numOfAmbulances ?? this.numOfAmbulances,
      driverKYC: driverKYC ?? this.driverKYC,
      driverTrained: driverTrained ?? this.driverTrained,
      ambulanceTypes: ambulanceTypes ?? this.ambulanceTypes,
      gpsTrackingAvailable: gpsTrackingAvailable ?? this.gpsTrackingAvailable,
      ambulanceEquipment: ambulanceEquipment ?? this.ambulanceEquipment,
      trainingCertifications: trainingCertifications ?? this.trainingCertifications,
      languageProficiency: languageProficiency ?? this.languageProficiency,
      operationalAreas: operationalAreas ?? this.operationalAreas,
      is24x7Available: is24x7Available ?? this.is24x7Available,
      distanceLimit: distanceLimit ?? this.distanceLimit,
      isOnlinePaymentAvailable: isOnlinePaymentAvailable ?? this.isOnlinePaymentAvailable,
      officePhotos: officePhotos ?? this.officePhotos,
      preciseLocation: preciseLocation ?? this.preciseLocation,
      vendorId: vendorId ?? this.vendorId,
      generatedId: generatedId ?? this.generatedId,
      driverLicense: driverLicense ?? this.driverLicense,
      state: state ?? this.state,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      isLive: isLive ?? this.isLive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agencyName': agencyName,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'ownerName': ownerName,
      'registrationNumber': registrationNumber,
      'address': address,
      'landmark': landmark,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'numOfAmbulances': numOfAmbulances,
      'driverKYC': driverKYC,
      'driverTrained': driverTrained,
      'ambulanceTypes': ambulanceTypes,
      'gpsTrackingAvailable': gpsTrackingAvailable,
      'ambulanceEquipment': ambulanceEquipment,
      'trainingCertifications': trainingCertifications,
      'languageProficiency': languageProficiency,
      'operationalAreas': operationalAreas,
      'is24x7Available': is24x7Available,
      'distanceLimit': distanceLimit,
      'isOnlinePaymentAvailable': isOnlinePaymentAvailable,
      'officePhotos': officePhotos,
      'preciseLocation': preciseLocation,
      'vendorId': vendorId,
      'generatedId': generatedId,
      'driverLicense': driverLicense,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'isLive': isLive,
    };
  }

  factory AmbulanceAgency.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> _parseMediaList(dynamic list) {
      if (list is List) {
        return list.map<Map<String, String>>((item) {
          if (item is Map) {
            return {
              'name': item['name']?.toString() ?? '',
              'url': item['url']?.toString() ?? ''
            };
          }
          return {'name': '', 'url': ''};
        }).toList();
      }
      return [];
    }

    return AmbulanceAgency(
      agencyName: json['agencyName'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      ownerName: json['ownerName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      address: json['address'] ?? '',
      landmark: json['landmark'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      numOfAmbulances: json['numOfAmbulances'] ?? 0,
      driverKYC: json['driverKYC'] ?? false,
      driverTrained: json['driverTrained'] ?? false,
      ambulanceTypes: List<String>.from(json['ambulanceTypes'] ?? []),
      gpsTrackingAvailable: json['gpsTrackingAvailable'] ?? false,
      ambulanceEquipment: List<String>.from(json['ambulanceEquipment'] ?? []),
      trainingCertifications: _parseMediaList(json['trainingCertifications']),
      languageProficiency: List<String>.from(json['languageProficiency'] ?? []),
      operationalAreas: List<String>.from(json['operationalAreas'] ?? []),
      is24x7Available: json['is24x7Available'] ?? false,
      distanceLimit: (json['distanceLimit'] as num?)?.toDouble() ?? 0.0,
      isOnlinePaymentAvailable: json['isOnlinePaymentAvailable'] ?? false,
      officePhotos: _parseMediaList(json['officePhotos']),
      preciseLocation: json['preciseLocation'] ?? '',
      vendorId: json['vendorId'] ?? '',
      generatedId: json['generatedId'] ?? '',
      driverLicense: json['driverLicense'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      pinCode: json['pinCode'] ?? '',
      isLive: json['isLive'] ?? json['isActive'] ?? false, // Accepts either field
    );
  }
}

class MediaFileTypes {
  static const String officePhotos = 'officePhotos';
  static const String trainingCertifications = 'trainingCertifications';
}
