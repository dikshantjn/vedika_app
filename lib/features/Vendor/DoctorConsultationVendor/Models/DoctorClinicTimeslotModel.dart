import 'dart:convert';

class DoctorClinicTimeslotModel {
  final String? timeSlotID;
  final String vendorId;
  final String day;
  final String startTime;
  final String endTime;
  final int intervalMinutes;
  final List<String> generatedSlots;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorClinicTimeslotModel({
    this.timeSlotID,
    required this.vendorId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.intervalMinutes,
    this.generatedSlots = const [],
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  DoctorClinicTimeslotModel copyWith({
    String? timeSlotID,
    String? vendorId,
    String? day,
    String? startTime,
    String? endTime,
    int? intervalMinutes,
    List<String>? generatedSlots,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorClinicTimeslotModel(
      timeSlotID: timeSlotID ?? this.timeSlotID,
      vendorId: vendorId ?? this.vendorId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      generatedSlots: generatedSlots ?? this.generatedSlots,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Generate time slots based on start time, end time, and interval
  List<String> generateTimeSlots() {
    List<String> slots = [];

    try {
      // Parse start time
      final startParts = startTime.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      // Parse end time
      final endParts = endTime.split(':');
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      // Convert to minutes since midnight for easier calculation
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      // Generate slots
      for (int currentMinutes = startMinutes;
           currentMinutes < endMinutes;
           currentMinutes += intervalMinutes) {
        final hour = (currentMinutes ~/ 60).toString().padLeft(2, '0');
        final minute = (currentMinutes % 60).toString().padLeft(2, '0');
        slots.add('$hour:$minute');
      }
    } catch (e) {
      print('Error generating time slots: $e');
    }

    return slots;
  }

  /// Validate timeslot data
  Map<String, String> validate() {
    final Map<String, String> errors = {};

    if (day.isEmpty) {
      errors['day'] = 'Please select a day';
    }

    if (startTime.isEmpty) {
      errors['startTime'] = 'Please enter start time';
    }

    if (endTime.isEmpty) {
      errors['endTime'] = 'Please enter end time';
    }

    if (intervalMinutes <= 0) {
      errors['intervalMinutes'] = 'Interval must be greater than 0';
    }

    // Validate time format and logical consistency
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      try {
        final startParts = startTime.split(':');
        final endParts = endTime.split(':');

        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        if (startMinutes >= endMinutes) {
          errors['timeRange'] = 'End time must be after start time';
        }

        if ((endMinutes - startMinutes) < intervalMinutes) {
          errors['intervalMinutes'] = 'Interval is too large for the time range';
        }
      } catch (e) {
        errors['timeFormat'] = 'Invalid time format';
      }
    }

    return errors;
  }

  factory DoctorClinicTimeslotModel.fromJson(Map<String, dynamic> json) {
    try {
      return DoctorClinicTimeslotModel(
        timeSlotID: json['timeSlotID']?.toString() ?? json['timeSlotId']?.toString() ?? json['id']?.toString(),
        vendorId: json['vendorId']?.toString() ?? '',
        day: json['day']?.toString() ?? '',
        startTime: json['startTime']?.toString() ?? '',
        endTime: json['endTime']?.toString() ?? '',
        intervalMinutes: json['intervalMinutes'] is int
            ? json['intervalMinutes']
            : int.tryParse(json['intervalMinutes']?.toString() ?? '30') ?? 30,
        generatedSlots: json['generatedSlots'] is List
            ? List<String>.from(json['generatedSlots'])
            : json['generatedSlots']?.toString()?.split(',') ?? [],
        isActive: json['isActive'] is bool
            ? json['isActive']
            : json['isActive']?.toString()?.toLowerCase() == 'true' ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
      print('Error parsing DoctorClinicTimeslotModel: $e');
      return DoctorClinicTimeslotModel(
        vendorId: '',
        day: '',
        startTime: '',
        endTime: '',
        intervalMinutes: 30,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlotID': timeSlotID,
      'vendorId': vendorId,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'intervalMinutes': intervalMinutes,
      'generatedSlots': generatedSlots,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DoctorClinicTimeslotModel(timeSlotID: $timeSlotID, vendorId: $vendorId, day: $day, startTime: $startTime, endTime: $endTime, intervalMinutes: $intervalMinutes, slots: ${generatedSlots.length})';
  }
}
