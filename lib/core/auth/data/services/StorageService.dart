import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Composite session helpers
  static Future<void> saveUserSession({
    required String token,
    required String phone,
    required String uid,
  }) async {
    await _storage.write(key: "auth_token", value: token);
    await _storage.write(key: "phone", value: phone);
    await _storage.write(key: "user_id", value: uid);
  }

  static Future<Map<String, String?>> getUserSession() async {
    final token = await _storage.read(key: "auth_token");
    final phone = await _storage.read(key: "phone");
    final uid = await _storage.read(key: "user_id");
    return {
      'token': token,
      'phone': phone,
      'uid': uid,
    };
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: "auth_token");
    await _storage.delete(key: "phone");
    await _storage.delete(key: "user_id");
  }

  // Store the user ID
  static Future<void> storeUserId(String userId) async {
    await _storage.write(key: "user_id", value: userId);
  }

  // Retrieve the user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: "user_id");
  }

  // Optionally, delete the user ID when the user logs out
  static Future<void> deleteUserId() async {
    await _storage.delete(key: "user_id");
  }
}
