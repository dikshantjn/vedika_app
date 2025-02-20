import 'package:flutter/material.dart';

class BookAppointmentViewModel extends ChangeNotifier {
  Map<String, dynamic>? selectedDoctor;
  String? selectedTimeSlot;
  DateTime? selectedDate;
  String selectedPatientType = "Self";

  // Method to update selected doctor
  void selectDoctor(Map<String, dynamic> doctor) {
    selectedDoctor = doctor;
    selectedTimeSlot = null;
    notifyListeners();
  }

  // Method to update selected time slot
  void selectTimeSlot(String time) {
    selectedTimeSlot = time;
    notifyListeners();
  }

  // Method to update selected patient type
  void selectPatientType(String type) {
    selectedPatientType = type;
    notifyListeners();
  }

  // Method to update selected date
  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // Method to check if all fields are filled
  bool isFormComplete() {
    return selectedDoctor != null && selectedTimeSlot != null && selectedDate != null;
  }
}
