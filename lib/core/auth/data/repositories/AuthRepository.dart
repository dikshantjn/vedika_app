import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    await storage.delete(key: "jwt_token"); // Remove stored JWT
    await storage.delete(key: "user_id"); // Remove stored User ID
    await _auth.signOut(); // Sign out from Firebase
  }
}
