import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class UserLoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio dio = Dio();
  final AuthRepository _authRepository; // Inject AuthRepository

  UserLoginRepository(this._authRepository); // Constructor injection

  // API URL - Replace with your actual backend API URL
  // final String apiUrl = "http://192.168.1.41:5000/api/otp/verify-otp";

  /// Sends OTP to the given phone number
  Future<void> sendOtp({
    required String phone,
    required Function(String) codeSentCallback,
    required Function(String) verificationCompletedCallback,
    required Function(String) errorCallback,
  }) async {
    try {
      print("🚀 Sending OTP to: $phone");

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            verificationCompletedCallback("✅ Verification completed automatically");
          } catch (e) {
            errorCallback("⚠️ Auto-verification failed: ${e.toString()}");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Verification failed: ${e.message}");
          errorCallback("⚠️ Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          print("📩 OTP Sent! Verification ID: $verificationId");
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("⏳ Auto-retrieval timeout. Verification ID: $verificationId");
          codeSentCallback(verificationId);
        },
      );
    } catch (e) {
      print("❌ Error sending OTP: ${e.toString()}");
      errorCallback("⚠️ Error sending OTP: ${e.toString()}");
    }
  }

  /// Verifies OTP manually and stores JWT
  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
    required Function(String) errorCallback,
    required Function(User, String) successCallback,
  }) async {
    try {
      print("🔍 Verifying OTP: $otp with Verification ID: $verificationId");

      // Create Firebase credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in user with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 🔥 Get Firebase ID Token to send to backend
        String? idToken = await user.getIdToken();
        print("✅ OTP verified. User ID: ${user.uid}, ID Token: $idToken");

        // Step 2: Send the ID Token to the backend for verification
        Response response = await dio.post(
          ApiEndpoints.verifyOtp,
          data: {'idToken': idToken}, // Send ID Token to backend
        );

        if (response.statusCode == 200) {
          // 🔹 Extract JWT from response
          String jwtToken = response.data['token'];
          print("🎉 JWT received: $jwtToken");
          print("🎉 User Id: ${user.uid}");


          // 🔹 Store JWT securely using AuthRepository
          await _authRepository.saveToken(jwtToken);
          await StorageService.storeUserId(user.uid);

          successCallback(user, jwtToken); // Return user & JWT
        } else {
          print("❌ Backend verification failed: ${response.data}");
          errorCallback("Backend verification failed: ${response.data['message']}");
        }
      } else {
        errorCallback("⚠️ OTP verification failed: No user found.");
      }
    } catch (e) {
      print("❌ Error verifying OTP: ${e.toString()}");
      errorCallback("⚠️ OTP verification failed: ${e.toString()}");
    }
  }

}
