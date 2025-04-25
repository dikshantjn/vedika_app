import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/ClinicAppointmentOrderService.dart';

enum ClinicAppointmentFetchState { initial, loading, loaded, error }

class ClinicAppointmentViewModel extends ChangeNotifier {
  final ClinicAppointmentOrderService _service = ClinicAppointmentOrderService();
  
  List<ClinicAppointment> _appointments = [];
  List<ClinicAppointment> get appointments => _appointments;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  ClinicAppointmentFetchState _fetchState = ClinicAppointmentFetchState.initial;
  ClinicAppointmentFetchState get fetchState => _fetchState;
  
  bool _isActionInProgress = false;
  bool get isActionInProgress => _isActionInProgress;
  
  // Filter appointments by status
  List<ClinicAppointment> getAppointmentsByStatus(String status) {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == status.toLowerCase()).toList();
  }
  
  // Get upcoming appointments (pending, confirmed)
  List<ClinicAppointment> get upcomingAppointments {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == 'pending' || 
      appointment.status.toLowerCase() == 'confirmed').toList();
  }
  
  // Get completed appointments
  List<ClinicAppointment> get completedAppointments {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == 'completed').toList();
  }
  
  // Get cancelled appointments
  List<ClinicAppointment> get cancelledAppointments {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == 'cancelled').toList();
  }
  
  // Fetch all clinic appointments for the current user
  Future<void> fetchUserClinicAppointments() async {
    if (_fetchState == ClinicAppointmentFetchState.loading) return;
    
    _fetchState = ClinicAppointmentFetchState.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final appointments = await _service.getUserClinicAppointments();
      _appointments = appointments;
      _fetchState = ClinicAppointmentFetchState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _fetchState = ClinicAppointmentFetchState.error;
      print('Error fetching clinic appointments: $e');
    }
    
    notifyListeners();
  }
  
  // Cancel a clinic appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    if (_isActionInProgress) return false;
    
    _isActionInProgress = true;
    notifyListeners();
    
    try {
      final result = await _service.cancelClinicAppointment(appointmentId);
      
      if (result) {
        // Update local list after successful cancellation
        await fetchUserClinicAppointments();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error cancelling appointment: $e');
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }
  
  // Refresh appointments data
  Future<void> refreshAppointments() async {
    return fetchUserClinicAppointments();
  }
  
  // Get current user from appointments (if available)
  UserModel? getCurrentUser() {
    if (_appointments.isNotEmpty && _appointments.first.user != null) {
      return _appointments.first.user;
    }
    return null;
  }
} 