import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/viewmodel/SplashViewModel.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _loaderController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
    _loaderController.dispose();
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
                  AnimatedBuilder(
                    animation: _loaderController,
                    builder: (context, child) {
                      final double scale = 0.98 + (_loaderController.value * 0.04);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 22,
                                spreadRadius: 6,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.10),
                                blurRadius: 8,
                                spreadRadius: -2,
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
                      );
                    },
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
                  // Elegant dot wave loader
                  _DotWaveLoader(controller: _loaderController),
            ],
          ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotWaveLoader extends StatelessWidget {
  final AnimationController controller;
  const _DotWaveLoader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final curved = CurvedAnimation(
            parent: controller,
            curve: Interval(
              (index * 0.12).clamp(0.0, 1.0),
              (index * 0.12 + 0.6).clamp(0.0, 1.0),
              curve: Curves.easeInOut,
            ),
          );
          final scale = Tween<double>(begin: 0.7, end: 1.25).animate(curved);
          final opacity = Tween<double>(begin: 0.5, end: 1.0).animate(curved);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ScaleTransition(
              scale: scale,
              child: FadeTransition(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.25),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
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

