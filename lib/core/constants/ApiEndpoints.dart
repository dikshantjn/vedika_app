class ApiEndpoints {
  // Base URL for your backend
  static const String _baseUrl = "http://192.168.1.41:5000/api";

  // Auth APIs
  static const String verifyOtp = '$_baseUrl/otp/verify-otp'; // OTP verification
  static const String signUp = '$_baseUrl/auth/signup'; // User registration

// Other potential APIs can be added here as needed
}
