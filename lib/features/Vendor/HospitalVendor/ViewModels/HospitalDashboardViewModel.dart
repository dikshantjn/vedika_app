import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

class HospitalDashboardViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool _isActive = false;
  bool get isActive => _isActive;
  
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
  
  // Static hospital profile data
  HospitalProfile? get hospitalProfile => HospitalProfile(
    name: 'City General Hospital',
    gstNumber: 'GST123456789',
    panNumber: 'PAN123456789',
    address: '123 Medical Street',
    landmark: 'Near City Mall',
    ownerName: 'Dr. John Smith',
    certifications: [
      {'name': 'ISO 9001', 'year': '2020'},
      {'name': 'NABH', 'year': '2021'},
    ],
    licenses: [
      {'name': 'Medical License', 'number': 'ML12345'},
      {'name': 'Pharmacy License', 'number': 'PL67890'},
    ],
    specialityTypes: ['Cardiology', 'Neurology', 'Orthopedics'],
    servicesOffered: ['Emergency Care', 'Surgery', 'Diagnostics'],
    bedsAvailable: 100,
    doctors: [
      {
        'name': 'Dr. Sarah Johnson',
        'speciality': 'Cardiology',
        'experience': '15 years',
      },
      {
        'name': 'Dr. Michael Brown',
        'speciality': 'Neurology',
        'experience': '12 years',
      },
    ],
    workingTime: '24/7',
    workingDays: 'Monday to Sunday',
    contactNumber: '+91 9876543210',
    email: 'info@cityhospital.com',
    website: 'www.cityhospital.com',
    hasLiftAccess: true,
    hasParking: true,
    providesAmbulanceService: true,
    about: 'City General Hospital is a leading healthcare provider with state-of-the-art facilities and experienced medical professionals. We are committed to providing the best healthcare services to our patients.',
    hasWheelchairAccess: true,
    providesOnlineConsultancy: true,
    feesRange: '₹500 - ₹5000',
    otherFacilities: ['Cafeteria', 'Pharmacy', 'ATM'],
    insuranceCompanies: ['ICICI Lombard', 'HDFC Ergo', 'Bajaj Allianz'],
    photos: [
      {'url': 'hospital1.jpg', 'caption': 'Main Building'},
      {'url': 'hospital2.jpg', 'caption': 'Emergency Ward'},
    ],
    state: 'Maharashtra',
    city: 'Mumbai',
    pincode: '400001',
    isActive: true,
  );

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
    
    try {
      // Simulate API calls
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
    } catch (e) {
      _error = 'Failed to load dashboard data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleActiveStatus() async {
    _isActive = !_isActive;
    notifyListeners();
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