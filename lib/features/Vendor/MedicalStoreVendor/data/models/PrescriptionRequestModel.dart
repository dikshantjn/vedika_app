import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

class PrescriptionRequestModel {
  final String prescriptionId;
  final UserModel user;
  final List<String>? requestedVendors;
  final String? acceptedVendor;
  final bool requestAcceptedStatus;
  final String prescriptionAcceptedStatus;
  final String prescriptionUrl;
  final DateTime createdAt;

  PrescriptionRequestModel({
    required this.prescriptionId,
    required this.user,
    this.requestedVendors,
    this.acceptedVendor,
    required this.requestAcceptedStatus,
    required this.prescriptionAcceptedStatus,
    required this.prescriptionUrl,
    required this.createdAt,
  });

  factory PrescriptionRequestModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionRequestModel(
      prescriptionId: json["prescriptionId"].toString(),
      user: json["User"] != null ? UserModel.fromJson(json["User"]) : UserModel.empty(), // ✅ Corrected User Mapping
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


  Map<String, dynamic> toJson() {
    return {
      "prescriptionId": prescriptionId,
      "user": user.toJson(),
      "requestedVendors": requestedVendors,
      "acceptedVendor": acceptedVendor,
      "requestAcceptedStatus": requestAcceptedStatus,
      "prescriptionAcceptedStatus": prescriptionAcceptedStatus,
      "prescriptionUrl": prescriptionUrl,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  /// **✅ Add copyWith Method**
  PrescriptionRequestModel copyWith({
    String? prescriptionId,
    UserModel? user,
    List<String>? requestedVendors,
    String? acceptedVendor,
    bool? requestAcceptedStatus,
    String? prescriptionAcceptedStatus,
    String? prescriptionUrl,
    DateTime? createdAt,
  }) {
    return PrescriptionRequestModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      user: user ?? this.user,
      requestedVendors: requestedVendors ?? this.requestedVendors,
      acceptedVendor: acceptedVendor ?? this.acceptedVendor,
      requestAcceptedStatus: requestAcceptedStatus ?? this.requestAcceptedStatus,
      prescriptionAcceptedStatus: prescriptionAcceptedStatus ?? this.prescriptionAcceptedStatus,
      prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date);
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw FormatException("Invalid date format: $date");
    }
  }
}
