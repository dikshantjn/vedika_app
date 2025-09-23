import 'package:intl/intl.dart';

class CyclePrediction {
  final String name;
  final int cycle;
  final String month;
  final String lastPeriodDate;
  final int cycleLength;
  final String cycleStartDate;
  final String nextPeriod;
  final String ovulationDate;
  final String fertileWindow;

  // Add these for calculations
  final DateTime cycleStartDateTime;
  final DateTime nextPeriodDateTime;
  final DateTime ovulationDateTime;

  CyclePrediction({
    required this.name,
    required this.cycle,
    required this.month,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.cycleStartDate,
    required this.nextPeriod,
    required this.ovulationDate,
    required this.fertileWindow,
    required this.cycleStartDateTime,
    required this.nextPeriodDateTime,
    required this.ovulationDateTime,
  });

  factory CyclePrediction.fromJson(Map<String, dynamic> json) {
    return CyclePrediction(
      name: json['Name'],
      cycle: json['Cycle'],
      month: json['Month'],
      lastPeriodDate: json['Last Period Date'],
      cycleLength: json['Cycle Length'],
      cycleStartDate: json['Cycle Start Date'],
      nextPeriod: json['Next Period'],
      ovulationDate: json['Ovulation Date'],
      fertileWindow: json['Fertile Window'],

      // Parse DateTime fields safely
      cycleStartDateTime: DateTime.tryParse(json['Cycle Start Date Time'] ?? '') ?? DateTime.now(),
      nextPeriodDateTime: DateTime.tryParse(json['Next Period Date Time'] ?? '') ?? DateTime.now(),
      ovulationDateTime: DateTime.tryParse(json['Ovulation Date Time'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Name": name,
      "Cycle": cycle,
      "Month": month,
      "Last Period Date": lastPeriodDate,
      "Cycle Length": cycleLength,
      "Cycle Start Date": cycleStartDate,
      "Next Period": nextPeriod,
      "Ovulation Date": ovulationDate,
      "Fertile Window": fertileWindow,

      // ✅ Store raw DateTimes as strings
      "Cycle Start Date Time": cycleStartDateTime.toIso8601String(),
      "Next Period Date Time": nextPeriodDateTime.toIso8601String(),
      "Ovulation Date Time": ovulationDateTime.toIso8601String(),
    };
  }
}
