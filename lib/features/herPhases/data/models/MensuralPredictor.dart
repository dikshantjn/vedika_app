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
    };
  }
}
