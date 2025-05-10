import '../../../../../core/auth/data/models/UserModel.dart';
import 'BloodBankAgency.dart';

class BloodBankBooking {
  final String? bookingId;
  final String requestId;
  final String vendorId;
  final String userId;
  final UserModel user;
  final List<String> bloodType;
  final String healthIssue;
  final String deliveryLocation;
  final int units;
  final double pricePerUnit;
  final double deliveryFees;
  final double gst;
  final double discount;
  double totalAmount;
  final String deliveryType;
  String paymentStatus;
  String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? notes;
  final DateTime? updatedAt;
  final BloodRequest? bloodRequest;
  final BloodBankAgency? agency;

  BloodBankBooking({
    this.bookingId,
    required this.requestId,
    required this.vendorId,
    required this.userId,
    required this.user,
    required this.bloodType,
    required this.healthIssue,
    required this.deliveryLocation,
    required this.units,
    required this.pricePerUnit,
    required this.deliveryFees,
    required this.gst,
    required this.discount,
    required this.totalAmount,
    required this.deliveryType,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.notes,
    this.updatedAt,
    this.bloodRequest,
    this.agency,
  });

  BloodBankBooking copyWith({
    String? bookingId,
    String? requestId,
    String? vendorId,
    String? userId,
    UserModel? user,
    List<String>? bloodType,
    String? healthIssue,
    String? deliveryLocation,
    int? units,
    double? pricePerUnit,
    double? deliveryFees,
    double? gst,
    double? discount,
    double? totalAmount,
    String? deliveryType,
    String? paymentStatus,
    String? status,
    DateTime? createdAt,
    DateTime? scheduledDate,
    String? notes,
    DateTime? updatedAt,
    BloodRequest? bloodRequest,
    BloodBankAgency? agency,
  }) {
    return BloodBankBooking(
      bookingId: bookingId ?? this.bookingId,
      requestId: requestId ?? this.requestId,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      bloodType: bloodType ?? this.bloodType,
      healthIssue: healthIssue ?? this.healthIssue,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      units: units ?? this.units,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      gst: gst ?? this.gst,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      bloodRequest: bloodRequest ?? this.bloodRequest,
      agency: agency ?? this.agency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'requestId': requestId,
      'vendorId': vendorId,
      'userId': userId,
      'user': user.toJson(),
      'bloodType': bloodType,
      'healthIssue': healthIssue,
      'deliveryLocation': deliveryLocation,
      'units': units,
      'pricePerUnit': pricePerUnit,
      'deliveryFees': deliveryFees,
      'gst': gst,
      'discount': discount,
      'totalAmount': totalAmount,
      'deliveryType': deliveryType,
      'paymentStatus': paymentStatus,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'notes': notes,
      'updatedAt': updatedAt?.toIso8601String(),
      'bloodRequest': bloodRequest?.toJson(),
      'agency': agency?.toJson(),
    };
  }

  factory BloodBankBooking.fromJson(Map<String, dynamic> json) {
    UserModel userModel;
    if (json.containsKey('bloodRequest') &&
        json['bloodRequest'] != null &&
        json['bloodRequest'].containsKey('user') &&
        json['bloodRequest']['user'] != null) {
      userModel = UserModel.fromJson(json['bloodRequest']['user']);
    } else if (json.containsKey('user') && json['user'] != null) {
      userModel = UserModel.fromJson(json['user']);
    } else {
      userModel = UserModel.empty();
    }

    BloodBankAgency? agency;
    if (json.containsKey('agency') && json['agency'] != null) {
      agency = BloodBankAgency.fromJson(json['agency']);
    }

    return BloodBankBooking(
      bookingId: json['bookingId'],
      requestId: json['requestId'],
      vendorId: json['vendorId'],
      userId: json['userId'],
      user: userModel,
      bloodType: json['bloodType'] is String
          ? [json['bloodType']]
          : List<String>.from(json['bloodType'] ?? []),
      healthIssue: json['healthIssue'] ?? '',
      deliveryLocation: json['deliveryLocation'] ?? '',
      units: json['units']?.toInt() ?? 0,
      pricePerUnit: json['pricePerUnit'] is String
          ? double.parse(json['pricePerUnit'])
          : json['pricePerUnit']?.toDouble() ?? 0.0,
      deliveryFees: json['deliveryFees'] is String
          ? double.parse(json['deliveryFees'])
          : json['deliveryFees']?.toDouble() ?? 0.0,
      gst: json['gst'] is String
          ? double.parse(json['gst'])
          : json['gst']?.toDouble() ?? 0.0,
      discount: json['discount'] is String
          ? double.parse(json['discount'])
          : json['discount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount'] is String
          ? double.parse(json['totalAmount'])
          : json['totalAmount']?.toDouble() ?? 0.0,
      deliveryType: json['deliveryType'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      notes: json['notes'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      bloodRequest: json['bloodRequest'] != null
          ? BloodRequest.fromJson(json['bloodRequest'])
          : null,
      agency: agency,
    );
  }

  static double calculateTotalAmount(double baseAmount, double deliveryFees, double gst, double discount) {
    final subtotal = baseAmount + deliveryFees;
    final gstAmount = subtotal * (gst / 100);
    return subtotal + gstAmount - discount;
  }

  @override
  String toString() {
    return 'BloodBankBooking(bookingId: $bookingId, requestId: $requestId, vendorId: $vendorId, user: ${user.name}, bloodType: $bloodType, units: $units, status: $status, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodBankBooking && other.bookingId == bookingId;
  }

  @override
  int get hashCode => bookingId.hashCode;
}


class BloodRequest {
  final String requestId;
  final String userId;
  final String customerName;
  final String bloodType;
  final int units;
  final List<String> prescriptionUrls;
  final List<String> requestedVendors;
  final String? acceptedVendorId;
  final String status;
  final UserModel? user;

  BloodRequest({
    required this.requestId,
    required this.userId,
    required this.customerName,
    required this.bloodType,
    required this.units,
    required this.prescriptionUrls,
    required this.requestedVendors,
    this.acceptedVendorId,
    required this.status,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'customerName': customerName,
      'bloodType': bloodType,
      'units': units,
      'prescriptionUrls': prescriptionUrls,
      'requestedVendors': requestedVendors,
      'acceptedVendorId': acceptedVendorId,
      'status': status,
      'user': user?.toJson(),
    };
  }

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      requestId: json['requestId'],
      userId: json['userId'],
      customerName: json['customerName'] ?? '',
      bloodType: json['bloodType'] ?? '',
      units: json['units']?.toInt() ?? 0,
      prescriptionUrls: List<String>.from(json['prescriptionUrls'] ?? []),
      requestedVendors: List<String>.from(json['requestedVendors'] ?? []),
      acceptedVendorId: json['acceptedVendorId'],
      status: json['status'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}