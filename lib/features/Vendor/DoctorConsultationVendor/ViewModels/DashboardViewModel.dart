import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isOnline = true;
  String _selectedTimeFilter = 'Today';
  bool _isLoading = false;
  String? _error;

  // Dashboard data
  int totalPatients = 185;
  int totalAppointments = 27;
  double rating = 4.7;
  int reviewCount = 32;
  int todayAppointments = 5;
  List<Map<String, dynamic>> analyticsData = [
    {'month': 'Jan', 'patients': 30, 'appointments': 45},
    {'month': 'Feb', 'patients': 50, 'appointments': 60},
    {'month': 'Mar', 'patients': 40, 'appointments': 55},
    {'month': 'Apr', 'patients': 70, 'appointments': 85},
    {'month': 'May', 'patients': 55, 'appointments': 65},
    {'month': 'Jun', 'patients': 80, 'appointments': 95},
  ];

  // Getters
  bool get isOnline => _isOnline;
  String get selectedTimeFilter => _selectedTimeFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get timeFilters => ['Today', 'Week', 'Month', 'Year'];

  // Methods to update state
  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  void setTimeFilter(String filter) {
    if (_selectedTimeFilter != filter) {
      _selectedTimeFilter = filter;
      fetchDashboardData();
      notifyListeners();
    }
  }

  // Method to fetch dashboard data
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update data based on selected filter (simulated)
      switch (_selectedTimeFilter) {
        case 'Today':
          totalPatients = 185;
          totalAppointments = 27;
          break;
        case 'Week':
          totalPatients = 210;
          totalAppointments = 45;
          break;
        case 'Month':
          totalPatients = 350;
          totalAppointments = 120;
          break;
        case 'Year':
          totalPatients = 1250;
          totalAppointments = 950;
          break;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load dashboard data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Initialize the dashboard
  void init() {
    fetchDashboardData();
  }
} 