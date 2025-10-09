import 'package:intl/intl.dart';
import '../../data/models/MensuralPredictor.dart';
import '../../data/services/herPhasesService.dart';
import 'package:vedika_healthcare/core/auth/data/services/UserService.dart';

class HerPhasesViewModel {
  /// Normalize a date to year-month-day (drop time component)
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static String formatDayOnly(DateTime date) {
    return DateFormat('dd MMMM').format(date);
  }

  /// Predict the next 3 cycles based on lastPeriodDate (in dd-MM-yyyy)
  List<MensuralPredictor> predictCycle3Months({
    required String name,
    required String lastPeriodDate,
    required int cycleLength,
  }) {
    // Parse input date in dd-MM-yyyy
    final DateTime lastPeriod = DateFormat('dd-MM-yyyy').parse(lastPeriodDate);
    final List<MensuralPredictor> results = [];

    for (int i = 1; i <= 3; i++) {
      final DateTime nextPeriod = lastPeriod.add(Duration(days: cycleLength * i));
      final DateTime ovulation = nextPeriod.subtract(const Duration(days: 14));
      final DateTime cycleStartForThis = lastPeriod.add(Duration(days: cycleLength * (i - 1)));

      results.add(MensuralPredictor(
        userId: null,
        userName: name,
        phoneNumber: null,
        emailId: null,
        lastPeriodDate: lastPeriodDate,
        cycleLength: cycleLength,
        cycleStartDate: formatDate(cycleStartForThis),
        nextPeriodDate: formatDate(nextPeriod),
        ovulationDate: formatDate(ovulation),
        cycle: i,
        month: DateFormat('MMMM').format(nextPeriod),
        cycleStartDateTime: cycleStartForThis,
        nextPeriodDateTime: nextPeriod,
        ovulationDateTime: ovulation,
      ));
    }

    return results;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Compute which day the calendar should focus on after predictions
  /// Prefers the first predicted next period date; otherwise falls back to the
  /// entered last period date; and finally to today when parsing fails.
  static DateTime computeFocusedDay(
    List<MensuralPredictor> predictions,
    String lastPeriodDate,
  ) {
    if (predictions.isNotEmpty) {
      return predictions.first.nextPeriodDateTime;
    }

    if (lastPeriodDate.isNotEmpty) {
      try {
        // Parse dd-MM-yyyy
        return DateFormat('dd-MM-yyyy').parse(lastPeriodDate);
      } catch (_) {
        // ignore and fall through to now
      }
    }
    return DateTime.now();
  }

  /// Collects all events for calendar highlighting
  /// Shows:
  /// - ONLY the entered lastPeriodDate in the past month (no predictions in that month)
  /// - Predicted fertile/ovulation/period/pre-period ONLY for NEXT 2 cycles
  Map<DateTime, String> getAllEvents(
      List<MensuralPredictor> predictions,
      String lastPeriodDate,
      ) {
    Map<DateTime, String> events = {};
    DateTime lastPeriod = DateFormat('dd-MM-yyyy').parse(lastPeriodDate);

    //  Show ONLY the user-entered lastPeriodDate (no other predictions in that month)
    events[_normalizeDate(lastPeriod)] = "Period";

    // Add predictions ONLY for future cycles (not the current month)
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

  Future<List<MensuralPredictor>> submitAndPredict({
    String? userId,
    required String userName,
    String? phoneNumber,
    String? emailId,
    required String lastPeriodDate,
    required int cycleLength,
  }) async {
    // If userId not provided, try reading from storage via UserService
    String? effectiveUserId = userId;
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      final userService = UserService();
      effectiveUserId = await userService.getCurrentUserId();
    }
    final service = HerPhasesService();
    // Compute first cycle details for the payload
    final List<MensuralPredictor> predictions = predictCycle3Months(
      name: userName,
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
    );
    final MensuralPredictor first = predictions.first;

    // Send unified model to backend (includes inputs and first-cycle derived fields)
    // Convert lastPeriodDate (dd-MM-yyyy) to API-required yyyy-MM-dd
    final DateTime last = DateFormat('dd-MM-yyyy').parse(lastPeriodDate);
    final String apiLastPeriod = DateFormat('yyyy-MM-dd').format(last);

    final payload = MensuralPredictor(
      userId: effectiveUserId,
      userName: userName,
      phoneNumber: phoneNumber,
      emailId: emailId,
      lastPeriodDate: apiLastPeriod,
      cycleLength: cycleLength,
      cycleStartDate: first.cycleStartDate,
      nextPeriodDate: first.nextPeriodDate,
      ovulationDate: first.ovulationDate,
      cycle: first.cycle,
      month: first.month,
      cycleStartDateTime: first.cycleStartDateTime,
      nextPeriodDateTime: first.nextPeriodDateTime,
      ovulationDateTime: first.ovulationDateTime,
    );

    await service.addHerPhases(payload);

    return predictions;
  }

  /// Optionally send/update contact preferences without reusing predictions from UI.
  /// This recomputes first-cycle fields and submits payload including phone/email.
  Future<void> submitContactInfo({
    String? userId,
    required String userName,
    String? phoneNumber,
    String? emailId,
    required String lastPeriodDate,
    required int cycleLength,
  }) async {
    String? effectiveUserId = userId;
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      final userService = UserService();
      effectiveUserId = await userService.getCurrentUserId();
    }

    final service = HerPhasesService();
    final List<MensuralPredictor> predictions = predictCycle3Months(
      name: userName,
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
    );
    final MensuralPredictor first = predictions.first;

    final payload = MensuralPredictor(
      userId: effectiveUserId,
      userName: userName,
      phoneNumber: phoneNumber,
      emailId: emailId,
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      cycleStartDate: first.cycleStartDate,
      nextPeriodDate: first.nextPeriodDate,
      ovulationDate: first.ovulationDate,
      cycle: first.cycle,
      month: first.month,
      cycleStartDateTime: first.cycleStartDateTime,
      nextPeriodDateTime: first.nextPeriodDateTime,
      ovulationDateTime: first.ovulationDateTime,
    );

    await service.addHerPhases(payload);
  }
}
