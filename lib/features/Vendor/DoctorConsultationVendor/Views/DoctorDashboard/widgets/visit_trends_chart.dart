import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class VisitTrendsChart extends StatelessWidget {
  const VisitTrendsChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit Trends',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DoctorConsultationColorPalette.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Visits',
                    style: TextStyle(
                      color: DoctorConsultationColorPalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildChartLegend(),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildLineChart(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    title: 'Highest',
                    value: '34',
                    subtitle: 'Mon, 15 Apr',
                    iconColor: DoctorConsultationColorPalette.successGreen,
                  ),
                  _buildSummaryItem(
                    title: 'Average',
                    value: '18',
                    subtitle: 'per day',
                    iconColor: DoctorConsultationColorPalette.primaryBlue,
                  ),
                  _buildSummaryItem(
                    title: 'Lowest',
                    value: '5',
                    subtitle: 'Sun, 21 Apr',
                    iconColor: DoctorConsultationColorPalette.errorRed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'This Week',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.secondaryTeal,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Last Week',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    // Mock data for the chart
    final List<double> thisWeekData = [15, 25, 18, 28, 22, 12, 18];
    final List<double> lastWeekData = [10, 18, 20, 15, 25, 10, 15];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(
        thisWeekData: thisWeekData,
        lastWeekData: lastWeekData,
        days: days,
        maxValue: 30,
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: DoctorConsultationColorPalette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> thisWeekData;
  final List<double> lastWeekData;
  final List<String> days;
  final double maxValue;
  
  LineChartPainter({
    required this.thisWeekData,
    required this.lastWeekData,
    required this.days,
    required this.maxValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double chartHeight = height - 30; // Reserve space for x-axis labels
    
    final double xStep = width / (thisWeekData.length - 1);
    
    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = DoctorConsultationColorPalette.borderLight
      ..strokeWidth = 1;
    
    // Draw horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final double y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        gridPaint,
      );
    }
    
    // Draw this week's line and points
    _drawLine(
      canvas,
      thisWeekData,
      xStep,
      chartHeight,
      DoctorConsultationColorPalette.primaryBlue,
      DoctorConsultationColorPalette.primaryBlue.withOpacity(0.2),
    );
    
    // Draw last week's line and points
    _drawLine(
      canvas,
      lastWeekData,
      xStep,
      chartHeight,
      DoctorConsultationColorPalette.secondaryTeal,
      DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.2),
    );
    
    // Draw x-axis labels
    final TextStyle labelStyle = TextStyle(
      color: DoctorConsultationColorPalette.textSecondary,
      fontSize: 10,
    );
    
    for (int i = 0; i < days.length; i++) {
      final TextSpan span = TextSpan(
        text: days[i],
        style: labelStyle,
      );
      
      final TextPainter painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      
      painter.layout();
      
      painter.paint(
        canvas,
        Offset(
          i * xStep - painter.width / 2,
          chartHeight + 10,
        ),
      );
    }
  }
  
  void _drawLine(
    Canvas canvas,
    List<double> data,
    double xStep,
    double chartHeight,
    Color lineColor,
    Color fillColor,
  ) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    final Path linePath = Path();
    final Path fillPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      final double y = chartHeight - (chartHeight * data[i] / maxValue);
      
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Complete the fill path
    fillPath.lineTo((data.length - 1) * xStep, chartHeight);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Draw points
    final Paint pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    final Paint pointStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      final double y = chartHeight - (chartHeight * data[i] / maxValue);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 4, pointStrokePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 