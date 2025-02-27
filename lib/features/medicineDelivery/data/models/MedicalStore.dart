class MedicalStore {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String contact;

  MedicalStore({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contact,
  });

  // Convert JSON to Model
  factory MedicalStore.fromJson(Map<String, dynamic> json) {
    return MedicalStore(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      contact: json['contact'],
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contact': contact,
    };
  }
}
