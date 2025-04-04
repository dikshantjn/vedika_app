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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionGranted && !_initializing) {
      _initializeApp();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      var result = await Permission.location.request();
      if (!result.isGranted) {
        return; // User denied, you can show dialog here
      }
    }
    _permissionGranted = true;
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_initializing) return; // Avoid multiple calls
    _initializing = true;

    try {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));

      locationProvider = LocationProvider();
      await locationProvider.loadSavedLocation();
      await getWifiIpAddress();

      emergencyService = EmergencyService(locationProvider);
      emergencyService.initialize();

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final vendorAuthViewModel = Provider.of<VendorLoginViewModel>(context, listen: false);
      final cartViewModel = Provider.of<CartAndPlaceOrderViewModel>(context, listen: false);

      // Fetch Orders and Cart Items for the current user
      await cartViewModel.fetchOrdersAndCartItems();

      await Future.wait([
        authViewModel.checkLoginStatus(),
        vendorAuthViewModel.checkLoginStatus(),
      ]);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Navigate based on the user role (vendor or regular user)
      if (authViewModel.isLoggedIn) {
        // Regular user is logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (vendorAuthViewModel.isVendorLoggedIn) {
        int? role = await _loginService.getVendorRole();
        print("Role from Splash screeen $role");
        // Vendor is logged in, navigate to vendor dashboard based on the role
        await vendorAuthViewModel.navigateToDashboard(context,role);
      } else {
        // User is not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserLoginScreen()),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
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
            colors: [ColorPalette.primaryColor, const Color(0xFF99D98C)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/uploadPrescription.json',
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
                    SizedBox(height: 10),
                    Text(
                      'Your trusted health partner',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

