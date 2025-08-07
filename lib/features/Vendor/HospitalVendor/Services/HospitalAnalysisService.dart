

class HospitalAnalysisService {
  // Mock data for different time periods
  static final Map<String, Map<String, dynamic>> _timePeriodData = {
    'day': {
      'stats': {
        'totalPatients': 45,
        'totalInquiries': 12,
        'totalBookings': 28,
        'totalBedRequests': 35,
        'confirmedBedBookings': 25,
        'totalBedRevenue': 125000,
        'avgTimeToConfirm': '1.5 hrs',
        'bedOccupancyRate': 78,
      },
      'requests': [
        {
          'patientName': 'Rahul Sharma',
          'bedType': 'General Ward',
          'status': 'Confirmed',
          'time': '09:30 AM',
          'date': 'Today',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Priya Patel',
          'bedType': 'ICU',
          'status': 'Pending',
          'time': '02:15 PM',
          'date': 'Today',
          'statusColor': 0xFFF59E0B,
        },
        {
          'patientName': 'Amit Kumar',
          'bedType': 'Private Room',
          'status': 'Confirmed',
          'time': '11:00 AM',
          'date': 'Today',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Sneha Singh',
          'bedType': 'Semi-Private',
          'status': 'Cancelled',
          'time': '03:45 PM',
          'date': 'Today',
          'statusColor': 0xFFEF4444,
        },
      ],
      'footfall': {
        'peakHour': '2 PM',
        'peakDay': 'Today',
        'chartData': [15, 25, 30, 35, 40, 45, 50, 45, 40, 35, 30, 25],
        'chartLabels': ['9AM', '10AM', '11AM', '12PM', '1PM', '2PM', '3PM', '4PM', '5PM', '6PM', '7PM', '8PM'],
      },
      'demographics': {
        'ageGroups': {
          '0-18': 15,
          '19-30': 25,
          '31-45': 35,
          '46-60': 20,
          '60+': 5,
        },
        'healthConditions': {
          'Cardiac': 20,
          'Neurological': 15,
          'Orthopedic': 25,
          'Respiratory': 10,
          'Gastrointestinal': 15,
          'Other': 15,
        },
        'genderDistribution': {
          'Male': 55,
          'Female': 45,
        },
      },
      'bedAnalytics': {
        'occupancy': {
          'General': 75,
          'Semi-Private': 68,
          'Private': 92,
          'ICU': 85,
        },
        'demand': {
          'General': 35,
          'Semi-Private': 28,
          'Private': 22,
          'ICU': 15,
        },
        'funnel': {
          'Requested': 100,
          'Accepted': 85,
          'Paid': 72,
          'Confirmed': 68,
        },
        'outcomes': {
          'Cancelled Requests': 8,
          'Avg. Time to Confirm': '1.5 hrs',
          'Waitlisted Requests': 5,
          'Avg. Length of Stay': '3.8 days',
        },
        'revenue': {
          'General': 20000,
          'Semi-Private': 35000,
          'Private': 60000,
          'ICU': 100000,
        },
        'peakBookingTimes': {
          'Morning (9AM-12PM)': 30,
          'Afternoon (12PM-3PM)': 45,
          'Evening (3PM-6PM)': 25,
        },
      },
      'insights': {
        'topCancelReasons': ['No availability', 'High cost', 'Location', 'Timing', 'Quality'],
        'highDemandBeds': ['ICU', 'Private', 'Semi-Private'],
        'suggestions': 'Consider adding more ICU and Private beds to meet high demand',
      },
    },
    'week': {
      'stats': {
        'totalPatients': 320,
        'totalInquiries': 85,
        'totalBookings': 180,
        'totalBedRequests': 220,
        'confirmedBedBookings': 165,
        'totalBedRevenue': 850000,
        'avgTimeToConfirm': '2.2 hrs',
        'bedOccupancyRate': 82,
      },
      'requests': [
        {
          'patientName': 'Rajesh Verma',
          'bedType': 'ICU',
          'status': 'Confirmed',
          'time': '10:00 AM',
          'date': 'Yesterday',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Meera Kapoor',
          'bedType': 'Private Room',
          'status': 'Pending',
          'time': '01:30 PM',
          'date': 'Yesterday',
          'statusColor': 0xFFF59E0B,
        },
        {
          'patientName': 'Vikram Singh',
          'bedType': 'General Ward',
          'status': 'Confirmed',
          'time': '08:45 AM',
          'date': '2 days ago',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Anjali Desai',
          'bedType': 'Semi-Private',
          'status': 'Cancelled',
          'time': '04:20 PM',
          'date': '3 days ago',
          'statusColor': 0xFFEF4444,
        },
      ],
      'footfall': {
        'peakHour': '3 PM',
        'peakDay': 'Wednesday',
        'chartData': [20, 35, 45, 55, 65, 75, 85, 75, 65, 55, 45, 35],
        'chartLabels': ['9AM', '10AM', '11AM', '12PM', '1PM', '2PM', '3PM', '4PM', '5PM', '6PM', '7PM', '8PM'],
      },
      'demographics': {
        'ageGroups': {
          '0-18': 18,
          '19-30': 28,
          '31-45': 38,
          '46-60': 22,
          '60+': 8,
        },
        'healthConditions': {
          'Cardiac': 22,
          'Neurological': 18,
          'Orthopedic': 28,
          'Respiratory': 12,
          'Gastrointestinal': 18,
          'Other': 12,
        },
        'genderDistribution': {
          'Male': 58,
          'Female': 42,
        },
      },
      'bedAnalytics': {
        'occupancy': {
          'General': 78,
          'Semi-Private': 72,
          'Private': 88,
          'ICU': 82,
        },
        'demand': {
          'General': 42,
          'Semi-Private': 35,
          'Private': 28,
          'ICU': 18,
        },
        'funnel': {
          'Requested': 100,
          'Accepted': 82,
          'Paid': 75,
          'Confirmed': 72,
        },
        'outcomes': {
          'Cancelled Requests': 12,
          'Avg. Time to Confirm': '2.2 hrs',
          'Waitlisted Requests': 8,
          'Avg. Length of Stay': '4.1 days',
        },
        'revenue': {
          'General': 25000,
          'Semi-Private': 40000,
          'Private': 65000,
          'ICU': 110000,
        },
        'peakBookingTimes': {
          'Morning (9AM-12PM)': 35,
          'Afternoon (12PM-3PM)': 50,
          'Evening (3PM-6PM)': 15,
        },
      },
      'insights': {
        'topCancelReasons': ['No availability', 'High cost', 'Location', 'Timing', 'Quality', 'Insurance issues'],
        'highDemandBeds': ['ICU', 'Private', 'General'],
        'suggestions': 'Increase ICU capacity and optimize bed allocation for better revenue',
      },
    },
    'month': {
      'stats': {
        'totalPatients': 1250,
        'totalInquiries': 320,
        'totalBookings': 680,
        'totalBedRequests': 850,
        'confirmedBedBookings': 620,
        'totalBedRevenue': 3200000,
        'avgTimeToConfirm': '2.8 hrs',
        'bedOccupancyRate': 85,
      },
      'requests': [
        {
          'patientName': 'Arun Kumar',
          'bedType': 'Private Room',
          'status': 'Confirmed',
          'time': '09:15 AM',
          'date': 'Last week',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Sunita Reddy',
          'bedType': 'ICU',
          'status': 'Pending',
          'time': '02:45 PM',
          'date': 'Last week',
          'statusColor': 0xFFF59E0B,
        },
        {
          'patientName': 'Kiran Patel',
          'bedType': 'Semi-Private',
          'status': 'Confirmed',
          'time': '11:30 AM',
          'date': '2 weeks ago',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Mohan Singh',
          'bedType': 'General Ward',
          'status': 'Cancelled',
          'time': '03:15 PM',
          'date': '3 weeks ago',
          'statusColor': 0xFFEF4444,
        },
      ],
      'footfall': {
        'peakHour': '1 PM',
        'peakDay': 'Monday',
        'chartData': [25, 40, 55, 70, 85, 100, 115, 100, 85, 70, 55, 40],
        'chartLabels': ['9AM', '10AM', '11AM', '12PM', '1PM', '2PM', '3PM', '4PM', '5PM', '6PM', '7PM', '8PM'],
      },
      'demographics': {
        'ageGroups': {
          '0-18': 20,
          '19-30': 30,
          '31-45': 40,
          '46-60': 25,
          '60+': 10,
        },
        'healthConditions': {
          'Cardiac': 25,
          'Neurological': 20,
          'Orthopedic': 30,
          'Respiratory': 15,
          'Gastrointestinal': 20,
          'Other': 10,
        },
        'genderDistribution': {
          'Male': 52,
          'Female': 48,
        },
      },
      'bedAnalytics': {
        'occupancy': {
          'General': 82,
          'Semi-Private': 75,
          'Private': 90,
          'ICU': 88,
        },
        'demand': {
          'General': 48,
          'Semi-Private': 38,
          'Private': 32,
          'ICU': 22,
        },
        'funnel': {
          'Requested': 100,
          'Accepted': 85,
          'Paid': 78,
          'Confirmed': 75,
        },
        'outcomes': {
          'Cancelled Requests': 15,
          'Avg. Time to Confirm': '2.8 hrs',
          'Waitlisted Requests': 12,
          'Avg. Length of Stay': '4.5 days',
        },
        'revenue': {
          'General': 30000,
          'Semi-Private': 45000,
          'Private': 70000,
          'ICU': 120000,
        },
        'peakBookingTimes': {
          'Morning (9AM-12PM)': 40,
          'Afternoon (12PM-3PM)': 45,
          'Evening (3PM-6PM)': 15,
        },
      },
      'insights': {
        'topCancelReasons': ['No availability', 'High cost', 'Location', 'Timing', 'Quality', 'Insurance issues', 'Doctor availability'],
        'highDemandBeds': ['ICU', 'Private', 'General', 'Semi-Private'],
        'suggestions': 'Consider expanding ICU and Private room capacity to maximize revenue potential',
      },
    },
    'year': {
      'stats': {
        'totalPatients': 15000,
        'totalInquiries': 3800,
        'totalBookings': 8200,
        'totalBedRequests': 10200,
        'confirmedBedBookings': 7500,
        'totalBedRevenue': 38500000,
        'avgTimeToConfirm': '3.2 hrs',
        'bedOccupancyRate': 88,
      },
      'requests': [
        {
          'patientName': 'Deepak Sharma',
          'bedType': 'ICU',
          'status': 'Confirmed',
          'time': '08:30 AM',
          'date': 'Last month',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Rekha Gupta',
          'bedType': 'Private Room',
          'status': 'Pending',
          'time': '01:00 PM',
          'date': 'Last month',
          'statusColor': 0xFFF59E0B,
        },
        {
          'patientName': 'Suresh Kumar',
          'bedType': 'General Ward',
          'status': 'Confirmed',
          'time': '10:45 AM',
          'date': '2 months ago',
          'statusColor': 0xFF10B981,
        },
        {
          'patientName': 'Lakshmi Devi',
          'bedType': 'Semi-Private',
          'status': 'Cancelled',
          'time': '04:30 PM',
          'date': '3 months ago',
          'statusColor': 0xFFEF4444,
        },
      ],
      'footfall': {
        'peakHour': '12 PM',
        'peakDay': 'Tuesday',
        'chartData': [30, 50, 70, 90, 110, 130, 150, 130, 110, 90, 70, 50],
        'chartLabels': ['9AM', '10AM', '11AM', '12PM', '1PM', '2PM', '3PM', '4PM', '5PM', '6PM', '7PM', '8PM'],
      },
      'demographics': {
        'ageGroups': {
          '0-18': 22,
          '19-30': 32,
          '31-45': 35,
          '46-60': 28,
          '60+': 12,
        },
        'healthConditions': {
          'Cardiac': 28,
          'Neurological': 22,
          'Orthopedic': 32,
          'Respiratory': 18,
          'Gastrointestinal': 22,
          'Other': 8,
        },
        'genderDistribution': {
          'Male': 54,
          'Female': 46,
        },
      },
      'bedAnalytics': {
        'occupancy': {
          'General': 85,
          'Semi-Private': 78,
          'Private': 92,
          'ICU': 90,
        },
        'demand': {
          'General': 52,
          'Semi-Private': 42,
          'Private': 35,
          'ICU': 25,
        },
        'funnel': {
          'Requested': 100,
          'Accepted': 88,
          'Paid': 82,
          'Confirmed': 78,
        },
        'outcomes': {
          'Cancelled Requests': 18,
          'Avg. Time to Confirm': '3.2 hrs',
          'Waitlisted Requests': 15,
          'Avg. Length of Stay': '4.8 days',
        },
        'revenue': {
          'General': 35000,
          'Semi-Private': 50000,
          'Private': 75000,
          'ICU': 130000,
        },
        'peakBookingTimes': {
          'Morning (9AM-12PM)': 45,
          'Afternoon (12PM-3PM)': 40,
          'Evening (3PM-6PM)': 15,
        },
      },
      'insights': {
        'topCancelReasons': ['No availability', 'High cost', 'Location', 'Timing', 'Quality', 'Insurance issues', 'Doctor availability', 'Bed type preference'],
        'highDemandBeds': ['ICU', 'Private', 'General', 'Semi-Private'],
        'suggestions': 'Focus on expanding ICU and Private room capacity while optimizing bed allocation for maximum revenue',
      },
    },
  };

