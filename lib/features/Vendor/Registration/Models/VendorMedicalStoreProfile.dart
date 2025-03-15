class VendorMedicalStoreProfile {
  final String? vendorId;  // Vendor ID is now optional
  final String? generatedId;  // Generated ID is now optional
  final String name;
  final String address;
  final String landmark;
  final String state;
  final String city;
  final String pincode;
  final String contactNumber;
  final String ownerName;
  final String licenseNumber;
  final String gstNumber;
  final String storeTiming;
  final String storeDays;
  final String floor;
  final List<String> availableMedicines;
  final List<String> images;

  VendorMedicalStoreProfile({
    this.vendorId,  // Made optional
    this.generatedId,  // Made optional
    required this.name,
    required this.address,
    required this.landmark,
    required this.state,
    required this.city,
    required this.pincode,
    required this.contactNumber,
    required this.ownerName,
    required this.licenseNumber,
    required this.gstNumber,
    required this.storeTiming,
    required this.storeDays,
    required this.floor,
    required this.availableMedicines,
    required this.images,
  });

  /// **Factory Method to Create Object from JSON**
  factory VendorMedicalStoreProfile.fromJson(Map<String, dynamic> json) {
    return VendorMedicalStoreProfile(
      vendorId: json['vendorId'],  // Can be null
      generatedId: json['generatedId'],  // Can be null
      name: json['name'],
      address: json['address'],
      landmark: json['landmark'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      contactNumber: json['contactNumber'],
      ownerName: json['ownerName'],
      licenseNumber: json['licenseNumber'],
      gstNumber: json['gstNumber'],
      storeTiming: json['storeTiming'],
      storeDays: json['storeDays'],
      floor: json['floor'],
      availableMedicines: List<String>.from(json['availableMedicines']),
      images: List<String>.from(json['images']),
    );
  }

  /// **Convert Object to JSON**
  Map<String, dynamic> toJson() {
    return {
      "vendorId": vendorId,  // Can be null
      "generatedId": generatedId,  // Can be null
      "name": name,
      "address": address,
      "landmark": landmark,
      "state": state,
      "city": city,
      "pincode": pincode,
      "contactNumber": contactNumber,
      "ownerName": ownerName,
      "licenseNumber": licenseNumber,
      "gstNumber": gstNumber,
      "storeTiming": storeTiming,
      "storeDays": storeDays,
      "floor": floor,
      "availableMedicines": availableMedicines,
      "images": images,
    };
  }
}




/// **Medical Store Image Model**
class MedicalStoreImage {
  String imageUrl;
  String description;
  String state;
  String city;
  String pincode;

  MedicalStoreImage({
    required this.imageUrl,
    required this.description,
    required this.state,
    required this.city,
    required this.pincode,
  });

  Map<String, dynamic> toJson() => {
    "imageUrl": imageUrl,
    "description": description,
    "state": state,
    "city": city,
    "pincode": pincode,
  };

  factory MedicalStoreImage.fromJson(Map<String, dynamic> json) {
    return MedicalStoreImage(
      imageUrl: json["imageUrl"],
      description: json["description"],
      state: json["state"],
      city: json["city"],
      pincode: json["pincode"],
    );
  }
}
