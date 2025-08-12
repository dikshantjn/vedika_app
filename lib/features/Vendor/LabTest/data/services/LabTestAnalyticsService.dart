import 'dart:async';

/// Provides mock analytics data for the Lab Test vendor dashboard.
class LabTestAnalyticsService {
  Future<Map<String, dynamic>> getAnalytics({required String period}) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 350));

    final String p = period.toLowerCase();
    final bool isWeek = p.contains('week');
    final bool isMonth = p.contains('month');
    final bool isYear = p.contains('year');

    // Section A: Today / This Week Overview
    final int totalBookings = isWeek
        ? 220
        : isMonth
            ? 840
            : isYear
                ? 10240
                : 32;
    final int pendingRequests = isWeek
        ? 28
        : isMonth
            ? 96
            : isYear
                ? 1180
                : 5;
    final int testsInProgress = isWeek
        ? 54
        : isMonth
            ? 210
            : isYear
                ? 2410
                : 9;
    final int completedTests = isWeek
        ? 130
        : isMonth
            ? 520
            : isYear
                ? 7700
                : 17;
    final double revenue = isWeek
        ? 184560.0
        : isMonth
            ? 742300.0
            : isYear
                ? 9100000.0
                : 26540.0;

    // Section B: Performance KPIs
    final int avgTimeToConfirmMins = isWeek
        ? 14
        : isMonth
            ? 13
            : isYear
                ? 15
                : 11; // minutes
    final int avgTimeToUploadReportMins = isWeek
        ? 310
        : isMonth
            ? 295
            : isYear
                ? 325
                : 285; // minutes
    final double cancellationRate = isWeek
        ? 0.06
        : isMonth
            ? 0.05
            : isYear
                ? 0.055
                : 0.04; // 0..1

    // Section C: Quick Trends
    final Map<String, int> topTestTypesToday = {
      'CBC': isWeek ? 120 : 20,
      'Thyroid': isWeek ? 95 : 16,
      'COVID': isWeek ? 80 : 12,
      'Vitamin D': isWeek ? 60 : 8,
    };
    final double homeCollectionRatio = isWeek ? 0.72 : 0.69; // 0..1
    final Map<String, int> newVsReturning = {
      'new': isWeek ? 140 : 22,
      'returning': isWeek ? 80 : 10,
    };

    // Helper series
    final List<String> months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    // A. Customer Insights
    final List<Map<String, dynamic>> newVsReturningByMonth = List.generate(12, (i) {
      final int newCount = [220, 210, 240, 260, 270, 250, 230, 240, 255, 265, 275, 290][i];
      final int returningCount = [180, 170, 190, 210, 215, 220, 200, 205, 210, 220, 230, 240][i];
      return {
        'month': months[i],
        'new': newCount,
        'returning': returningCount,
      };
    });

    final List<Map<String, dynamic>> rebookingTrends = List.generate(12, (i) {
      final int repeats = [40, 38, 42, 48, 52, 55, 57, 60, 62, 65, 68, 72][i];
      return {'month': months[i], 'thyroidRepeats': repeats};
    });

    final List<Map<String, dynamic>> topCustomersByTestCount = const [
      {'customer': 'Aarav Sharma', 'tests': 18},
      {'customer': 'Neha Verma', 'tests': 16},
      {'customer': 'Rohit Gupta', 'tests': 14},
      {'customer': 'Priya Singh', 'tests': 12},
      {'customer': 'Aman Patel', 'tests': 11},
    ];

    // B. Demand Analysis
    final List<Map<String, dynamic>> geoDemandByArea = const [
      {'area': 'Andheri', 'bookings': 220},
      {'area': 'Bandra', 'bookings': 180},
      {'area': 'Powai', 'bookings': 160},
      {'area': 'Thane', 'bookings': 140},
      {'area': 'Vashi', 'bookings': 120},
    ];

    final List<Map<String, dynamic>> seasonalTestDemand = List.generate(12, (i) {
      // Simulate monsoon spikes (Jun-Sep) for dengue/malaria
      final bool monsoon = i >= 5 && i <= 8;
      final int dengue = monsoon ? 90 + (i - 5) * 10 : 30 + (i % 4) * 5;
      final int malaria = monsoon ? 80 + (i - 5) * 9 : 25 + (i % 3) * 5;
      return {'month': months[i], 'dengue': dengue, 'malaria': malaria};
    });

    final List<Map<String, dynamic>> mostRequestedLast30Days = const [
      {'test': 'CBC', 'count': 340},
      {'test': 'Thyroid', 'count': 290},
      {'test': 'Vitamin D', 'count': 210},
      {'test': 'Lipid Profile', 'count': 190},
      {'test': 'HbA1c', 'count': 175},
    ];

    final List<Map<String, dynamic>> lowDemandLast30Days = const [
      {'test': 'ESR', 'count': 20},
      {'test': 'CRP', 'count': 18},
      {'test': 'Uric Acid', 'count': 16},
      {'test': 'BUN', 'count': 14},
      {'test': 'Calcium', 'count': 12},
    ];

    // C. Operational Efficiency
    final List<Map<String, dynamic>> avgTimeToAppointmentDaysByMonth = List.generate(12, (i) {
      final double days = [1.8, 1.9, 2.0, 1.7, 1.6, 1.8, 1.9, 2.1, 2.2, 2.0, 1.9, 1.8][i];
      return {'month': months[i], 'days': days};
    });

    final List<Map<String, dynamic>> avgTimeToConfirmCollectionMinsByMonth = List.generate(12, (i) {
      final int mins = [14, 13, 12, 12, 11, 11, 12, 13, 13, 14, 15, 15][i] * 60; // minutes to seconds-style magnitude
      return {'month': months[i], 'mins': mins};
    });

    final List<Map<String, dynamic>> reportTurnaroundHoursByMonth = List.generate(12, (i) {
      final int hours = [22, 24, 26, 24, 23, 25, 26, 27, 26, 25, 24, 23][i];
      return {'month': months[i], 'hours': hours};
    });

    // D. Service Preferences
    final List<Map<String, dynamic>> homeCollectionTrendByMonth = List.generate(12, (i) {
      final double ratio = [0.66, 0.67, 0.68, 0.69, 0.70, 0.71, 0.72, 0.71, 0.70, 0.69, 0.68, 0.69][i];
      return {'month': months[i], 'ratio': ratio};
    });

    final List<Map<String, dynamic>> collectionTypeDistributionByMonth = List.generate(12, (i) {
      final double home = [0.66, 0.67, 0.68, 0.69, 0.70, 0.71, 0.72, 0.71, 0.70, 0.69, 0.68, 0.69][i];
      final double walkIn = 1.0 - home;
      return {'month': months[i], 'home': home, 'walkIn': walkIn};
    });

    // E. Revenue & Volume
    final List<Map<String, dynamic>> monthlyRevenue = List.generate(12, (i) {
      final double rev = [6.8, 6.9, 7.1, 7.4, 7.6, 7.8, 8.0, 8.1, 8.0, 8.2, 8.4, 8.8][i] * 100000.0;
      return {'month': months[i], 'revenue': rev};
    });

    final Map<String, double> revenueByTestType = const {
      'CBC': 1250000.0,
      'Thyroid': 980000.0,
      'Vitamin D': 760000.0,
      'Lipid Profile': 720000.0,
      'HbA1c': 640000.0,
    };

    final List<Map<String, dynamic>> bookingVolumeByMonth = List.generate(12, (i) {
      final int count = [820, 840, 860, 880, 900, 920, 940, 960, 950, 970, 990, 1020][i];
      return {'month': months[i], 'bookings': count};
    });

    return {
      'period': period,
      'overview': {
        'totalBookings': totalBookings,
        'pendingRequests': pendingRequests,
        'testsInProgress': testsInProgress,
        'completedTests': completedTests,
        'revenue': revenue,
      },
      'performance': {
        'avgTimeToConfirmMins': avgTimeToConfirmMins,
        'avgTimeToUploadReportMins': avgTimeToUploadReportMins,
        'cancellationRate': cancellationRate,
      },
      'trends': {
        'topTestTypes': topTestTypesToday,
        'homeCollectionRatio': homeCollectionRatio,
        'newVsReturning': newVsReturning,
      },
      'customerInsights': {
        'newVsReturningByMonth': newVsReturningByMonth,
        'rebookingTrends': rebookingTrends,
        'topCustomersByTestCount': topCustomersByTestCount,
      },
      'demandAnalysis': {
        'geoDemandByArea': geoDemandByArea,
        'seasonalTestDemand': seasonalTestDemand,
        'mostRequestedLast30Days': mostRequestedLast30Days,
        'lowDemandLast30Days': lowDemandLast30Days,
      },
      'operationalEfficiency': {
        'avgTimeToAppointmentDaysByMonth': avgTimeToAppointmentDaysByMonth,
        'avgTimeToConfirmCollectionMinsByMonth':
            avgTimeToConfirmCollectionMinsByMonth,
        'reportTurnaroundHoursByMonth': reportTurnaroundHoursByMonth,
      },
      'servicePreferences': {
        'homeCollectionTrendByMonth': homeCollectionTrendByMonth,
        'collectionTypeDistributionByMonth': collectionTypeDistributionByMonth,
      },
      'revenueAndVolume': {
        'monthlyRevenue': monthlyRevenue,
        'revenueByTestType': revenueByTestType,
        'bookingVolumeByMonth': bookingVolumeByMonth,
      },
    };
  }
}


