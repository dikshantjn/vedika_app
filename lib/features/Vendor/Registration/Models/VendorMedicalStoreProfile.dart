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
   List<String> registrationCertificates;  // Changed to List<String>
   List<String> complianceCertificates;   // Changed to List<String>
   List<String> photos;  // Changed to List<String>

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
      pincode: json['pincode'].toString(),
      contactNumber: json['contactNumber'].toString(),
      emailId: json['emailId'],
      ownerName: json['ownerName'],
      licenseNumber: json['licenseNumber'].toString(),
      gstNumber: json['gstNumber'].toString(),
      panNumber: json['panNumber'].toString(),
      storeTiming: json['storeTiming'],
      storeDays: json['storeDays'].toString(),
      floor: json['floor'],
      medicineType: json['medicineType'],
      isRareMedicationsAvailable: json['isRareMedicationsAvailable'] ?? false,
      isOnlinePayment: json['isOnlinePayment'] ?? false,
      isLiftAccess: json['isLiftAccess'] ?? false,
      isWheelchairAccess: json['isWheelchairAccess'] ?? false,
      isParkingAvailable: json['isParkingAvailable'] ?? false,
      location: json['location'] ?? '',
      availableMedicines: _convertToList(json['availableMedicines']),
      registrationCertificates: _convertToList(json['registrationCertificates']),
      complianceCertificates: _convertToList(json['complianceCertificates']),
      photos: _convertToList(json['photos']),
    );
  }

// ✅ **Helper function to handle single string or list**
  static List<String> _convertToList(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<String>.from(data);
    if (data is String) return [data];  // Convert single string to list
    return [];
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
