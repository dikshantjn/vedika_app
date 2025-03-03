import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabAppointmentModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';

class LabTestAppointmentViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<LabTestModel> selectedTests = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isHomeSampleCollection = false;
  File? prescriptionImage;

  ValueNotifier<String?> dateError = ValueNotifier(null);
  ValueNotifier<String?> timeError = ValueNotifier<String?>(null);
  ValueNotifier<String?> testError = ValueNotifier(null);

  // Toggle Test Selection
  void toggleTestSelection(LabTestModel test) {
    if (selectedTests.contains(test)) {
      selectedTests.remove(test);
    } else {
      selectedTests.add(test);
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
      selectedDate = pickedDate;
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
      selectedTime = pickedTime;
      timeError.value = null;
      notifyListeners();
    }
  }

  // Toggle Home Sample Collection
  void toggleHomeSampleCollection(bool value) {
    isHomeSampleCollection = value;
    notifyListeners();
  }

  // Upload Prescription
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      prescriptionImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Validate Fields Before Proceeding
  bool validateFields() {
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

  // Confirm Appointment
  void confirmAppointment(BuildContext context, LabModel lab) {
    if (!validateFields()) return;

    final appointment = LabAppointmentModel(
      labId: lab.id,
      labName: lab.name,
      address: lab.address,
      contact: lab.contact,
      selectedTests: selectedTests.map((test) => test.name).toList(),
      selectedDate: selectedDate!,
      selectedTime: selectedTime!.format(context),
      isHomeSampleCollection: isHomeSampleCollection,
      prescriptionImage: prescriptionImage,
    );

    Navigator.pushNamed(context, '/labPayment', arguments: appointment);
  }

  void validateTime() {
    if (selectedTime == null) {
      timeError.value = "Please select a time";
    } else {
      timeError.value = null;
    }
  }
}
