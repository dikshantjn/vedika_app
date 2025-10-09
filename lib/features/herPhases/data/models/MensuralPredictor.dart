class MensuralPredictor {
  // Identity and contact
  final String? userId; // optional
  final String userName;
  final String? phoneNumber; // optional
  final String? emailId; // optional

  // Inputs
  final String lastPeriodDate; // dd-MM-yyyy
  final int cycleLength;

  // Derived outputs (display strings)
  final String cycleStartDate; // dd MMMM yyyy
  final String nextPeriodDate; // dd MMMM yyyy
  final String ovulationDate; // dd MMMM yyyy

  // Optional helpers for UI/debug
  final int? cycle; // 1..N
  final String? month; // e.g., March

  // Raw date-times used for calculations
  final DateTime cycleStartDateTime;
  final DateTime nextPeriodDateTime;
  final DateTime ovulationDateTime;

  MensuralPredictor({
    this.userId,
    required this.userName,
    this.phoneNumber,
    this.emailId,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.cycleStartDate,
    required this.nextPeriodDate,
    required this.ovulationDate,
    this.cycle,
    this.month,
    required this.cycleStartDateTime,
    required this.nextPeriodDateTime,
    required this.ovulationDateTime,
  });

  factory MensuralPredictor.fromJson(Map<String, dynamic> json) {
    return MensuralPredictor(
      userId: json['user_id'],
      userName: json['user_name'] ?? json['Name'] ?? '',
      phoneNumber: json['phone_number'],
      emailId: json['email_id'],
      lastPeriodDate: json['last_period_date'] ?? json['Last Period Date'] ?? '',
      cycleLength: json['cycle_length'] ?? json['Cycle Length'] ?? 28,
      cycleStartDate: json['cycle_start_date'] ?? json['Cycle Start Date'] ?? '',
      nextPeriodDate: json['next_period_date'] ?? json['Next Period'] ?? '',
      ovulationDate: json['ovulation_date'] ?? json['Ovulation Date'] ?? '',
      cycle: json['Cycle'],
      month: json['Month'],
      cycleStartDateTime: DateTime.tryParse(json['Cycle Start Date Time'] ?? json['cycle_start_date_time'] ?? '') ?? DateTime.now(),
      nextPeriodDateTime: DateTime.tryParse(json['Next Period Date Time'] ?? json['next_period_date_time'] ?? '') ?? DateTime.now(),
      ovulationDateTime: DateTime.tryParse(json['Ovulation Date Time'] ?? json['ovulation_date_time'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'user_name': userName,
      'phone_number': phoneNumber,
      'email_id': emailId,
      // Expecting yyyy-MM-dd for API
      'last_period_date': lastPeriodDate,
      'cycle_length': cycleLength,
      'cycle_start_date': cycleStartDate,
      'next_period_date': nextPeriodDate,
      'ovulation_date': ovulationDate,
      // useful for backend or later reads
      'Cycle Start Date Time': cycleStartDateTime.toIso8601String(),
      'Next Period Date Time': nextPeriodDateTime.toIso8601String(),
      'Ovulation Date Time': ovulationDateTime.toIso8601String(),
      // optional UI helpers
      'Cycle': cycle,
      'Month': month,
    };
    // Remove nulls
    data.removeWhere((key, value) => value == null);
    return data;
  }
}