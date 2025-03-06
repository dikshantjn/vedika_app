import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

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
