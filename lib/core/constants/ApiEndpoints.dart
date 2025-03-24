class ApiEndpoints {
  // ✅ Base URL
  static const String baseUrl = "http://192.168.1.42:5000/api";
  // static const String baseUrl = "http://172.20.10.4:5000/api";

  // 📌 Auth APIs
  static const String verifyOtp = '$baseUrl/otp/verify-otp';
  static const String signUp = '$baseUrl/auth/signup';

  // 📌 User Profile APIs
  static const String getUserProfile = '$baseUrl/user';
  static const String saveUserProfile = '$baseUrl/user/save';
  static const String editUserProfile = '$baseUrl/user/edit';

  // 📌 Medical Profile APIs
  static const String medicalProfile = '$baseUrl/medical-profile';
  static const String registerVendor = '$baseUrl/vendors/register';
  static const String loginVendor = '$baseUrl/vendors/login';
  static const String updateMedicalStore = '$baseUrl/vendors/update';
  static const String getVendorProfile = '$baseUrl/vendors/profile';

  // 📌 Medicine Product APIs
  static const String addProduct = '$baseUrl/medicineProduct/add-product';
  static const String getAllProducts = '$baseUrl/medicineProduct/products';
  static const String getProductById = '$baseUrl/medicineProduct/products/';
  static const String updateProduct = '$baseUrl/medicineProduct/products/';
  static const String deleteProduct = '$baseUrl/medicineProduct/products/';

  // 📌 Inventory APIs
  static const String getInventory = '$baseUrl/inventory/vendor';

  // 📌 Prescription Upload API
  static const String uploadPrescription = '$baseUrl/prescription/upload-prescription';
  static const String checkPrescriptionAcceptanceStatus = '$baseUrl/prescription/check-prescription-acceptance';
  static const String getPrescritionRequests = '$baseUrl/prescription/requests';

  static const String acceptPrescriptionRequest = '$baseUrl/prescription/accept-status';
  static const String getOrders = '$baseUrl/orders/getOrders';



}
