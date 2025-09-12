import 'package:intl/intl.dart';
import '../../data/models/MensuralPredictor.dart';

class HerPhasesViewModel {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static String formatDayOnly(DateTime date) {
    return DateFormat('dd MMMM').format(date);
  }

  /// Predict only the NEXT 2 cycles (skip current month cycle)
  List<CyclePrediction> predictCycle3Months({
    required String name,
    required String lastPeriodDate,
    required int cycleLength,
  }) {
    DateTime lastPeriod = DateTime.parse(lastPeriodDate);
    List<CyclePrediction> results = [];

    // ✅ Start from the NEXT cycle (skip the current one)
    for (int i = 1; i <= 3; i++) {
      DateTime nextPeriod = lastPeriod.add(Duration(days: cycleLength * i));

      // Ovulation is typically 14 days before the next period
      DateTime ovulation = nextPeriod.subtract(const Duration(days: 14));

      // Fertile window: 5 days (4 before + ovulation day + 1 after)
      DateTime fertileStart = ovulation.subtract(const Duration(days: 4));
      DateTime fertileEnd = ovulation.add(const Duration(days: 1));

      results.add(CyclePrediction(
        name: name,
        cycle: i,
        month: DateFormat('MMMM').format(nextPeriod),
        lastPeriodDate: lastPeriodDate,
        cycleLength: cycleLength,
        cycleStartDate: formatDate(lastPeriod.add(Duration(days: cycleLength * (i - 1)))),
        nextPeriod: formatDate(nextPeriod),
        ovulationDate: formatDate(ovulation),
        fertileWindow:
        "${formatDayOnly(fertileStart)} to ${formatDayOnly(fertileEnd)}",
        cycleStartDateTime: lastPeriod.add(Duration(days: cycleLength * (i - 1))),
        nextPeriodDateTime: nextPeriod,
        ovulationDateTime: ovulation,
      ));
    }

    return results;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Collects all events for calendar highlighting
  /// Shows:
  /// - ONLY the entered lastPeriodDate in the past month (no predictions in that month)
  /// - Predicted fertile/ovulation/period/pre-period ONLY for NEXT 2 cycles
  Map<DateTime, String> getAllEvents(
      List<CyclePrediction> predictions,
      String lastPeriodDate,
      ) {
    Map<DateTime, String> events = {};
    DateTime lastPeriod = DateTime.parse(lastPeriodDate);

    // ✅ Show ONLY the user-entered lastPeriodDate (no other predictions in that month)
    events[_normalizeDate(lastPeriod)] = "Period";

    // ✅ Add predictions ONLY for future cycles (not the current month)
    for (var prediction in predictions) {
      DateTime nextPeriod = prediction.nextPeriodDateTime;
      DateTime ovulation = prediction.ovulationDateTime;

      // Skip if the prediction is in the same month as the entered last period date
      if (nextPeriod.year == lastPeriod.year && nextPeriod.month == lastPeriod.month) {
        continue; // Don't add any predictions for the same month
      }

      // Period Days (5 days starting from next period)
      for (int i = 0; i < 5; i++) {
        events[_normalizeDate(nextPeriod.add(Duration(days: i)))] = "Period";
      }

      // Pre-Period (2 days before)
      for (int i = 2; i >= 1; i--) {
        events[_normalizeDate(nextPeriod.subtract(Duration(days: i)))] =
        "Pre-Period";
      }

      // Peak Ovulation
      events[_normalizeDate(ovulation)] = "Peak Ovulation";

      // Fertile Window
      final fertileStart = ovulation.subtract(const Duration(days: 4));
      final fertileEnd = ovulation.add(const Duration(days: 1));

      for (int i = 0; i <= fertileEnd.difference(fertileStart).inDays; i++) {
        final d = fertileStart.add(Duration(days: i));

        if (d != ovulation) {
          events[_normalizeDate(d)] = "Fertile";
        }
      }
    }

    return events;
  }
}
