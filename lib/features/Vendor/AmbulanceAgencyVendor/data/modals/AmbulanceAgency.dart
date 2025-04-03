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
  final List<String> trainingCertifications;
  final List<String> languageProficiency;
  final List<String> operationalAreas;
  final bool is24x7Available;
  final double distanceLimit;
  final bool isOnlinePaymentAvailable;
  final String officePhotos;
  final String preciseLocation;
  final String vendorId;
  final String generatedId;

  // Add this field
  final String driverLicense; // New field for Driver License

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
    required this.driverLicense, // Initialize the driverLicense field
  });

  // CopyWith method to allow updating of fields easily
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
    List<String>? trainingCertifications,
    List<String>? languageProficiency,
    List<String>? operationalAreas,
    bool? is24x7Available,
    double? distanceLimit,
    bool? isOnlinePaymentAvailable,
    String? officePhotos,
    String? preciseLocation,
    String? vendorId,
    String? generatedId,
    String? driverLicense, // Add this field to copyWith
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
      driverLicense: driverLicense ?? this.driverLicense, // Handle driverLicense
    );
  }
}
