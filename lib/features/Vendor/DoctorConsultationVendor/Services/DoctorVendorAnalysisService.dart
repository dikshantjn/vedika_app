import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';

class DoctorVendorAnalysisService {
  // Singleton pattern
  static final DoctorVendorAnalysisService _instance = DoctorVendorAnalysisService._internal();
  factory DoctorVendorAnalysisService() => _instance;
  DoctorVendorAnalysisService._internal();

  // Mock data for different time periods
  Map<String, Map<String, dynamic>> _mockData = {
    'Today': {
      'newVsReturningPatients': {
        'new': 8,
        'returning': 12,
        'total': 20,
      },
      'avgTimeToAppointment': 2.5, // days
      'avgTimeToConfirm': 0.8, // hours
      'rebookingPatterns': {
        '15days': 5,
        '30days': 8,
        '60days': 12,
        '90days': 15,
      },
      'noShowsCancellations': {
        'noShows': 2,
        'cancellations': 1,
        'total': 20,
        'percentage': 15.0,
      },
      'peakConsultationHours': [
        {'hour': 9, 'bookings': 3},
        {'hour': 10, 'bookings': 5},
        {'hour': 11, 'bookings': 4},
        {'hour': 12, 'bookings': 2},
        {'hour': 14, 'bookings': 3},
        {'hour': 15, 'bookings': 6},
        {'hour': 16, 'bookings': 4},
        {'hour': 17, 'bookings': 3},
      ],
      'cityAreaDemand': [
        {'city': 'Pune', 'bookings': 12, 'percentage': 60.0},
        {'city': 'Mumbai', 'bookings': 5, 'percentage': 25.0},
        {'city': 'Nagpur', 'bookings': 3, 'percentage': 15.0},
      ],
      'onlineVsOffline': {
        'online': 14,
        'offline': 6,
        'total': 20,
      },
      'seasonalTrends': [
        {'month': 'Jan', 'flu': 8, 'allergy': 3, 'general': 9},
        {'month': 'Feb', 'flu': 6, 'allergy': 4, 'general': 10},
        {'month': 'Mar', 'flu': 4, 'allergy': 7, 'general': 9},
        {'month': 'Apr', 'flu': 2, 'allergy': 12, 'general': 6},
        {'month': 'May', 'flu': 1, 'allergy': 15, 'general': 4},
        {'month': 'Jun', 'flu': 3, 'allergy': 8, 'general': 9},
      ],
      'specialities': [
        {'name': 'General Medicine', 'bookings': 8, 'percentage': 40.0},
        {'name': 'Cardiology', 'bookings': 5, 'percentage': 25.0},
        {'name': 'Dermatology', 'bookings': 4, 'percentage': 20.0},
        {'name': 'Pediatrics', 'bookings': 3, 'percentage': 15.0},
      ],
      'ratingVsAppointments': [
        {'rating': 4.0, 'appointments': 5},
        {'rating': 4.5, 'appointments': 8},
        {'rating': 5.0, 'appointments': 7},
      ],
      'appointmentOutcomes': {
        'completed': 16,
        'rescheduled': 2,
        'cancelled': 2,
        'total': 20,
        'prescriptions': 14,
        'followUps': 8,
      },
      'revenue': {
        'total': 25000,
        'online': 17500,
        'offline': 7500,
        'avgPerConsult': 1250,
      },
      'followUpFunnel': {
        'firstTimePatients': 8,
        'bookedFollowUp': 6,
        'conversionRate': 75.0,
      },
      'aiSuggestions': [
        'Most rebooked patients: 5 patients rebooked within 30 days',
        'Recommend video consult slots at 7PM — peak time observed',
        '90% bookings today were from Pune — run local promo?',
      ],
    },
    'Week': {
      'newVsReturningPatients': {
        'new': 25,
        'returning': 45,
        'total': 70,
      },
      'avgTimeToAppointment': 3.2,
      'avgTimeToConfirm': 1.2,
      'rebookingPatterns': {
        '15days': 18,
        '30days': 25,
        '60days': 35,
        '90days': 42,
      },
      'noShowsCancellations': {
        'noShows': 8,
        'cancellations': 5,
        'total': 70,
        'percentage': 18.6,
      },
      'peakConsultationHours': [
        {'hour': 9, 'bookings': 12},
        {'hour': 10, 'bookings': 18},
        {'hour': 11, 'bookings': 15},
        {'hour': 12, 'bookings': 8},
        {'hour': 14, 'bookings': 10},
        {'hour': 15, 'bookings': 22},
        {'hour': 16, 'bookings': 16},
        {'hour': 17, 'bookings': 12},
      ],
      'cityAreaDemand': [
        {'city': 'Pune', 'bookings': 42, 'percentage': 60.0},
        {'city': 'Mumbai', 'bookings': 18, 'percentage': 25.7},
        {'city': 'Nagpur', 'bookings': 10, 'percentage': 14.3},
      ],
      'onlineVsOffline': {
        'online': 49,
        'offline': 21,
        'total': 70,
      },
      'seasonalTrends': [
        {'month': 'Jan', 'flu': 25, 'allergy': 10, 'general': 35},
        {'month': 'Feb', 'flu': 20, 'allergy': 15, 'general': 35},
        {'month': 'Mar', 'flu': 15, 'allergy': 25, 'general': 30},
        {'month': 'Apr', 'flu': 8, 'allergy': 35, 'general': 27},
        {'month': 'May', 'flu': 5, 'allergy': 40, 'general': 25},
        {'month': 'Jun', 'flu': 12, 'allergy': 30, 'general': 28},
      ],
      'specialities': [
        {'name': 'General Medicine', 'bookings': 28, 'percentage': 40.0},
        {'name': 'Cardiology', 'bookings': 18, 'percentage': 25.7},
        {'name': 'Dermatology', 'bookings': 14, 'percentage': 20.0},
        {'name': 'Pediatrics', 'bookings': 10, 'percentage': 14.3},
      ],
      'ratingVsAppointments': [
        {'rating': 4.0, 'appointments': 18},
        {'rating': 4.5, 'appointments': 25},
        {'rating': 5.0, 'appointments': 27},
      ],
      'appointmentOutcomes': {
        'completed': 57,
        'rescheduled': 8,
        'cancelled': 5,
        'total': 70,
        'prescriptions': 48,
        'followUps': 25,
      },
      'revenue': {
        'total': 87500,
        'online': 61250,
        'offline': 26250,
        'avgPerConsult': 1250,
      },
      'followUpFunnel': {
        'firstTimePatients': 25,
        'bookedFollowUp': 20,
        'conversionRate': 80.0,
      },
      'aiSuggestions': [
        'Most rebooked patients: 18 patients rebooked within 30 days',
        'Peak consultation time: 3-4 PM with 22 bookings',
        '60% bookings this week were from Pune — consider local marketing',
      ],
    },
    'Month': {
      'newVsReturningPatients': {
        'new': 120,
        'returning': 180,
        'total': 300,
      },
      'avgTimeToAppointment': 4.1,
      'avgTimeToConfirm': 1.8,
      'rebookingPatterns': {
        '15days': 85,
        '30days': 120,
        '60days': 150,
        '90days': 180,
      },
      'noShowsCancellations': {
        'noShows': 35,
        'cancellations': 25,
        'total': 300,
        'percentage': 20.0,
      },
      'peakConsultationHours': [
        {'hour': 9, 'bookings': 45},
        {'hour': 10, 'bookings': 65},
        {'hour': 11, 'bookings': 55},
        {'hour': 12, 'bookings': 35},
        {'hour': 14, 'bookings': 40},
        {'hour': 15, 'bookings': 85},
        {'hour': 16, 'bookings': 70},
        {'hour': 17, 'bookings': 55},
      ],
      'cityAreaDemand': [
        {'city': 'Pune', 'bookings': 180, 'percentage': 60.0},
        {'city': 'Mumbai', 'bookings': 75, 'percentage': 25.0},
        {'city': 'Nagpur', 'bookings': 45, 'percentage': 15.0},
      ],
      'onlineVsOffline': {
        'online': 210,
        'offline': 90,
        'total': 300,
      },
      'seasonalTrends': [
        {'month': 'Jan', 'flu': 120, 'allergy': 45, 'general': 135},
        {'month': 'Feb', 'flu': 95, 'allergy': 60, 'general': 145},
        {'month': 'Mar', 'flu': 70, 'allergy': 100, 'general': 130},
        {'month': 'Apr', 'flu': 40, 'allergy': 140, 'general': 120},
        {'month': 'May', 'flu': 25, 'allergy': 160, 'general': 115},
        {'month': 'Jun', 'flu': 55, 'allergy': 120, 'general': 125},
      ],
      'specialities': [
        {'name': 'General Medicine', 'bookings': 120, 'percentage': 40.0},
        {'name': 'Cardiology', 'bookings': 75, 'percentage': 25.0},
        {'name': 'Dermatology', 'bookings': 60, 'percentage': 20.0},
        {'name': 'Pediatrics', 'bookings': 45, 'percentage': 15.0},
      ],
      'ratingVsAppointments': [
        {'rating': 4.0, 'appointments': 75},
        {'rating': 4.5, 'appointments': 120},
        {'rating': 5.0, 'appointments': 105},
      ],
      'appointmentOutcomes': {
        'completed': 240,
        'rescheduled': 35,
        'cancelled': 25,
        'total': 300,
        'prescriptions': 200,
        'followUps': 120,
      },
      'revenue': {
        'total': 375000,
        'online': 262500,
        'offline': 112500,
        'avgPerConsult': 1250,
      },
      'followUpFunnel': {
        'firstTimePatients': 120,
        'bookedFollowUp': 95,
        'conversionRate': 79.2,
      },
      'aiSuggestions': [
        'Most rebooked patients: 85 patients rebooked within 30 days',
        'Peak consultation time: 3-4 PM with 85 bookings',
        '60% bookings this month were from Pune — consider local marketing',
        'Dermatology consultations increased by 25% this month',
      ],
    },
    'Year': {
      'newVsReturningPatients': {
        'new': 1200,
        'returning': 1800,
        'total': 3000,
      },
      'avgTimeToAppointment': 5.2,
      'avgTimeToConfirm': 2.1,
      'rebookingPatterns': {
        '15days': 850,
        '30days': 1200,
        '60days': 1500,
        '90days': 1800,
      },
      'noShowsCancellations': {
        'noShows': 350,
        'cancellations': 250,
        'total': 3000,
        'percentage': 20.0,
      },
      'peakConsultationHours': [
        {'hour': 9, 'bookings': 450},
        {'hour': 10, 'bookings': 650},
        {'hour': 11, 'bookings': 550},
        {'hour': 12, 'bookings': 350},
        {'hour': 14, 'bookings': 400},
        {'hour': 15, 'bookings': 850},
        {'hour': 16, 'bookings': 700},
        {'hour': 17, 'bookings': 550},
      ],
      'cityAreaDemand': [
        {'city': 'Pune', 'bookings': 1800, 'percentage': 60.0},
        {'city': 'Mumbai', 'bookings': 750, 'percentage': 25.0},
        {'city': 'Nagpur', 'bookings': 450, 'percentage': 15.0},
      ],
      'onlineVsOffline': {
        'online': 2100,
        'offline': 900,
        'total': 3000,
      },
      'seasonalTrends': [
        {'month': 'Jan', 'flu': 1200, 'allergy': 450, 'general': 1350},
        {'month': 'Feb', 'flu': 950, 'allergy': 600, 'general': 1450},
        {'month': 'Mar', 'flu': 700, 'allergy': 1000, 'general': 1300},
        {'month': 'Apr', 'flu': 400, 'allergy': 1400, 'general': 1200},
        {'month': 'May', 'flu': 250, 'allergy': 1600, 'general': 1150},
        {'month': 'Jun', 'flu': 550, 'allergy': 1200, 'general': 1250},
      ],
      'specialities': [
        {'name': 'General Medicine', 'bookings': 1200, 'percentage': 40.0},
        {'name': 'Cardiology', 'bookings': 750, 'percentage': 25.0},
        {'name': 'Dermatology', 'bookings': 600, 'percentage': 20.0},
        {'name': 'Pediatrics', 'bookings': 450, 'percentage': 15.0},
      ],
      'ratingVsAppointments': [
        {'rating': 4.0, 'appointments': 750},
        {'rating': 4.5, 'appointments': 1200},
        {'rating': 5.0, 'appointments': 1050},
      ],
      'appointmentOutcomes': {
        'completed': 2400,
        'rescheduled': 350,
        'cancelled': 250,
        'total': 3000,
        'prescriptions': 2000,
        'followUps': 1200,
      },
      'revenue': {
        'total': 3750000,
        'online': 2625000,
        'offline': 1125000,
        'avgPerConsult': 1250,
      },
      'followUpFunnel': {
        'firstTimePatients': 1200,
        'bookedFollowUp': 950,
        'conversionRate': 79.2,
      },
      'aiSuggestions': [
        'Most rebooked patients: 850 patients rebooked within 30 days',
        'Peak consultation time: 3-4 PM with 850 bookings',
        '60% bookings this year were from Pune — consider local marketing',
        'Dermatology consultations increased by 25% this year',
        'Online consultations grew by 30% compared to last year',
      ],
    },
  };

  // Get analytics data for a specific time period
  Future<Map<String, dynamic>> getAnalyticsData(String timeFilter) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    return _mockData[timeFilter] ?? _mockData['Today']!;
  }

  // Get all available time filters
  List<String> getTimeFilters() {
    return ['Today', 'Week', 'Month', 'Year'];
  }

  // Get basic analytics (existing functionality)
  Future<List<Map<String, dynamic>>> getBasicAnalytics() async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return [
      {'month': 'Jan', 'patients': 30, 'appointments': 45},
      {'month': 'Feb', 'patients': 50, 'appointments': 60},
      {'month': 'Mar', 'patients': 40, 'appointments': 55},
      {'month': 'Apr', 'patients': 70, 'appointments': 85},
      {'month': 'May', 'patients': 55, 'appointments': 65},
      {'month': 'Jun', 'patients': 80, 'appointments': 95},
    ];
  }
}
