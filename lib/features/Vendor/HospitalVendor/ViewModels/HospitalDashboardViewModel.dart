import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class HospitalDashboardViewModel extends ChangeNotifier {
  final HospitalVendorService _hospitalService = HospitalVendorService();
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();
  String? _vendorId;

  Future<String?> getVendorId() async {
    return await _loginService.getVendorId();
  }
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool _isActive = false;
  bool get isActive => _isActive;
  
  HospitalProfile? _hospitalProfile;
  HospitalProfile? get hospitalProfile => _hospitalProfile;
  
  // Appointments Data
  List<Appointment> _todayAppointments = [];
  List<Appointment> get todayAppointments => _todayAppointments;
  
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  
  List<Appointment> _pastAppointments = [];
  List<Appointment> get pastAppointments => _pastAppointments;
  
  // Statistics
  int _totalPatients = 0;
  int get totalPatients => _totalPatients;
  
  int _totalEnquiries = 0;
  int get totalEnquiries => _totalEnquiries;
  
  int _totalBookings = 0;
  int get totalBookings => _totalBookings;
  
  // Footfall Data
  Map<String, int> _dailyFootfall = {};
  Map<String, int> get dailyFootfall => _dailyFootfall;
  
  Map<String, int> _weeklyFootfall = {};
  Map<String, int> get weeklyFootfall => _weeklyFootfall;
  
  String _peakHour = '';
  String get peakHour => _peakHour;
  
  String _peakDay = '';
  String get peakDay => _peakDay;
  
  // Demographics
  Map<String, int> _ageGroupDistribution = {};
  Map<String, int> get ageGroupDistribution => _ageGroupDistribution;
  
  Map<String, int> _healthConditions = {};
  Map<String, int> get healthConditions => _healthConditions;
  
  // Time Period for Analytics
  String _selectedTimePeriod = 'week';
  String get selectedTimePeriod => _selectedTimePeriod;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateTimePeriod(String period) {
    _selectedTimePeriod = period;
    notifyListeners();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    // Get vendor ID from storage
    _vendorId = await getVendorId();
    print("🔹 Fetching Dashboard Data - Vendor ID: $_vendorId");
    
    if (_vendorId == null) {
      print("❌ Error: Vendor ID is null");
      _error = 'Vendor ID not found';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Get current vendor status
      print("🔹 Fetching Current Vendor Status...");
      _isActive = await _vendorService.getVendorStatus(_vendorId!);
      print("✅ Current Vendor Status: $_isActive");
      
      print("🔹 Fetching Hospital Profile...");
      // Fetch hospital profile
      _hospitalProfile = await _hospitalService.getHospitalProfile(_vendorId!);
      print("✅ Hospital Profile Fetched: ${_hospitalProfile?.name}");
      print("✅ Hospital Profile Data: ${_hospitalProfile?.toJson()}");
      
      // Simulate API calls for other data
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock data for demonstration
      _todayAppointments = [
        Appointment(
          id: '1',
          patientName: 'John Doe',
          date: '2024-03-20',
          time: '10:00 AM',
          status: 'confirmed',
        ),
        Appointment(
          id: '2',
          patientName: 'Jane Smith',
          date: '2024-03-20',
          time: '02:30 PM',
          status: 'pending',
        ),
      ];
      
      _upcomingAppointments = [
        Appointment(
          id: '3',
          patientName: 'Robert Johnson',
          date: '2024-03-21',
          time: '11:00 AM',
          status: 'confirmed',
        ),
      ];
      
      _pastAppointments = [
        Appointment(
          id: '4',
          patientName: 'Emily Davis',
          date: '2024-03-19',
          time: '09:00 AM',
          status: 'completed',
        ),
      ];
      
      _totalPatients = 150;
      _totalEnquiries = 45;
      _totalBookings = 75;
      
      _dailyFootfall = {
        '9 AM': 15,
        '10 AM': 25,
        '11 AM': 30,
        '12 PM': 20,
        '1 PM': 10,
        '2 PM': 25,
        '3 PM': 35,
        '4 PM': 30,
        '5 PM': 20,
      };
      
      _weeklyFootfall = {
        'Mon': 120,
        'Tue': 150,
        'Wed': 180,
        'Thu': 160,
        'Fri': 140,
        'Sat': 200,
        'Sun': 100,
      };
      
      _peakHour = '3 PM';
      _peakDay = 'Saturday';
      
      _ageGroupDistribution = {
        '0-18': 20,
        '19-30': 35,
        '31-45': 45,
        '46-60': 30,
        '60+': 20,
      };
      
      _healthConditions = {
        'Cardiac': 25,
        'Neurological': 20,
        'Orthopedic': 30,
        'Respiratory': 15,
        'Gastrointestinal': 20,
        'Other': 40,
      };
      
      _error = null;
      print("✅ Dashboard Data Loaded Successfully");
    } catch (e, stackTrace) {
      print("❌ Error fetching dashboard data: $e");
      print("❌ Stack Trace: $stackTrace");
      _error = 'Failed to load dashboard data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
      print("🔹 Dashboard Loading State: $_isLoading");
      print("🔹 Hospital Profile State: ${_hospitalProfile?.name ?? 'null'}");
      print("🔹 Current Vendor Status: $_isActive");
    }
  }

  Future<void> toggleActiveStatus() async {
    try {
      print("🔄 Toggling Vendor Status...");
      
      // Get vendor ID if not already available
      if (_vendorId == null) {
        _vendorId = await getVendorId();
        if (_vendorId == null) {
          print("❌ Error: Vendor ID is null during toggle");
          return;
        }
      }

      // Call the toggle status API
      final newStatus = await _vendorService.toggleVendorStatus(_vendorId!);
      print("✅ Vendor Status Toggled: $newStatus");
      
      // Update local state
      _isActive = newStatus;
      notifyListeners();
      
      // If we have a hospital profile, update its active status
      if (_hospitalProfile != null) {
        _hospitalProfile = _hospitalProfile!.copyWith(isActive: newStatus);
      }
      
      print("✅ Local State Updated - isActive: $_isActive");
      
      // Verify the new status matches the server
      final verifiedStatus = await _vendorService.getVendorStatus(_vendorId!);
      print("✅ Verified Server Status: $verifiedStatus");
      
      if (verifiedStatus != newStatus) {
        print("⚠️ Status mismatch detected. Updating to server status.");
        _isActive = verifiedStatus;
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error toggling vendor status: $e");
      // Revert the switch if the API call fails
      _isActive = !_isActive;
      notifyListeners();
    }
  }

  Future<void> acceptAppointment(String appointmentId) async {
    final index = _todayAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _todayAppointments[index] = _todayAppointments[index].copyWith(
        status: 'confirmed',
      );
      notifyListeners();
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    final index = _todayAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _todayAppointments[index] = _todayAppointments[index].copyWith(
        status: 'completed',
      );
      notifyListeners();
    }
  }

  // Add a method to refresh the hospital profile
  Future<void> refreshHospitalProfile() async {
    print("🔄 Refreshing Hospital Profile...");
    try {
      _vendorId = await getVendorId();
      if (_vendorId == null) {
        print("❌ Error: Vendor ID is null during refresh");
        return;
      }
      
      _hospitalProfile = await _hospitalService.getHospitalProfile(_vendorId!);
      print("✅ Hospital Profile Refreshed: ${_hospitalProfile?.name}");
      notifyListeners();
    } catch (e) {
      print("❌ Error refreshing hospital profile: $e");
    }
  }

  Future<void> updateBedAvailability(String hospitalId, int availableBeds) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _hospitalService.updateBedAvailability(hospitalId, availableBeds);
      
      // Refresh the hospital data to get updated bed availability
      await fetchDashboardData();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

class Appointment {
  final String id;
  final String patientName;
  final String date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
  });

  Appointment copyWith({
    String? id,
    String? patientName,
    String? date,
    String? time,
    String? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
} 