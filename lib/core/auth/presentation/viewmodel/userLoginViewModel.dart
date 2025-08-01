import 'dart:io'; // Make sure this is imported at the top
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/SignUpRepository.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/UserLoginRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class UserLoginViewModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey; // Add navigatorKey
  final AuthRepository _authRepository;
  final UserLoginRepository _signupRepository;
  final SignUpRepository _signUpRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isOtpSent = false;
  String? _verificationId;
  bool _isVerified = false;
  String _phoneNumber = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  bool get isVerified => _isVerified;
  String get phoneNumber => _phoneNumber;
  UserModel? _user;

  UserModel? get user => _user;

  /// Constructor
  UserLoginViewModel({required this.navigatorKey}) // Accept navigatorKey
      : _authRepository = AuthRepository(),
        _signupRepository = UserLoginRepository(AuthRepository()),
        _signUpRepository = SignUpRepository(AuthRepository());

  /// Sends OTP to the given phone number
  Future<void> sendOtp(String phone) async {
    _phoneNumber = phone;
    _setLoadingState(true);
    _resetError();

    try {
      await _signupRepository.sendOtp(
        phone: phone,
        codeSentCallback: (verificationId) {
          _verificationId = verificationId;
          _isOtpSent = true;
          _setLoadingState(false);
        },
        verificationCompletedCallback: (autoVerifyMessage) {
          print(autoVerifyMessage);
          _isVerified = true;
          _setLoadingState(false);
        },
        errorCallback: (error) {
          _setError(error);
        },
      );
    } catch (e) {
      _setError("Failed to send OTP: ${e.toString()}");
    }
  }


  Future<void> verifyOtp(String otp, BuildContext context) async {
    if (_verificationId == null) {
      _setError("Verification ID not found. Please request OTP again.");
      return;
    }

    _setLoadingState(true);
    _resetError();

    try {
      // Get LocationProvider early while context is still valid
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);

      await _signupRepository.verifyOtp(
        verificationId: _verificationId!,
        otp: otp,
        errorCallback: (error) {
          _setError(error);
          _setLoadingState(false);
        },
        successCallback: (user, idToken) async {
          _isOtpSent = false;
          _isVerified = true;
          notifyListeners();

          print("✅ User Verified! Checking Registration...");

          // Detect platform
          String platform = Platform.isAndroid
              ? 'android'
              : Platform.isIOS
              ? 'ios'
              : 'unknown';

          // Attempt to register user
          UserModel? registeredUser = await _signUpRepository.registerUser(
            user.phoneNumber!,
            idToken,
          );

          // 🟢 Regardless of registration, update platform
          await _signUpRepository.updatePlatform(user.phoneNumber!, platform);

          if (registeredUser != null) {
            print("✅ User Registered: ${registeredUser.userId}");
            if (registeredUser.userId.isNotEmpty) {
              await FCMService().getTokenAndSend(registeredUser.userId);
            }
          } else {
            print("⚠️ User already exists or registration failed.");
          }

          // Store user ID first
          await StorageService.storeUserId(user.uid);
          
          // Update location before navigation
          await locationProvider.updateLocationAfterLogin();

          // Get FCM token and send
          String? userId = await StorageService.getUserId();
          if (userId != null) {
            await FCMService().getTokenAndSend(userId);
          }

          // Navigate to home only if navigator is still valid
          if (navigatorKey.currentState != null) {
            print("🚀 Navigating to Home Page...");
            navigatorKey.currentState!.pushReplacementNamed(AppRoutes.home);
          } else {
            print("⚠️ Navigator state is no longer valid, skipping navigation.");
          }
        },
      );
    } catch (e) {
      _setError("OTP verification failed: ${e.toString()}");
    } finally {
      _setLoadingState(false);
    }
  }



  /// Resends OTP using the stored phone number
  Future<void> resendOtp() async {
    if (_phoneNumber.isEmpty) {
      _setError("Phone number is not available.");
      return;
    }
    await sendOtp(_phoneNumber);
  }

  /// Sets loading state
  void _setLoadingState(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  /// Resets error state
  void _resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sets an error message
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
