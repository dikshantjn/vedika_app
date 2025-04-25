import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:fl_chart/fl_chart.dart';

class BookingChart extends StatelessWidget {
  const BookingChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChartHeader(),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: LabTestColorPalette.borderLight,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: LabTestColorPalette.borderLight,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: LabTestColorPalette.textSecondary,
                        fontSize: 12,
                      );
                      String text;
                      switch (value.toInt()) {
                        case 0:
                          text = 'Mon';
                          break;
                        case 1:
                          text = 'Tue';
                          break;
                        case 2:
                          text = 'Wed';
                          break;
                        case 3:
                          text = 'Thu';
                          break;
                        case 4:
                          text = 'Fri';
                          break;
                        case 5:
                          text = 'Sat';
                          break;
                        case 6:
                          text = 'Sun';
                          break;
                        default:
                          text = '';
                      }
                      return Text(text, style: style);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: LabTestColorPalette.textSecondary,
                        fontSize: 12,
                      );
                      return Text(value.toInt().toString(), style: style);
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: LabTestColorPalette.borderLight,
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 4),
                    FlSpot(2, 2),
                    FlSpot(3, 5),
                    FlSpot(4, 3),
                    FlSpot(5, 4),
                    FlSpot(6, 3),
                  ],
                  isCurved: true,
                  color: LabTestColorPalette.primaryBlue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: LabTestColorPalette.primaryBlue,
                        strokeWidth: 2,
                        strokeColor: LabTestColorPalette.backgroundPrimary,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: LabTestColorPalette.primaryBlue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Weekly Bookings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: LabTestColorPalette.primaryBlueLightest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: LabTestColorPalette.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 12,
                  color: LabTestColorPalette.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 