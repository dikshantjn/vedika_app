import 'dart:io';

class LabAppointmentModel {
  final String labId;
  final String labName;
  final String address;
  final String contact;
  final List<String> selectedTests;
  final DateTime selectedDate;
  final String selectedTime;
  final bool isHomeSampleCollection;
  final File? prescriptionImage;

  LabAppointmentModel({
    required this.labId,
    required this.labName,
    required this.address,
    required this.contact,
    required this.selectedTests,
    required this.selectedDate,
    required this.selectedTime,
    required this.isHomeSampleCollection,
    this.prescriptionImage,
  });
}
