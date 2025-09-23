import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';

class LabTestBooking {
  String? bookingId;
  String? vendorId;
  String? userId;
  List<String>? selectedTests;
  String? bookingDate;
  String? bookingTime;
  bool? homeCollectionRequired;
  bool? reportDeliveryAtHome;
  String? prescriptionUrl;
  double? testFees;
  double? reportDeliveryFees;
  double? discount;
  double? gst;
  double? totalAmount;
  String? bookingStatus; // Pending, Accepted, Rejected, Completed, Cancelled
  String? paymentStatus; // Pending, Paid
  String? paymentId; // Payment ID from Razorpay
  String? userAddress;
  String? userLocation; // Latitude,Longitude as String
  String? centerLocationUrl;
  Map<String, String>? reportUrls;
  UserModel? user;
  DiagnosticCenter? diagnosticCenter;
  DateTime? createdAt;
  DateTime? updatedAt;

  LabTestBooking({
    this.bookingId,
    this.vendorId,
    this.userId,
    this.selectedTests,
    this.bookingDate,
    this.bookingTime,
    this.homeCollectionRequired,
    this.reportDeliveryAtHome,
    this.prescriptionUrl,
    this.testFees,
    this.reportDeliveryFees,
    this.discount,
    this.gst,
    this.totalAmount,
    this.bookingStatus,
    this.paymentStatus,
    this.paymentId,
    this.userAddress,
    this.userLocation,
    this.centerLocationUrl,
    this.reportUrls,
    this.user,
    this.diagnosticCenter,
    this.createdAt,
    this.updatedAt,
  });

  factory LabTestBooking.fromJson(Map<String, dynamic> json) {
    // Debug print for reportUrls

    return LabTestBooking(
      bookingId: json['bookingId'],
      vendorId: json['vendorId'],
      userId: json['userId'],
      selectedTests: List<String>.from(json['selectedTests'] ?? []),
      bookingDate: json['bookingDate'],
      bookingTime: json['bookingTime'],
      homeCollectionRequired: json['homeCollectionRequired'],
      reportDeliveryAtHome: json['reportDeliveryAtHome'],
      prescriptionUrl: json['prescriptionUrl'],
      testFees: (json['testFees'] ?? 0).toDouble(),
      reportDeliveryFees: (json['reportDeliveryFees'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      bookingStatus: json['bookingStatus'],
      paymentStatus: json['paymentStatus'],
      paymentId: json['paymentId'],
      userAddress: json['userAddress'],
      userLocation: json['userLocation'],
      centerLocationUrl: json['centerLocationUrl'],
      reportUrls: json['reportUrls'] != null 
          ? Map<String, String>.from(json['reportUrls'] as Map)
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      diagnosticCenter: json['diagnosticCenter'] != null
          ? DiagnosticCenter.fromJson(json['diagnosticCenter'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'vendorId': vendorId,
      'userId': userId,
      'selectedTests': selectedTests,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'homeCollectionRequired': homeCollectionRequired,
      'reportDeliveryAtHome': reportDeliveryAtHome,
      'prescriptionUrl': prescriptionUrl,
      'testFees': testFees,
      'reportDeliveryFees': reportDeliveryFees,
      'discount': discount,
      'gst': gst,
      'totalAmount': totalAmount,
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'userAddress': userAddress,
      'userLocation': userLocation,
      'centerLocationUrl': centerLocationUrl,
      'reportUrls': reportUrls,
      'user': user?.toJson(),
      'diagnosticCenter': diagnosticCenter?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
