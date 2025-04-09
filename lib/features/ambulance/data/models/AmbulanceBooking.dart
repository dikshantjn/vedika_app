import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

class AmbulanceBooking {
  final String requestId;
  final String userId;
  final String vendorId;
  final String pickupLocation;
  final String dropLocation;
  String status;
  final String vehicleType;
  final double totalAmount;
  final double totalDistance;
  final double costPerKm;
  final double baseCharge;
  final DateTime timestamp;
  final DateTime requiredDateTime;
  final UserModel user;

  AmbulanceBooking({
    required this.requestId,
    required this.userId,
    required this.vendorId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.status,
    required this.vehicleType,
    required this.totalAmount,
    required this.totalDistance,
    required this.costPerKm,
    required this.baseCharge,
    required this.timestamp,
    required this.requiredDateTime,
    required this.user,
  });

  factory AmbulanceBooking.fromJson(Map<String, dynamic> json) {
    return AmbulanceBooking(
      requestId: json['requestId'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      dropLocation: json['dropLocation'] ?? '',
      status: json['status'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      costPerKm: (json['costPerKm'] ?? 0).toDouble(),
      baseCharge: (json['baseCharge'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      requiredDateTime: DateTime.tryParse(json['requiredDateTime'] ?? '') ?? DateTime.now(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : UserModel.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'vendorId': vendorId,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'status': status,
      'vehicleType': vehicleType,
      'totalAmount': totalAmount,
      'totalDistance': totalDistance,
      'costPerKm': costPerKm,
      'baseCharge': baseCharge,
      'timestamp': timestamp.toIso8601String(),
      'requiredDateTime': requiredDateTime.toIso8601String(),
      'user': user.toJson(),
    };
  }

  AmbulanceBooking copyWith({
    String? requestId,
    String? userId,
    String? vendorId,
    String? pickupLocation,
    String? dropLocation,
    String? status,
    String? vehicleType,
    double? totalAmount,
    double? totalDistance,
    double? costPerKm,
    double? baseCharge,
    DateTime? timestamp,
    DateTime? requiredDateTime,
    UserModel? user,
  }) {
    return AmbulanceBooking(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      status: status ?? this.status,
      vehicleType: vehicleType ?? this.vehicleType,
      totalAmount: totalAmount ?? this.totalAmount,
      totalDistance: totalDistance ?? this.totalDistance,
      costPerKm: costPerKm ?? this.costPerKm,
      baseCharge: baseCharge ?? this.baseCharge,
      timestamp: timestamp ?? this.timestamp,
      requiredDateTime: requiredDateTime ?? this.requiredDateTime,
      user: user ?? this.user,
    );
  }
}
