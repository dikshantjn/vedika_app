class MedicalStore {
  final String storeId;
  final String medicalStoreGeneratedId;
  final String name;
  final String address;
  final String contactNumber;
  final String ownerName;
  final String licenseNumber;
  final String gstNumber;
  final List<String> availableMedicines;
  final List<String> images;

  MedicalStore({
    required this.storeId,
    required this.medicalStoreGeneratedId,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.ownerName,
    required this.licenseNumber,
    required this.gstNumber,
    required this.availableMedicines,
    required this.images,
  });

  factory MedicalStore.fromJson(Map<String, dynamic> json) {
    return MedicalStore(
      storeId: json['storeId'],
      medicalStoreGeneratedId: json['medicalStoreGeneratedId'],
      name: json['name'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      ownerName: json['ownerName'],
      licenseNumber: json['licenseNumber'],
      gstNumber: json['gstNumber'],
      availableMedicines: List<String>.from(json['availableMedicines']),
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "storeId": storeId,
      "medicalStoreGeneratedId": medicalStoreGeneratedId,
      "name": name,
      "address": address,
      "contactNumber": contactNumber,
      "ownerName": ownerName,
      "licenseNumber": licenseNumber,
      "gstNumber": gstNumber,
      "availableMedicines": availableMedicines,
      "images": images,
    };
  }
}
