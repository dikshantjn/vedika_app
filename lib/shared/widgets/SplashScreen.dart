import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/userLoginScreen.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/main.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  late LocationProvider locationProvider;
  late EmergencyService emergencyService;
  bool _initializing = false;
  bool _permissionGranted = false;
  final VendorLoginService _loginService = VendorLoginService();
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_initializing) {
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    if (_initializing) return;
    _initializing = true;

    try {
      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (_initializing) {
          _initializing = false;
          _navigateToLogin();
        }
      });

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));

      locationProvider = LocationProvider();
      await locationProvider.initializeLocation();
      await getWifiIpAddress();

      emergencyService = EmergencyService(locationProvider);
      emergencyService.initialize();

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final vendorAuthViewModel = Provider.of<VendorLoginViewModel>(context, listen: false);
      final cartViewModel = Provider.of<CartAndPlaceOrderViewModel>(context, listen: false);

      await cartViewModel.fetchOrdersAndCartItems();

      await Future.wait([
        authViewModel.checkLoginStatus(),
        vendorAuthViewModel.checkLoginStatus(),
      ]);

      if (!mounted) return;

      if (authViewModel.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (vendorAuthViewModel.isVendorLoggedIn) {
        int? role = await _loginService.getVendorRole();
        await vendorAuthViewModel.navigateToDashboard(context, role);
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print("❌ Error during initialization: $e");
      _navigateToLogin();
    } finally {
      _timeoutTimer?.cancel();
      _initializing = false;
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserLoginScreen()),
    );
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      child: ClipOval(
                        child: Container(
                          width: 130,
                          height: 110,
                          child: Image.asset(
                            'assets/logo/Logo.png',
                            fit: BoxFit.cover,
                          ),
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
                          'Vedika Health Care',
                      style: TextStyle(
                            fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                            letterSpacing: 1.2,
                      ),
                    ),
                        const SizedBox(height: 12),
                        const Text(
                          'Connecting You to Better Health',
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

