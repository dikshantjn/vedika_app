import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/userLoginScreen.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final vendorAuthViewModel = Provider.of<VendorLoginViewModel>(context, listen: false);

    // ✅ Check both user and vendor login status in parallel
    await Future.wait([
      authViewModel.checkLoginStatus(),
      vendorAuthViewModel.checkLoginStatus(),
    ]);

    print("Final User Login Status: ${authViewModel.isLoggedIn}");
    print("Final Vendor Login Status: ${vendorAuthViewModel.isVendorLoggedIn}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authViewModel.isLoggedIn) {
        print("✅ Navigating to User HomePage...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (vendorAuthViewModel.isVendorLoggedIn) {
        print("✅ Navigating to Vendor Dashboard...");
        Navigator.pushReplacementNamed(context, AppRoutes.VendorMedicalStoreDashBoard);
      } else {
        print("❌ Navigating to Login...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserLoginScreen()), // Default to User Login
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorPalette.primaryColor, const Color(0xFF99D98C)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/uploadPrescription.json', // Replace with your Lottie animation
                height: 150,
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                builder: (context, double opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: const Column(
                  children: [
                    Text(
                      'Vedika - Healthcare App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
