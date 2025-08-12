import 'package:flutter/material.dart';

class OrdersRevenueChart extends StatelessWidget {
  final List<String> days;
  final List<int> dailyOrders;
  final List<double> dailyRevenue;
  const OrdersRevenueChart({
    Key? key,
    required this.days,
    required this.dailyOrders,
    required this.dailyRevenue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OrdersRevenuePainter(
        days: days,
        dailyOrders: dailyOrders,
        dailyRevenue: dailyRevenue,
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _OrdersRevenuePainter extends CustomPainter {
  final List<String> days;
  final List<int> dailyOrders;
  final List<double> dailyRevenue;
  _OrdersRevenuePainter({
    required this.days,
    required this.dailyOrders,
    required this.dailyRevenue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double chartHeight = height - 24; // space for labels

    final int n = days.length;
    final double xStep = n > 1 ? width / (n - 1) : width;

    // find max
    final double maxOrders = (dailyOrders.isEmpty ? 1 : dailyOrders.reduce((a, b) => a > b ? a : b)).toDouble();
    final double maxRevenue = dailyRevenue.isEmpty ? 1 : dailyRevenue.reduce((a, b) => a > b ? a : b);
    final double maxValue = (maxOrders > maxRevenue ? maxOrders : maxRevenue) * 1.2;

    // grid
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final double y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // orders line
    final Path ordersPath = Path();
    final Paint ordersPaint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < n; i++) {
      final double x = i * xStep;
      final double y = chartHeight - (chartHeight * (dailyOrders[i] / maxValue));
      if (i == 0) {
        ordersPath.moveTo(x, y);
      } else {
        ordersPath.lineTo(x, y);
      }
    }
    canvas.drawPath(ordersPath, ordersPaint);

    // revenue area
    final Path revenuePath = Path();
    final Paint revenueLine = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Paint revenueFill = Paint()
      ..color = Colors.green.shade600.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final double x = i * xStep;
      final double y = chartHeight - (chartHeight * (dailyRevenue[i] / maxValue));
      if (i == 0) {
        revenuePath.moveTo(x, y);
      } else {
        revenuePath.lineTo(x, y);
      }
    }
    final Path revenueArea = Path.from(revenuePath)
      ..lineTo((n - 1) * xStep, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();
    canvas.drawPath(revenueArea, revenueFill);
    canvas.drawPath(revenuePath, revenueLine);

    // x labels
    final textStyle = TextStyle(color: Colors.grey.shade600, fontSize: 10);
    for (int i = 0; i < n; i++) {
      final tp = TextPainter(
        text: TextSpan(text: days[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(i * xStep - tp.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


