class VendorMedicalStoreProfile {
  final String? vendorId;
  final String? generatedId;
  final String name;
  final String address;
  final String landmark;
  final String state;
  final String city;
  final String pincode;
  final String contactNumber;
  final String emailId;
  final String ownerName;
  final String licenseNumber;
  final String gstNumber;
  final String panNumber;
  final String storeTiming;
  final String storeDays;
  final String floor;
  final String medicineType;
  final bool isRareMedicationsAvailable;
  final bool isOnlinePayment;
  final bool isLiftAccess;
  final bool isWheelchairAccess;
  final bool isParkingAvailable;
  final String location;
  final List<String> availableMedicines;
  final List<String> registrationCertificates;  // Changed to List<String>
  final List<String> complianceCertificates;   // Changed to List<String>
  final List<String> photos;  // Changed to List<String>

  VendorMedicalStoreProfile({
    this.vendorId,
    this.generatedId,
    required this.name,
    required this.address,
    required this.landmark,
    required this.state,
    required this.city,
    required this.pincode,
    required this.contactNumber,
    required this.emailId,
    required this.ownerName,
    required this.licenseNumber,
    required this.gstNumber,
    required this.panNumber,
    required this.storeTiming,
    required this.storeDays,
    required this.floor,
    required this.medicineType,
    required this.isRareMedicationsAvailable,
    required this.isOnlinePayment,
    required this.isLiftAccess,
    required this.isWheelchairAccess,
    required this.isParkingAvailable,
    required this.location,
    required this.availableMedicines,
    required this.registrationCertificates,
    required this.complianceCertificates,
    required this.photos,
  });

  factory VendorMedicalStoreProfile.fromJson(Map<String, dynamic> json) {
    return VendorMedicalStoreProfile(
      vendorId: json['vendorId'],
      generatedId: json['generatedId'],
      name: json['name'],
      address: json['address'],
      landmark: json['landmark'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      contactNumber: json['contactNumber'],
      emailId: json['emailId'],
      ownerName: json['ownerName'],
      licenseNumber: json['licenseNumber'],
      gstNumber: json['gstNumber'],
      panNumber: json['panNumber'],
      storeTiming: json['storeTiming'],
      storeDays: json['storeDays'],
      floor: json['floor'],
      medicineType: json['medicineType'],
      isRareMedicationsAvailable: json['isRareMedicationsAvailable'],
      isOnlinePayment: json['isOnlinePayment'],
      isLiftAccess: json['isLiftAccess'],
      isWheelchairAccess: json['isWheelchairAccess'],
      isParkingAvailable: json['isParkingAvailable'],
      location: json['location'],
      availableMedicines: List<String>.from(json['availableMedicines'] ?? []),
      registrationCertificates: List<String>.from(json['registrationCertificates'] ?? []),  // Changed to List<String>
      complianceCertificates: List<String>.from(json['complianceCertificates'] ?? []),   // Changed to List<String>
      photos: List<String>.from(json['photos'] ?? []),  // Changed to List<String>
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vendorId": vendorId,
      "generatedId": generatedId,
      "name": name,
      "address": address,
      "landmark": landmark,
      "state": state,
      "city": city,
      "pincode": pincode,
      "contactNumber": contactNumber,
      "emailId": emailId,
      "ownerName": ownerName,
      "licenseNumber": licenseNumber,
      "gstNumber": gstNumber,
      "panNumber": panNumber,
      "storeTiming": storeTiming,
      "storeDays": storeDays,
      "floor": floor,
      "medicineType": medicineType,
      "isRareMedicationsAvailable": isRareMedicationsAvailable,
      "isOnlinePayment": isOnlinePayment,
      "isLiftAccess": isLiftAccess,
      "isWheelchairAccess": isWheelchairAccess,
      "isParkingAvailable": isParkingAvailable,
      "location": location,
      "availableMedicines": availableMedicines,
      "registrationCertificates": registrationCertificates,  // Changed to List<String>
      "complianceCertificates": complianceCertificates,   // Changed to List<String>
      "photos": photos,  // Changed to List<String>
    };
  }
}
