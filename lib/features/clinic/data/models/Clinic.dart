class Doctor {
  final String name;
  final String specialization;
  final List<String> timeSlots;
  final int fee;
  final String imageUrl;  // New field for image URL

  Doctor({
    required this.name,
    required this.specialization,
    required this.timeSlots,
    required this.fee,
    required this.imageUrl,  // Add imageUrl to the constructor
  });

  // To convert a doctor to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'timeSlots': timeSlots,
      'fee': fee,
      'imageUrl': imageUrl,  // Add imageUrl to JSON
    };
  }

  // To convert from JSON to a doctor object
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'] ?? '',  // Default to empty string if null
      specialization: json['specialization'] ?? '',  // Default to empty string if null
      timeSlots: List<String>.from(json['timeSlots'] ?? []),  // Default to empty list if null
      fee: json['fee'] ?? 0,  // Default to 0 if null
      imageUrl: json['imageUrl'] ?? '',  // Default to empty string if null
    );
  }
}


class Clinic {
  final String id;
  final String name;
  final String address;
  final String contact;
  final double lat;
  final double lng;
  final List<Doctor> doctors;
  final List<String> specialties;
  final List<String> images;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.lat,
    required this.lng,
    required this.doctors,
    required this.specialties,
    required this.images,
  });

  // To convert a clinic to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact': contact,
      'lat': lat,
      'lng': lng,
      'doctors': doctors.map((doctor) => doctor.toJson()).toList(),
      'specialties': specialties,
      'images': images,
    };
  }

  // To convert from JSON to a clinic object
  factory Clinic.fromJson(Map<String, dynamic> json) {
    var doctorsList = (json['doctors'] as List)
        .map((doctorJson) => Doctor.fromJson(doctorJson))
        .toList();

    return Clinic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
      doctors: doctorsList,
      specialties: List<String>.from(json['specialties'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

