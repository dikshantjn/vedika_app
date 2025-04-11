
class BloodBankRequest {
  final String? requestId;
  final String userId;
  final String customerName;
  final String bloodType;
  final int units;
  final double deliveryFees;
  final double gst;
  final double discount;
  final double totalAmount;
  final List<String> prescriptionUrls;
  final List<String> requestedVendors;
  final String status;
  final DateTime createdAt;

  BloodBankRequest({
    this.requestId,
    required this.userId,
    required this.customerName,
    required this.bloodType,
    required this.units,
    required this.deliveryFees,
    required this.gst,
    required this.discount,
    required this.totalAmount,
    required this.prescriptionUrls,
    required this.requestedVendors,
    required this.status,
    required this.createdAt,
  });

  BloodBankRequest copyWith({
    String? requestId,
    String? userId,
    String? customerName,
    String? bloodType,
    int? units,
    double? deliveryFees,
    double? gst,
    double? discount,
    double? totalAmount,
    List<String>? prescriptionUrls,
    List<String>? requestedVendors,
    String? status,
    DateTime? createdAt,
  }) {
    return BloodBankRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      bloodType: bloodType ?? this.bloodType,
      units: units ?? this.units,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      gst: gst ?? this.gst,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
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
      'customerName': customerName,
      'bloodType': bloodType,
      'units': units,
      'deliveryFees': deliveryFees,
      'gst': gst,
      'discount': discount,
      'totalAmount': totalAmount,
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
      customerName: json['customerName'],
      bloodType: json['bloodType'],
      units: json['units'],
      deliveryFees: json['deliveryFees'].toDouble(),
      gst: json['gst'].toDouble(),
      discount: json['discount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      prescriptionUrls: List<String>.from(json['prescriptionUrls']),
      requestedVendors: List<String>.from(json['requestedVendors']),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    return 'BloodBankRequest(requestId: $requestId, userId: $userId, customerName: $customerName, bloodType: $bloodType, units: $units, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodBankRequest && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
} 