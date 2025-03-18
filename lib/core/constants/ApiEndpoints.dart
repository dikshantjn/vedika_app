class ApiEndpoints {
  // Base URL for your backend
  static const String _baseUrl = "http://192.168.1.41:5000/api";

  // static const String _baseUrl = "http://localhost:5000/api";

  // Auth APIs
  static const String verifyOtp = '$_baseUrl/otp/verify-otp'; // OTP verification
  static const String signUp = '$_baseUrl/auth/signup'; // User registration

  // User Profile APIs
  static const String getUserProfile = '$_baseUrl/user'; // Get User Profile by userId
  static const String saveUserProfile = '$_baseUrl/user/save'; // Save User Profile
  static const String editUserProfile = '$_baseUrl/user/edit'; // Edit User Profile

// Medical Profile APIs
  static const String medicalProfile = '$_baseUrl/medical-profile';
  static const String registerVendor = '$_baseUrl/vendors/register'; // Vendor registration
  static const String loginVendor = '$_baseUrl/vendors/login'; // Vendor registration
  static const String updateMedicalStore = '$_baseUrl/vendors/update'; // Vendor registration


}
