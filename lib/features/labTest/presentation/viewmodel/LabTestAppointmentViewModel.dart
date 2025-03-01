import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabAppointmentModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';

class LabTestAppointmentViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<LabTestModel> selectedTests = []; // Change from List<String> to List<LabTestModel>
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isHomeSampleCollection = false;
  File? prescriptionImage;

  // Select Test
  void toggleTestSelection(LabTestModel test) {
    if (selectedTests.contains(test)) {
      selectedTests.remove(test);
    } else {
      selectedTests.add(test);
    }
    notifyListeners();
  }

  // Select Date
  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (pickedDate != null) {
      selectedDate = pickedDate;
      notifyListeners();
    }
  }

  // Select Time
  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      selectedTime = pickedTime;
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

  // Confirm Appointment
  void confirmAppointment(BuildContext context, LabModel lab) {
    if (formKey.currentState!.validate() && selectedTests.isNotEmpty && selectedDate != null && selectedTime != null) {
      LabAppointmentModel appointment = LabAppointmentModel(
        labId: lab.id,
        labName: lab.name,
        address: lab.address,
        contact: lab.contact,
        selectedTests: selectedTests.map((test) => test.name).toList(), // Map to names
        selectedDate: selectedDate!,
        selectedTime: selectedTime!.format(context),
        isHomeSampleCollection: isHomeSampleCollection,
        prescriptionImage: prescriptionImage,
      );

      Navigator.pushNamed(
        context,
        '/labPayment',
        arguments: appointment,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all details")));
    }
  }
}

