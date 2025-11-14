import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/AuthService.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/features/membership/presentation/viewmodel/MembershipViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/ProfileCompletionViewModel.dart';
import 'package:vedika_healthcare/features/cart/index.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authRepository = AuthService();
  bool _isLoggedIn = false;
  String? redirectRoute;
  dynamic redirectArguments;

  bool get isLoggedIn => _isLoggedIn;

  AuthViewModel() {
    checkLoginStatus(); // ✅ Check if user is logged in when app starts
  }

  Future<void> login(String token) async {
    await _authRepository.saveToken(token); // ✅ Save token securely
    _isLoggedIn = true;
    notifyListeners(); // ✅ Notify UI
  }

  Future<void> checkLoginStatus() async {
    String? token = await _authRepository.getToken();
    print("Retrieved Token: $token"); // ✅ Debugging

    // Ensure token is not null and not empty
    _isLoggedIn = token != null && token.isNotEmpty;
    print("Is Logged In: $_isLoggedIn"); // ✅ Debugging

    notifyListeners();
  }

  Future<void> logout(BuildContext context, {bool navigate = true}) async {
    await _authRepository.logout(); // ✅ Clear token
    _isLoggedIn = false;
    notifyListeners();

    if (!navigate) {
      return; // Skip navigation if caller wants to remain on the same screen
    }

    // Prefer global navigator to avoid using a possibly unmounted context (e.g., drawer just popped)
    final navState = navigatorKey.currentState;
    if (navState != null) {
      navState.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    // Fallback: if context is still mounted, schedule navigation next frame
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      });
    }
  }

  // =========================
  // Login flow (merged from UserLoginViewModel)
  // =========================
  // State enum for MVVM consumers
  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;
  bool _isOtpSent = false;
  String? _verificationId;
  bool _isVerified = false;
  String _phoneNumber = '';
  bool _isVerifying = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  bool get isOtpSent => _isOtpSent;
  bool get isVerified => _isVerified;
  String get phoneNumber => _phoneNumber;
  bool get isVerifying => _isVerifying;

  void setRedirect(String? route, dynamic args) {
    redirectRoute = route;
    redirectArguments = args;
  }

  Future<void> startPhoneAuth(String phone, {String? route, dynamic args}) async {
    setRedirect(route, args);
    _phoneNumber = phone;
    _status = AuthStatus.sendingOtp;
    _setLoadingState(true);
    _resetError();
    _setInfo(null);
    notifyListeners();

    try {
      await _authRepository.startPhoneAuth(
        phone: phone,
        onVerificationCompleted: (credential) async {
          await autoVerify(credential);
        },
        onVerificationFailed: (error) {
          _status = AuthStatus.error;
          _setError(error.message ?? "Phone verification failed");
        },
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _isOtpSent = true;
          _status = AuthStatus.otpSent;
          _setLoadingState(false);
          _setInfo("OTP sent to ${_maskedPhone()}");
          notifyListeners();
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
          if (_status != AuthStatus.loggedIn) {
            _status = AuthStatus.otpSent;
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _status = AuthStatus.error;
      _setError("Failed to start phone auth: ${e.toString()}");
    }
  }

  Future<void> autoVerify(PhoneAuthCredential credential) async {
    _status = AuthStatus.verifying;
    _isVerifying = true;
    notifyListeners();
    await signInWithCredential(credential);
  }

  Future<void> sendOtp(String phone) async {
    _phoneNumber = phone;
    _setLoadingState(true);
    _resetError();
    _setInfo(null);

    try {
      // Immediately show OTP UI
      _isOtpSent = true;
      notifyListeners();

      await _authRepository.sendOtp(
        phone: phone,
        codeSentCallback: (verificationId) {
          _verificationId = verificationId;
          _setLoadingState(false);
          _setInfo("OTP sent to ${_maskedPhone()}\u00A0\u2713");
        },
        verificationCompletedCallback: (autoVerifyMessage) {
          print(autoVerifyMessage);
          _isVerified = true;
          _setLoadingState(false);
        },
        errorCallback: (error) {
          _setError(error);
          _setInfo(null);
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

    _status = AuthStatus.verifying;
    _setLoadingState(true);
    _isVerifying = true;
    notifyListeners();
    _resetError();
    _setInfo(null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await signInWithCredential(credential, context: context);
    } catch (e) {
      _setError("OTP verification failed: ${e.toString()}");
    } finally {
      _setLoadingState(false);
      _isVerifying = false;
      notifyListeners();
    }
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential, {BuildContext? context}) async {
    try {
      final userCredential = await _authRepository.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        _status = AuthStatus.error;
        _setError("Sign in failed: no user.");
        return;
      }

      final idToken = await _authRepository.getIdToken(user);

      // Persist session
      await StorageService.saveUserSession(
        token: idToken ?? '',
        phone: user.phoneNumber ?? _phoneNumber,
        uid: user.uid,
      );
      await StorageService.storeUserId(user.uid);

      // Optional: device/platform updates or prefetches could be added back here if needed

      _isOtpSent = false;
      _isVerified = true;
      _status = AuthStatus.loggedIn;
      await login(idToken ?? ''); // keep existing listeners in sync

      // Fire-and-forget: send FCM token without blocking login flow
      try {
        FCMService().getTokenAndSend(user.uid);
      } catch (_) {}

      // Trigger any additional updates that rely on providers (optional, skipped for speed)
      if (context != null) {
        final BuildContext providerContext = navigatorKey.currentContext ?? context;
        final cartViewModel = Provider.of<CartViewModel>(providerContext, listen: false);
        final membershipViewModel = Provider.of<MembershipViewModel>(providerContext, listen: false);
        final profileCompletionVM = Provider.of<ProfileCompletionViewModel>(providerContext, listen: false);
        final locationProvider = Provider.of<LocationProvider>(providerContext, listen: false);

        // Fire-and-forget to keep UI snappy
        locationProvider.updateLocationAfterLogin();
        final userId = user.uid;
        membershipViewModel.loadPlans();
        membershipViewModel.loadCurrentMembership(userId);
        profileCompletionVM.preloadAll(userId);
        cartViewModel.fetchMedicineCartCount(userId: userId);
        cartViewModel.fetchProductCartCount();
      }
    } catch (e) {
      _status = AuthStatus.error;
      _setError("Sign in failed: ${e.toString()}");
    }
  }

  Future<void> resendOtp() async {
    if (_phoneNumber.isEmpty) {
      _setError("Contact number is not available.");
      return;
    }
    await sendOtp(_phoneNumber);
  }

  void _setLoadingState(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  void _resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _setInfo(String? message) {
    _infoMessage = message;
    notifyListeners();
  }

  String _maskedPhone() {
    if (_phoneNumber.isEmpty) return '';
    final digits = _phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    final last4 = digits.substring(digits.length - 4);
    return '+91 ••••••$last4';
  }
}

enum AuthStatus {
  idle,
  sendingOtp,
  otpSent,
  verifying,
  loggedIn,
  error,
}
