import 'package:intl/intl.dart';
import '../../data/models/MensuralPredictor.dart';  // ✅ Correct import

class HerPhasesViewModel {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static String formatDayOnly(DateTime date) {
    return DateFormat('dd MMMM').format(date);
  }

  List<CyclePrediction> predictCycle2Months({
    required String name,
    required String lastPeriodDate,
    required int cycleLength,
  }) {
    DateTime lastPeriod = DateTime.parse(lastPeriodDate);
    List<CyclePrediction> results = [];
    DateTime currentPeriod = lastPeriod;

    for (int i = 0; i < 2; i++) {
      DateTime nextPeriod = currentPeriod.add(Duration(days: cycleLength));
      DateTime ovulation = nextPeriod.subtract(Duration(days: 14));
      DateTime fertileStart = ovulation.subtract(Duration(days: 4));
      DateTime fertileEnd = ovulation.add(Duration(days: 1));

      results.add(CyclePrediction(
        name: name,
        cycle: i + 1,
        month: DateFormat('MMMM').format(nextPeriod),
        lastPeriodDate: lastPeriodDate,
        cycleLength: cycleLength,
        cycleStartDate: formatDate(currentPeriod),
        nextPeriod: formatDate(nextPeriod),
        ovulationDate: formatDate(ovulation),
        fertileWindow:
        "${formatDayOnly(fertileStart)} to ${formatDayOnly(fertileEnd)}",
      ));

      currentPeriod = nextPeriod;
    }

    return results;
  }
}
