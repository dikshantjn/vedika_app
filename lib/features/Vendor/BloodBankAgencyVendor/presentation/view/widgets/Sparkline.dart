import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<int> values;
  final Color color;
  const Sparkline({Key? key, required this.values, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color color;
  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final double width = size.width;
    final double height = size.height;
    final double padding = 6;
    final double chartWidth = width - padding * 2;
    final double chartHeight = height - padding * 2;
    int maxVal = values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1;
    final double yScale = chartHeight / (maxVal * 1.2);
    final double xStep = chartWidth / (values.length - 1);

    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = padding + i * xStep;
      final double y = padding + chartHeight - values[i] * yScale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Paint fill = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final Path area = Path.from(path)
      ..lineTo(padding + chartWidth, padding + chartHeight)
      ..lineTo(padding, padding + chartHeight)
      ..close();

    canvas.drawPath(area, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


