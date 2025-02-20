import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DoctorSelection.dart';

class BookClinicAppointmentViewModel with ChangeNotifier {
  Doctor? selectedDoctor;  // Changed to Doctor object
  String? selectedDate;
  String? selectedTimeSlot;
  String selectedPatientType = "Self";

  // Select Doctor
  void selectDoctor(Doctor doctor) {
    selectedDoctor = doctor;
    notifyListeners();
  }

  // Select Date
  void selectDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  // Select Time Slot
  void selectTimeSlot(String timeSlot) {
    selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  // Select Patient Type (Self or Other)
  void selectPatientType(String type) {
    selectedPatientType = type;
    notifyListeners();
  }

  // Check if the form is complete
  bool isFormComplete() {
    return selectedDoctor != null && selectedDate != null && selectedTimeSlot != null && selectedPatientType.isNotEmpty;
  }
}
