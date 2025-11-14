import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';

/// AuthService merges token storage, OTP verification, and registration logic.
class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Dio _dio = Dio();

  // New: Expose firebase instance for advanced callers
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  // =========================
  // Token/session management
  // =========================

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: "jwt_token", value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: "jwt_token");
  }

  Future<void> logout() async {
    try {
      String? userId = await StorageService.getUserId();
      if (userId != null) {
        // Fire-and-forget: do not block logout on token deletion
        try { FCMService().deleteTokenFromServer(userId); } catch (_) {}
      }
      await _secureStorage.delete(key: "jwt_token");
      await _secureStorage.delete(key: "user_id");
      await _firebaseAuth.signOut();
    } catch (e) {
      // Best-effort cleanup
      await _secureStorage.delete(key: "jwt_token");
      await _secureStorage.delete(key: "user_id");
      await _firebaseAuth.signOut();
    }
  }

  Future<bool> isLoggedIn() async {
    final userId = await StorageService.getUserId();
    return userId != null && userId.isNotEmpty;
  }

  Future<String?> getUserId() async {
    return StorageService.getUserId();
  }

  // =========================
  // OTP: send and verify
  // =========================

  // Optimized phone auth with full callback support (no backend exchange)
  Future<void> startPhoneAuth({
    required String phone,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: timeout,
      verificationCompleted: (PhoneAuthCredential credential) async {
        onVerificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onCodeAutoRetrievalTimeout(verificationId);
      },
    );
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<String?> getIdToken(User user) async {
    return await user.getIdToken();
  }

  Future<void> sendOtp({
    required String phone,
    required Function(String) codeSentCallback,
    required Function(String) verificationCompletedCallback,
    required Function(String) errorCallback,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _firebaseAuth.signInWithCredential(credential);
            verificationCompletedCallback("Verification completed automatically");
          } catch (e) {
            errorCallback("Auto-verification failed: ${e.toString()}");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          errorCallback("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          codeSentCallback(verificationId);
        },
      );
    } catch (e) {
      errorCallback("Error sending OTP: ${e.toString()}");
    }
  }

  /// Verifies OTP with Firebase, then exchanges Firebase ID token with backend for JWT.
  /// Calls [successCallback] with (firebaseUser, jwtToken) on success.
  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
    required Function(String) errorCallback,
    required Function(User, String) successCallback,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        errorCallback("OTP verification failed: No user found.");
        return;
      }

      // Get Firebase ID Token
      final String? idToken = await user.getIdToken();

      // Exchange for backend JWT
      final Response response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        final String jwtToken = response.data['token'];
        // Persist JWT + user id
        await saveToken(jwtToken);
        await StorageService.storeUserId(user.uid);
        successCallback(user, jwtToken);
      } else {
        errorCallback("Backend verification failed");
      }
    } catch (e) {
      errorCallback("OTP verification failed: ${e.toString()}");
    }
  }

  // =========================
  // Registration and platform
  // =========================

  Future<UserModel?> registerUser(String phoneNumber, String authToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.signUp,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $authToken",
          },
        ),
        data: {
          "phone_number": phoneNumber,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final user = UserModel.fromJson(responseData['user']);
        // Token already saved during verifyOtp step.
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePlatform(String phoneNumber, String platform) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updatePlatform,
        data: {
          "phone_number": phoneNumber,
          "platform": platform,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}


