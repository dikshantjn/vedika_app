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
  final List<Map<String, String>> officePhotos; // Updated to store name and URL
  final String preciseLocation;
  final String vendorId;
  final String generatedId;
  final String driverLicense;
  final String state;
  final String city;
  final String pinCode;
  final bool isLive; // Added isLive to track agency's online/offline status

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
    required this.officePhotos, // Now stores a list of maps
    required this.preciseLocation,
    required this.vendorId,
    required this.generatedId,
    required this.driverLicense,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.isLive, // Ensure isLive is initialized
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
    bool? isLive, // Option to update the isLive status
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
      isLive: isLive ?? this.isLive, // Update isLive status
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
      'isLive': isLive, // Add isLive to JSON
    };
  }
}
