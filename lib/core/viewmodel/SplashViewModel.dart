import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/cart/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/membership/presentation/viewmodel/MembershipViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/ProfileCompletionViewModel.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';

class SplashViewModel extends ChangeNotifier {
  final VendorLoginService _vendorLoginService = VendorLoginService();
  final FCMService _fcmService = FCMService();
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    notifyListeners();

    final Future<void> minSplash = Future.delayed(const Duration(seconds: 1));

    try {
      // Providers
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final vendorAuthVM = Provider.of<VendorLoginViewModel>(context, listen: false);
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      final membershipVM = Provider.of<MembershipViewModel>(context, listen: false);
      final profileCompletionVM = Provider.of<ProfileCompletionViewModel>(context, listen: false);

      // Initialize location and emergency service
      await locationProvider.initializeLocation();
      await EmergencyService.initialize(locationProvider);

      // Setup FCM permissions and token (non-blocking for splash)
      await _fcmService.requestNotificationPermission();
      String? userId = await StorageService.getUserId();
      String? vendorId = await _vendorLoginService.getVendorId();
      if (vendorId != null && vendorId.isNotEmpty && authViewModel.isLoggedIn) {
        // If both user and vendor are logged in, ensure vendor token is saved
        unawaited(_fcmService.getVendorTokenAndSend(vendorId));
      } else {
        if (userId != null && userId.isNotEmpty) {
          unawaited(_fcmService.getTokenAndSend(userId));
        } else if (vendorId != null && vendorId.isNotEmpty) {
          unawaited(_fcmService.getVendorTokenAndSend(vendorId));
        }
      }

      // Check auth states
      await Future.wait([
        authViewModel.checkLoginStatus(),
        vendorAuthVM.checkLoginStatus(),
      ]);

      // Preload counts quickly if user logged in (non-blocking where possible)
      if (authViewModel.isLoggedIn) {
        final uid = await StorageService.getUserId();
        if (uid != null && uid.isNotEmpty) {
          unawaited(cartViewModel.fetchMedicineCartCount(userId: uid));
          unawaited(cartViewModel.fetchProductCartCount());
          // Membership/profile data loaded after navigation
          unawaited(membershipVM.loadPlans());
          unawaited(membershipVM.loadCurrentMembership(uid));
          unawaited(profileCompletionVM.preloadAll(uid));
        }
      }

      // Handle initial notification if app opened from terminated state
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      // Wait for minimum splash time
      await minSplash;

      if (!context.mounted) return;

      // Navigate (prioritize vendor dashboard when both are logged in)
      if (vendorAuthVM.isVendorLoggedIn) {
        int? role = await _vendorLoginService.getVendorRole();
        await vendorAuthVM.navigateToDashboard(context, role);
      } else if (authViewModel.isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }

      // After navigation, process initial notification if any
      if (initialMessage != null) {
        // Ensure a beat so navigator is ready
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          _fcmService.handleNotificationTapWithAppLaunch(
            jsonEncode(initialMessage.data),
            context,
            isAppLaunch: true,
          );
        }
      }
    } catch (_) {
      await minSplash;
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }
}


