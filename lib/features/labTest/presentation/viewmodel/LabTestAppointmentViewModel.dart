import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabAppointmentModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';

class LabTestAppointmentViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Selected tests
  final List<String> _selectedTests = [];
  List<String> get selectedTests => _selectedTests;
  
  // Date selection
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;
  
  // Time selection
  String? _selectedTime;
  String? get selectedTime => _selectedTime;
  
  // Collection & delivery options
  bool _homeCollectionRequired = false;
  bool get homeCollectionRequired => _homeCollectionRequired;
  
  bool _reportDeliveryAtHome = false;
  bool get reportDeliveryAtHome => _reportDeliveryAtHome;
  
  // Prescription
  File? _prescriptionImage;
  File? get prescriptionImage => _prescriptionImage;
  
  // Submission state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  
  ValueNotifier<String?> dateError = ValueNotifier(null);
  ValueNotifier<String?> timeError = ValueNotifier<String?>(null);
  ValueNotifier<String?> testError = ValueNotifier(null);

  // Toggle Test Selection
  void toggleTestSelection(LabTestModel test) {
    if (selectedTests.contains(test.name)) {
      removeTest(test.name);
    } else {
      addTest(test.name);
    }
    testError.value = selectedTests.isEmpty ? "Please select at least one test" : null;
    notifyListeners();
  }

  // Select Date
  Future<void> selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null) {
      setDate(pickedDate);
      dateError.value = null;
      notifyListeners();
    }
  }

  // Select Time
  Future<void> selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setTime(pickedTime.format(context));
      timeError.value = null;
      notifyListeners();
    }
  }

  // Toggle Home Sample Collection
  void toggleHomeSampleCollection(bool value) {
    _homeCollectionRequired = value;
    notifyListeners();
  }

  // Toggle Report Delivery at Home
  void toggleReportDeliveryAtHome(bool value) {
    _reportDeliveryAtHome = value;
    notifyListeners();
  }

  // Upload Prescription
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setPrescriptionImage(File(pickedFile.path));
      notifyListeners();
    }
  }

  // Add test to selection
  void addTest(String test) {
    if (!_selectedTests.contains(test)) {
      _selectedTests.add(test);
      notifyListeners();
    }
  }
  
  // Remove test from selection
  void removeTest(String test) {
    _selectedTests.remove(test);
    notifyListeners();
  }

  // Set date
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // Set time
  void setTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }
  
  // Set prescription image
  void setPrescriptionImage(File? image) {
    _prescriptionImage = image;
    notifyListeners();
  }
  
  // Validate form
  bool validateForm() {
    bool isValid = true;
    
    testError.value = selectedTests.isEmpty ? "Please select at least one test" : null;
    dateError.value = selectedDate == null ? "Please select a date" : null;
    timeError.value = selectedTime == null ? "Please select a time" : null;

    if (selectedTests.isEmpty || selectedDate == null || selectedTime == null) {
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }
  
  // Reset form
  void resetForm() {
    _selectedTests.clear();
    _selectedDate = null;
    _selectedTime = null;
    _homeCollectionRequired = false;
    _reportDeliveryAtHome = false;
    _prescriptionImage = null;
    notifyListeners();
  }
  
  // Submit appointment
  Future<bool> submitAppointment(DiagnosticCenter center) async {
    if (!validateForm()) {
      return false;
    }
    
    _isSubmitting = true;
    notifyListeners();
    
    try {
      // TODO: Implement the actual API call to book the appointment
      
      // For now, simulate a network request
      await Future.delayed(const Duration(seconds: 2));
      
      // Create a booking object
      final booking = LabTestBooking(
        vendorId: center.vendorId,
        selectedTests: _selectedTests,
        bookingDate: _selectedDate!.toString().split(' ')[0], // Format as YYYY-MM-DD
        bookingTime: _selectedTime,
        homeCollectionRequired: _homeCollectionRequired,
        reportDeliveryAtHome: _reportDeliveryAtHome,
        prescriptionUrl: _prescriptionImage?.path,
        diagnosticCenter: center,
        bookingStatus: 'Pending',
        paymentStatus: 'Pending',
      );
      
      // Reset form after successful booking
      resetForm();
      
      _isSubmitting = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error booking appointment: $e');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void validateTime() {
    if (selectedTime == null) {
      timeError.value = "Please select a time";
    } else {
      timeError.value = null;
    }
  }
}
