import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankRequest {
  final String? requestId;
  final String userId;
  final UserModel user;
  final String customerName;
  final String bloodType;
  final int units;
  final List<String> prescriptionUrls;
  final List<String> requestedVendors;
  final String status; // pending, cancelled, expired
  final DateTime createdAt;

  BloodBankRequest({
    this.requestId,
    required this.userId,
    required this.user,
    required this.customerName,
    required this.bloodType,
    required this.units,
    required this.prescriptionUrls,
    required this.requestedVendors,
    required this.status,
    required this.createdAt,
  });

  BloodBankRequest copyWith({
    String? requestId,
    String? userId,
    UserModel? user,
    String? customerName,
    String? bloodType,
    int? units,
    List<String>? prescriptionUrls,
    List<String>? requestedVendors,
    String? status,
    DateTime? createdAt,
  }) {
    return BloodBankRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      customerName: customerName ?? this.customerName,
      bloodType: bloodType ?? this.bloodType,
      units: units ?? this.units,
      prescriptionUrls: prescriptionUrls ?? this.prescriptionUrls,
      requestedVendors: requestedVendors ?? this.requestedVendors,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'user': user.toJson(),
      'customerName': customerName,
      'bloodType': bloodType,
      'units': units,
      'prescriptionUrls': prescriptionUrls,
      'requestedVendors': requestedVendors,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BloodBankRequest.fromJson(Map<String, dynamic> json) {
    return BloodBankRequest(
      requestId: json['requestId'],
      userId: json['userId'],
      user: UserModel.fromJson(json['user']),
      customerName: json['customerName'],
      bloodType: json['bloodType'],
      units: json['units'],
      prescriptionUrls: List<String>.from(json['prescriptionUrls']),
      requestedVendors: List<String>.from(json['requestedVendors']),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    return 'BloodBankRequest(requestId: $requestId, userId: $userId, user: ${user.name}, customerName: $customerName, bloodType: $bloodType, units: $units, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodBankRequest && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
} 