class DeliveryAddressModel {
  final String? addressId;
  final String? userId;
  final String houseStreet;
  final String addressLine1;
  final String? addressLine2;  // Make this nullable
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String addressType;
  final DateTime? createdAt;

  DeliveryAddressModel({
    this.addressId,
    this.userId,
    required this.houseStreet,
    required this.addressLine1,
    this.addressLine2,  // Make this nullable
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.addressType,
    this.createdAt,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      addressId: json['addressId'] as String?,
      userId: json['userId'] as String?,
      houseStreet: json['houseStreet'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?, // Make this nullable
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      addressType: json['addressType'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'houseStreet': houseStreet,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,  // Make this nullable
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'addressType': addressType,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
