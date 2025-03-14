class Pathology {
  final String pathologyId;
  final String pathologyGeneratedId; // Unique category-wise ID
  final String name;
  final String address;
  final String contactNumber;
  final List<String> testsOffered;
  final String licenseNumber;
  final List<String> images;

  Pathology({
    required this.pathologyId,
    required this.pathologyGeneratedId,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.testsOffered,
    required this.licenseNumber,
    required this.images,
  });

  factory Pathology.fromJson(Map<String, dynamic> json) {
    return Pathology(
      pathologyId: json['pathologyId'],
      pathologyGeneratedId: json['pathologyGeneratedId'],
      name: json['name'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      testsOffered: List<String>.from(json['testsOffered']),
      licenseNumber: json['licenseNumber'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pathologyId": pathologyId,
      "pathologyGeneratedId": pathologyGeneratedId,
      "name": name,
      "address": address,
      "contactNumber": contactNumber,
      "testsOffered": testsOffered,
      "licenseNumber": licenseNumber,
      "images": images,
    };
  }
}
