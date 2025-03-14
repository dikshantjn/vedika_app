class AmbulanceAgency {
  final String agencyId;
  final String ambulanceAgencyGeneratedId; // Unique category-wise ID
  final String name;
  final String address;
  final String contactNumber;
  final List<String> ambulanceTypes;
  final String licenseNumber;
  final List<String> images;

  AmbulanceAgency({
    required this.agencyId,
    required this.ambulanceAgencyGeneratedId,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.ambulanceTypes,
    required this.licenseNumber,
    required this.images,
  });

  factory AmbulanceAgency.fromJson(Map<String, dynamic> json) {
    return AmbulanceAgency(
      agencyId: json['agencyId'],
      ambulanceAgencyGeneratedId: json['ambulanceAgencyGeneratedId'],
      name: json['name'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      ambulanceTypes: List<String>.from(json['ambulanceTypes']),
      licenseNumber: json['licenseNumber'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "agencyId": agencyId,
      "ambulanceAgencyGeneratedId": ambulanceAgencyGeneratedId,
      "name": name,
      "address": address,
      "contactNumber": contactNumber,
      "ambulanceTypes": ambulanceTypes,
      "licenseNumber": licenseNumber,
      "images": images,
    };
  }
}
