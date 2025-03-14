class Clinic {
  final String clinicId;
  final String clinicGeneratedId;
  final String name;
  final String address;
  final String contactNumber;
  final String ownerName;
  final String licenseNumber;
  final List<String> services;
  final String openingHours;
  final String registrationCertificate;
  final List<String> images;

  Clinic({
    required this.clinicId,
    required this.clinicGeneratedId,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.ownerName,
    required this.licenseNumber,
    required this.services,
    required this.openingHours,
    required this.registrationCertificate,
    required this.images,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      clinicId: json['clinicId'],
      clinicGeneratedId: json['clinicGeneratedId'],
      name: json['name'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      ownerName: json['ownerName'],
      licenseNumber: json['licenseNumber'],
      services: List<String>.from(json['services']),
      openingHours: json['openingHours'],
      registrationCertificate: json['registrationCertificate'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "clinicId": clinicId,
      "clinicGeneratedId": clinicGeneratedId,
      "name": name,
      "address": address,
      "contactNumber": contactNumber,
      "ownerName": ownerName,
      "licenseNumber": licenseNumber,
      "services": services,
      "openingHours": openingHours,
      "registrationCertificate": registrationCertificate,
      "images": images,
    };
  }
}

