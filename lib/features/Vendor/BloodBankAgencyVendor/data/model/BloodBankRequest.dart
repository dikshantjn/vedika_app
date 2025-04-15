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
  final String? acceptedVendorId;
  final String status; // pending, cancelled, expired, completed
  final DateTime createdAt;
  final DateTime updatedAt;

  BloodBankRequest({
    this.requestId,
    required this.userId,
    required this.user,
    required this.customerName,
    required this.bloodType,
    required this.units,
    required this.prescriptionUrls,
    required this.requestedVendors,
    this.acceptedVendorId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
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
    String? acceptedVendorId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      acceptedVendorId: acceptedVendorId ?? this.acceptedVendorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'acceptedVendorId': acceptedVendorId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      acceptedVendorId: json['acceptedVendorId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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