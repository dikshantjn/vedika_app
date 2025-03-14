class Hospital {
  final String hospitalId;
  final String hospitalGeneratedId; // Unique category-wise ID
  final String name;
  final String state; // State Code (e.g., MH)
  final String city; // City Code (e.g., PNQ)
  final String pincode;
  final String contactNumber;
  final List<String> specialties;
  final int availableBeds;
  final String licenseNumber;
  final String website;
  final String email;
  final String ownerName;
  final List<RegistrationCertificate> registrationCertificates; // Updated to use RegistrationCertificate model
  final List<HospitalImage> images; // Updated to use HospitalImage model

  Hospital({
    required this.hospitalId,
    required this.hospitalGeneratedId,
    required this.name,
    required this.state,
    required this.city,
    required this.pincode,
    required this.contactNumber,
    required this.specialties,
    required this.availableBeds,
    required this.licenseNumber,
    required this.website,
    required this.email,
    required this.ownerName,
    required this.registrationCertificates, // List of registration certificates
    required this.images, // List of hospital images
  });

  /// **Factory constructor for JSON deserialization**
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalId: json['hospitalId'],
      hospitalGeneratedId: json['hospitalGeneratedId'],
      name: json['name'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      contactNumber: json['contactNumber'],
      specialties: List<String>.from(json['specialties']),
      availableBeds: json['availableBeds'],
      licenseNumber: json['licenseNumber'],
      website: json['website'],
      email: json['email'],
      ownerName: json['ownerName'],
      registrationCertificates: (json['registrationCertificates'] as List).map((item) => RegistrationCertificate.fromJson(item)).toList(),
      images: (json['images'] as List).map((item) => HospitalImage.fromJson(item)).toList(),
    );
  }

  /// **Convert Hospital object to JSON**
  Map<String, dynamic> toJson() {
    return {
      "hospitalId": hospitalId,
      "hospitalGeneratedId": hospitalGeneratedId,
      "name": name,
      "state": state,
      "city": city,
      "pincode": pincode,
      "contactNumber": contactNumber,
      "specialties": specialties,
      "availableBeds": availableBeds,
      "licenseNumber": licenseNumber,
      "website": website,
      "email": email,
      "ownerName": ownerName,
      "registrationCertificates": registrationCertificates.map((item) => item.toJson()).toList(),
      "images": images.map((item) => item.toJson()).toList(),
    };
  }
}

class RegistrationCertificate {
  final String certificateUrl;
  final String certificateName; // Certificate description/name

  RegistrationCertificate({
    required this.certificateUrl,
    required this.certificateName,
  });

  /// **Factory constructor for JSON deserialization**
  factory RegistrationCertificate.fromJson(Map<String, dynamic> json) {
    return RegistrationCertificate(
      certificateUrl: json['certificateUrl'],
      certificateName: json['certificateName'],
    );
  }

  /// **Convert RegistrationCertificate object to JSON**
  Map<String, dynamic> toJson() {
    return {
      "certificateUrl": certificateUrl,
      "certificateName": certificateName,
    };
  }
}

class HospitalImage {
  final String imageUrl;
  final String imageDescription; // Description for the image

  HospitalImage({
    required this.imageUrl,
    required this.imageDescription,
  });

  /// **Factory constructor for JSON deserialization**
  factory HospitalImage.fromJson(Map<String, dynamic> json) {
    return HospitalImage(
      imageUrl: json['imageUrl'],
      imageDescription: json['imageDescription'],
    );
  }

  /// **Convert HospitalImage object to JSON**
  Map<String, dynamic> toJson() {
    return {
      "imageUrl": imageUrl,
      "imageDescription": imageDescription,
    };
  }
}
