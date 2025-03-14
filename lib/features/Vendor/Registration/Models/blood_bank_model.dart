class BloodBank {
  final String bankId;
  final String bloodBankGeneratedId; // Unique category-wise ID
  final String name;
  final String address;
  final String contactNumber;
  final String licenseNumber;
  final List<String> availableBloodGroups;
  final List<String> images;

  BloodBank({
    required this.bankId,
    required this.bloodBankGeneratedId,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.licenseNumber,
    required this.availableBloodGroups,
    required this.images,
  });

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    return BloodBank(
      bankId: json['bankId'],
      bloodBankGeneratedId: json['bloodBankGeneratedId'],
      name: json['name'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      licenseNumber: json['licenseNumber'],
      availableBloodGroups: List<String>.from(json['availableBloodGroups']),
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "bankId": bankId,
      "bloodBankGeneratedId": bloodBankGeneratedId,
      "name": name,
      "address": address,
      "contactNumber": contactNumber,
      "licenseNumber": licenseNumber,
      "availableBloodGroups": availableBloodGroups,
      "images": images,
    };
  }
}
