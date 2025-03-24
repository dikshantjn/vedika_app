import 'package:flutter/foundation.dart';

class PrescriptionRequestModel {
  final String prescriptionId;
  final String userId;
  final List<String>? requestedVendors;
  final String? acceptedVendor;
  final bool requestAcceptedStatus;
  final String prescriptionAcceptedStatus;
  final String prescriptionUrl;
  final DateTime createdAt;

  PrescriptionRequestModel({
    required this.prescriptionId,
    required this.userId,
    this.requestedVendors,
    this.acceptedVendor,
    required this.requestAcceptedStatus,
    required this.prescriptionAcceptedStatus,
    required this.prescriptionUrl,
    required this.createdAt,
  });

  /// **🔹 Factory Constructor to Handle JSON Parsing**
  factory PrescriptionRequestModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionRequestModel(
      prescriptionId: json["prescriptionId"].toString(), // Ensure String type
      userId: json["userId"].toString(),
      requestedVendors: (json["requestedVendors"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      acceptedVendor: json["acceptedVendor"]?.toString(),
      requestAcceptedStatus: json["requestAcceptedStatus"] ?? false,
      prescriptionAcceptedStatus: json["prescriptionAcceptedStatus"] ?? "Pending",
      prescriptionUrl: json["prescriptionUrl"].toString(),
      createdAt: _parseDate(json["createdAt"]),
    );
  }

  /// **🔹 Convert Model to JSON**
  Map<String, dynamic> toJson() {
    return {
      "prescriptionId": prescriptionId,
      "userId": userId,
      "requestedVendors": requestedVendors,
      "acceptedVendor": acceptedVendor,
      "requestAcceptedStatus": requestAcceptedStatus,
      "prescriptionAcceptedStatus": prescriptionAcceptedStatus,
      "prescriptionUrl": prescriptionUrl,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  /// **🔹 Helper Function to Handle Different Date Formats**
  static DateTime _parseDate(dynamic date) {
    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date); // Handle timestamp format
    } else if (date is String) {
      return DateTime.parse(date); // Handle ISO 8601 format
    } else {
      throw FormatException("Invalid date format: $date");
    }
  }

  PrescriptionRequestModel copyWith({
    String? prescriptionId,
    String? userId,
    List<String>? requestedVendors,
    String? acceptedVendor,
    bool? requestAcceptedStatus,
    String? prescriptionAcceptedStatus,
    String? prescriptionUrl,
    DateTime? createdAt,
  }) {
    return PrescriptionRequestModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      userId: userId ?? this.userId,
      requestedVendors: requestedVendors ?? this.requestedVendors,
      acceptedVendor: acceptedVendor ?? this.acceptedVendor,
      requestAcceptedStatus: requestAcceptedStatus ?? this.requestAcceptedStatus,
      prescriptionAcceptedStatus: prescriptionAcceptedStatus ?? this.prescriptionAcceptedStatus,
      prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

}
