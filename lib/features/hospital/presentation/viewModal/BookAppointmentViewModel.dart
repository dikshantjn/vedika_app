import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

class BookAppointmentViewModel extends ChangeNotifier {
  HospitalProfile? hospital;
  BedType? selectedBedType;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  String selectedPatientType = "Self";
  String? selectedDoctorId;

  // Getter for total available beds
  int get totalAvailableBeds => hospital?.bedsAvailable ?? 0;

  // Method to update selected hospital
  void selectHospital(HospitalProfile hospital) {
    this.hospital = hospital;
    notifyListeners();
  }

  // Method to update selected bed type
  void selectBedType(BedType bedType) {
    selectedBedType = bedType;
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

  // Method to update selected doctor
  void selectDoctor(String doctorId) {
    selectedDoctorId = doctorId;
    notifyListeners();
  }

  // Method to check if all required fields are filled
  bool isFormComplete() {
    return hospital != null && 
           selectedBedType != null && 
           selectedDate != null && 
           selectedTimeSlot != null;
  }

  // Method to create a new bed booking
  BedBooking createBedBooking(String userId) {
    if (!isFormComplete()) {
      throw Exception('All required fields must be filled');
    }

    // Convert HospitalProfile to Hospital
    final hospitalData = Hospital(
      name: hospital!.name,
      address: hospital!.address,
      city: hospital!.city,
      state: hospital!.state,
      contactNumber: hospital!.contactNumber,
      email: hospital!.email,
    );

    // Convert UserModel to User
    final userData = User(
      userId: userId,
      name: selectedPatientType == "Self" ? hospital!.ownerName : null,
      phoneNumber: hospital!.contactNumber,
      emailId: hospital!.email,
      gender: null,
      photo: null,
    );

    return BedBooking(
      user: userData,
      vendorId: hospital!.vendorId ?? hospital!.generatedId ?? '',
      userId: userId,
      hospital: hospitalData,
      bedType: selectedBedType!.type,
      price: selectedBedType!.price,
      paidAmount: 0.0, // Initial paid amount is 0
      paymentStatus: 'pending', // Initial payment status is pending
      bookingDate: selectedDate!,
      timeSlot: selectedTimeSlot!,
      selectedDoctorId: selectedDoctorId,
      status: 'pending', // Initial booking status is pending
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
