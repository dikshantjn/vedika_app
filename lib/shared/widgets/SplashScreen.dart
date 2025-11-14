import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/viewmodel/SplashViewModel.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Kick off initialization via ViewModel; enforces 1s splash internally
    Future.microtask(() {
      if (mounted) {
        context.read<SplashViewModel>().initialize(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<SplashViewModel>().initialize(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A73E8), // Professional blue
              Color(0xFF34A853), // Healthcare green
            ],
          ),
        ),
        child: Stack(
            children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: HealthcarePatternPainter(),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animation
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/logo/Logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // App name with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                    child: child,
                        ),
                  );
                },
                    child: Column(
                  children: [
                        const Text(
                          'Vedika.Health',
                      style: TextStyle(
                            fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                            letterSpacing: 1.2,
                      ),
                    ),
                        const SizedBox(height: 12),
                        const Text(
                          'Transforming Health, Transforming Lives',
                      style: TextStyle(
                        fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 40),
                  // Loading indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
            ],
          ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for healthcare-themed background pattern
class HealthcarePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw cross pattern
    for (var i = 0.0; i < size.width; i += 40) {
      for (var j = 0.0; j < size.height; j += 40) {
        // Vertical line
        canvas.drawLine(
          Offset(i, j),
          Offset(i, j + 20),
          paint,
        );
        // Horizontal line
        canvas.drawLine(
          Offset(i, j),
          Offset(i + 20, j),
          paint,
        );
      }
    }

    // Draw wave pattern
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0.0; i < size.height; i += 100) {
      final path = Path();
      path.moveTo(0, i);
      
      for (var j = 0.0; j < size.width; j += 50) {
        path.quadraticBezierTo(
          j + 25,
          i + 20,
          j + 50,
          i,
        );
      }
      
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

