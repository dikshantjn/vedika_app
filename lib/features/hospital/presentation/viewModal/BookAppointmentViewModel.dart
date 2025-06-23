import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/Ward.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/WardService.dart';

class BookAppointmentViewModel extends ChangeNotifier {
  final WardService _wardService = WardService();
  
  HospitalProfile? hospital;
  Ward? selectedWard;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  String selectedPatientType = "Self";
  String? selectedDoctorId;
  
  List<Ward> _wards = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Ward> get wards => _wards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalAvailableBeds => hospital?.bedsAvailable ?? 0;

  // Method to update selected hospital and fetch wards
  Future<void> selectHospital(HospitalProfile hospital) async {
    this.hospital = hospital;
    await fetchWards();
    notifyListeners();
  }

  // Method to fetch wards
  Future<void> fetchWards() async {
    if (hospital?.vendorId == null && hospital?.generatedId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vendorId = hospital!.vendorId ?? hospital!.generatedId!;
      _wards = await _wardService.getWards(vendorId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load wards: $e';
      _wards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to update selected ward
  void selectWard(Ward ward) {
    selectedWard = ward;
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
           selectedWard != null && 
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
      name: selectedPatientType == "Self" ? "Self" : null,
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
      wardId: selectedWard!.wardId,
      bedType: selectedWard!.wardType,
      price: selectedWard!.pricePerDay,
      paidAmount: 0.0,
      paymentStatus: 'pending',
      bookingDate: selectedDate!,
      timeSlot: selectedTimeSlot!,
      selectedDoctorId: selectedDoctorId,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
