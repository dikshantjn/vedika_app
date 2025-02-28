class DeliveryPartner {
  final String id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final double rating;
  final double chargesPerKm;

  DeliveryPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.chargesPerKm,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      rating: json['rating'].toDouble(),
      chargesPerKm: json['chargesPerKm'].toDouble(),
    );
  }
}
