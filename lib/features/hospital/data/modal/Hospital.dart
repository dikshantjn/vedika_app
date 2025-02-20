class Doctor {
  String name;
  String specialization;
  List<String> timeSlots;
  int fee;

  Doctor({
    required this.name,
    required this.specialization,
    required this.timeSlots,
    required this.fee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      specialization: json['specialization'],
      timeSlots: List<String>.from(json['timeSlots']),
      fee: json['fee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'timeSlots': timeSlots,
      'fee': fee,
    };
  }
}

class Hospital {
  String id;
  String name;
  String address;
  String contact;
  String email;
  String website;
  List<String> specialties;
  List<Doctor> doctors;
  int beds;
  List<String> services;
  String visitingHours;
  double ratings;
  List<String> insuranceProviders;
  List<String> labs;
  double lat;
  double lng;
  List<String> images; // Added images field

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.email,
    required this.website,
    required this.specialties,
    required this.doctors,
    required this.beds,
    required this.services,
    required this.visitingHours,
    required this.ratings,
    required this.insuranceProviders,
    required this.labs,
    required this.lat,
    required this.lng,
    required this.images, // Initialize images
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      contact: json['contact'],
      email: json['email'],
      website: json['website'],
      specialties: List<String>.from(json['specialties']),
      doctors: (json['doctors'] as List).map((doc) => Doctor.fromJson(doc)).toList(),
      beds: json['beds'],
      services: List<String>.from(json['services']),
      visitingHours: json['visitingHours'],
      ratings: json['ratings'].toDouble(),
      insuranceProviders: List<String>.from(json['insuranceProviders']),
      labs: List<String>.from(json['labs']),
      lat: json['lat'],
      lng: json['lng'],
      images: List<String>.from(json['images'] ?? []), // Handle missing images field safely
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact': contact,
      'email': email,
      'website': website,
      'specialties': specialties,
      'doctors': doctors.map((doc) => doc.toJson()).toList(),
      'beds': beds,
      'services': services,
      'visitingHours': visitingHours,
      'ratings': ratings,
      'insuranceProviders': insuranceProviders,
      'labs': labs,
      'lat': lat,
      'lng': lng,
      'images': images, // Include images in serialization
    };
  }
}
