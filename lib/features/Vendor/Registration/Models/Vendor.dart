import 'dart:math';

class Vendor {
  int vendorRole; // Role to determine if medical store exists
  String phoneNumber;
  String email;
  String? password; // Making password optional
  String generatedId;

  // Constructor
  Vendor({
    required this.vendorRole,
    required this.phoneNumber,
    required this.email,
    this.password, // password is now optional
    required this.generatedId,
  }) {
    // If password is not provided (null), generate a random one
    if (password == null || password!.isEmpty) {
      password = _generateRandomPassword();
    }
  }

  // Method to convert Vendor to Map for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'vendorRole': vendorRole,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'generatedId': generatedId,
    };
  }

  // Method to generate a random 8-character password
  String _generateRandomPassword([int length = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

//iuUHTlk8