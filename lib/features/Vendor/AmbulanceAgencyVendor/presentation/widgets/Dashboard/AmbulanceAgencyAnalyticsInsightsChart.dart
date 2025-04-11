import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';

class AmbulanceAgencyAnalyticsInsightsChart extends StatefulWidget {
  final AgencyDashboardViewModel viewModel;

  const AmbulanceAgencyAnalyticsInsightsChart({super.key, required this.viewModel});

  @override
  State<AmbulanceAgencyAnalyticsInsightsChart> createState() =>
      _AmbulanceAgencyAnalyticsInsightsChartState();
}

class _AmbulanceAgencyAnalyticsInsightsChartState extends State<AmbulanceAgencyAnalyticsInsightsChart> {
  final List<String> _titles = ["BLS", "ALS", "ICU", "Air", "Train"];

  @override
  Widget build(BuildContext context) {
    final vehicleStats = widget.viewModel.vehicleStats;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Analytics & Insights",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final name = _titles[group.x.toInt()];
                      return BarTooltipItem(
                        "$name: ${rod.toY.toStringAsFixed(1)}",
                        TextStyle(color: Colors.black87, fontSize: 14),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 20,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = ["BLS", "ALS", "ICU", "Air", "Train"];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            titles[value.toInt()],
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, horizontalInterval: 20),
                barGroups: List.generate(_titles.length, (index) {
                  final stat = vehicleStats[_titles[index]] ?? 0.0;
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: stat,
                      width: 20,
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.red.withOpacity(0.7)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    )
                  ]);
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