  // Get data for specific time period
  static Map<String, dynamic> getDataForTimePeriod(String timePeriod) {
    return _timePeriodData[timePeriod] ?? _timePeriodData['week']!;
  }

  // Get stats for time period
  static Map<String, dynamic> getStats(String timePeriod) {
    final data = getDataForTimePeriod(timePeriod);
    return data['stats'] ?? {};
  }

  // Get requests for time period
  static List<Map<String, dynamic>> getRequests(String timePeriod) {
    final data = getDataForTimePeriod(timePeriod);
    return List<Map<String, dynamic>>.from(data['requests'] ?? []);
  }

  // Get footfall data for time period
  static Map<String, dynamic> getFootfallData(String timePeriod) {
    final data = getDataForTimePeriod(timePeriod);
    return data['footfall'] ?? {};
  }

  // Get demographics data for time period
  static Map<String, dynamic> getDemographicsData(String timePeriod) {
    final data = getDataForTimePeriod(timePeriod);
    return data['demographics'] ?? {};
  }

  // Get bed analytics data for time period
  static Map<String, dynamic> getBedAnalyticsData(String timePeriod) {
    final data = getDataForTimePeriod(timePeriod);
    return data['bedAnalytics'] ?? {};
  }

  // Get insights data for time period
  static Map<String, dynamic> getInsightsData(String timePeriod) {
    final data = getDataForTimePeriod(timePeriod);
    return data['insights'] ?? {};
  }
}
