import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'dart:convert';

class ClinicAppointment {
  final String clinicAppointmentId;
  final String doctorId;
  final String userId;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final bool isOnline;
  final DateTime date;
  final String time; // Format: "HH:MM"
  final double paidAmount;
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final UserModel? user; // The patient user details

  final String vendorId;
  final DateTime? adminUpdatedAt;
  final String userResponseStatus; // accepted, declined, pending
  final String? meetingUrl;

  final DoctorClinicProfile? doctor;
  final String? notes;
  final List<String> attachments;
  final String? cancelReason;
  final String? rescheduledBy;
  final DateTime? rescheduledAt;
  final String? doctorAttendanceStatus;
  final String? userAttendanceStatus;

  ClinicAppointment({
    required this.clinicAppointmentId,
    required this.doctorId,
    required this.userId,
    required this.status,
    required this.isOnline,
    required this.date,
    required this.time,
    required this.paidAmount,
    required this.paymentStatus,
    this.user,
    required this.vendorId,
    this.adminUpdatedAt,
    required this.userResponseStatus,
    this.meetingUrl,
    this.doctor,
    this.notes,
    required this.attachments,
    this.cancelReason,
    this.rescheduledBy,
    this.rescheduledAt,
    this.doctorAttendanceStatus,
    this.userAttendanceStatus,
  });

  factory ClinicAppointment.fromJson(Map<String, dynamic> json) {
    List<String> parsedAttachments = const [];
    final dynamic attachmentsJson = json['attachments'];
    if (attachmentsJson is List) {
      parsedAttachments = attachmentsJson.map((e) => e.toString()).toList();
    } else if (attachmentsJson is String && attachmentsJson.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(attachmentsJson);
        if (decoded is List) {
          parsedAttachments = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return ClinicAppointment(
      clinicAppointmentId: json['clinicAppointmentId'],
      doctorId: json['doctorId'],
      userId: json['userId'],
      status: json['status'],
      isOnline: json['isOnline'],
      date: json['date'] is DateTime
          ? json['date']
          : DateTime.parse(json['date']),
      time: json['time'],
      paidAmount: json['paidAmount'].toDouble(),
      paymentStatus: json['paymentStatus'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      vendorId: json['vendorId'],
      adminUpdatedAt: json['adminUpdatedAt'] != null
          ? DateTime.parse(json['adminUpdatedAt'])
          : null,
      userResponseStatus: json['userResponseStatus'],
      meetingUrl: json['meetingUrl'],
      doctor: json['doctor'] != null
          ? DoctorClinicProfile.fromJson(json['doctor'])
          : null,
      notes: json['notes'],
      attachments: parsedAttachments,
      cancelReason: json['cancelReason'],
      rescheduledBy: json['rescheduledBy'],
      rescheduledAt: json['rescheduledAt'] != null
          ? DateTime.parse(json['rescheduledAt'])
          : null,
      doctorAttendanceStatus: json['doctorAttendanceStatus'],
      userAttendanceStatus: json['userAttendanceStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinicAppointmentId': clinicAppointmentId,
      'doctorId': doctorId,
      'userId': userId,
      'status': status,
      'isOnline': isOnline,
      'date': date.toIso8601String(),
      'time': time,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus,
      'user': user?.toJson(),
      'vendorId': vendorId,
      'adminUpdatedAt': adminUpdatedAt?.toIso8601String(),
      'userResponseStatus': userResponseStatus,
      'meetingUrl': meetingUrl,
      'doctor': doctor?.toJson(),
      'notes': notes,
      'attachments': attachments,
      'cancelReason': cancelReason,
      'rescheduledBy': rescheduledBy,
      'rescheduledAt': rescheduledAt?.toIso8601String(),
      'doctorAttendanceStatus': doctorAttendanceStatus,
      'userAttendanceStatus': userAttendanceStatus,
    };
  }

  ClinicAppointment copyWith({
    String? clinicAppointmentId,
    String? doctorId,
    String? userId,
    String? status,
    bool? isOnline,
    DateTime? date,
    String? time,
    double? paidAmount,
    String? paymentStatus,
    UserModel? user,
    String? vendorId,
    DateTime? adminUpdatedAt,
    String? userResponseStatus,
    String? meetingUrl,
    DoctorClinicProfile? doctor,
    String? notes,
    List<String>? attachments,
    String? cancelReason,
    String? rescheduledBy,
    DateTime? rescheduledAt,
    String? doctorAttendanceStatus,
    String? userAttendanceStatus,
  }) {
    return ClinicAppointment(
      clinicAppointmentId: clinicAppointmentId ?? this.clinicAppointmentId,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      date: date ?? this.date,
      time: time ?? this.time,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      user: user ?? this.user,
      vendorId: vendorId ?? this.vendorId,
      adminUpdatedAt: adminUpdatedAt ?? this.adminUpdatedAt,
      userResponseStatus: userResponseStatus ?? this.userResponseStatus,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      doctor: doctor ?? this.doctor,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      cancelReason: cancelReason ?? this.cancelReason,
      rescheduledBy: rescheduledBy ?? this.rescheduledBy,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
      doctorAttendanceStatus: doctorAttendanceStatus ?? this.doctorAttendanceStatus,
      userAttendanceStatus: userAttendanceStatus ?? this.userAttendanceStatus,
    );
  }
}
