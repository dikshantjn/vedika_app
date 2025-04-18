import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/Appointment.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAppointments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      _appointments = [
        Appointment(
          id: 'APT001',
          patientName: 'John Doe',
          phoneNumber: '+91 9876543210',
          address: '123, Main Street, City',
          appointmentTime: '10:00 AM, 15 Mar 2024',
          status: 'pending',
        ),
        Appointment(
          id: 'APT002',
          patientName: 'Jane Smith',
          phoneNumber: '+91 9876543211',
          address: '456, Park Avenue, City',
          appointmentTime: '11:00 AM, 15 Mar 2024',
          status: 'accepted',
        ),
      ];
    } catch (e) {
      _error = 'Failed to fetch appointments. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _appointments = _appointments.map((appointment) {
        if (appointment.id == appointmentId) {
          return appointment.copyWith(
            status: 'accepted',
            isProcessing: false,
          );
        }
        return appointment;
      }).toList();
    } catch (e) {
      _error = 'Failed to accept appointment. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _appointments = _appointments.map((appointment) {
        if (appointment.id == appointmentId) {
          return appointment.copyWith(
            status: 'completed',
            isProcessing: false,
          );
        }
        return appointment;
      }).toList();
    } catch (e) {
      _error = 'Failed to process appointment. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 