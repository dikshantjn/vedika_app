import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';

class SeasonalLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{month: 'Jan', incidents: 28}, ...]
  const SeasonalLineChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SeasonalLinePainter(data: data),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _SeasonalLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  _SeasonalLinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double paddingLeft = 8;
    final double paddingRight = 8;
    final double paddingBottom = 18;
    final double chartWidth = width - paddingLeft - paddingRight;
    final double chartHeight = height - paddingBottom;

    // Determine max incidents
    int maxIncidents = 1;
    for (final e in data) {
      maxIncidents = e['incidents'] > maxIncidents ? e['incidents'] as int : maxIncidents;
    }
    final double yScale = chartHeight / (maxIncidents * 1.2);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final double y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Build points
    final int n = data.length;
    final double xStep = n > 1 ? chartWidth / (n - 1) : chartWidth;
    final Path linePath = Path();
    final Paint linePaint = Paint()
      ..color = AmbulanceAgencyColorPalette.secondaryAmber
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n; i++) {
      final int val = data[i]['incidents'] as int;
      final double x = paddingLeft + i * xStep;
      final double y = chartHeight - val * yScale;
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);

    // Draw points
    final Paint pointPaint = Paint()
      ..color = AmbulanceAgencyColorPalette.secondaryAmber
      ..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final int val = data[i]['incidents'] as int;
      final double x = paddingLeft + i * xStep;
      final double y = chartHeight - val * yScale;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    // Month labels
    final TextStyle labelStyle = const TextStyle(fontSize: 10, color: Color(0xFF757575));
    for (int i = 0; i < n; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: data[i]['month'] as String, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final double x = paddingLeft + i * xStep - textPainter.width / 2;
      textPainter.paint(canvas, Offset(x, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


