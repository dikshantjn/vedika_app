import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';

class AuthRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save JWT token securely
  Future<void> saveToken(String token) async {
    await storage.write(key: "jwt_token", value: token);
  }

  // Get JWT token
  Future<String?> getToken() async {
    return await storage.read(key: "jwt_token");
  }

  // Logout function
  Future<void> logout() async {
    try {
      String? userId = await StorageService.getUserId();
      if (userId != null) {
        await FCMService().deleteTokenFromServer(userId);
      }
      await storage.delete(key: "jwt_token"); // Remove stored JWT
      await storage.delete(key: "user_id"); // Remove stored User ID
      await _auth.signOut(); // Sign out from Firebase
    } catch (e) {
      print('Error during logout: $e');
      // Still try to clear local storage even if FCM token deletion fails
      await storage.delete(key: "jwt_token");
      await storage.delete(key: "user_id");
      await _auth.signOut();
    }
  }
}
