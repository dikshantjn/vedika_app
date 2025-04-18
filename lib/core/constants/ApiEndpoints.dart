class ApiEndpoints {
  // ✅ Base URL
  static const String baseUrl = "http://192.168.1.45:5000/api";
  // static const String baseUrl = "http://192.168.1.46:5000/api";
  // static const String baseUrl = "https://vedika-healthcare-backend-257351484310.us-central1.run.app/api";


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

  static const String acceptPrescriptionStatus = '$baseUrl/prescription/accept-status';
  static const String getOrders = '$baseUrl/orders/getOrders';
  static const String getPrescriptionUrl = '$baseUrl/prescription';
  static const String getMedicineSuggestions = '$baseUrl/orders/search';
  static const String placeOrder = '$baseUrl/orders/getOrders';


  // 📌 Cart APIs
  static const String addToCart = '$baseUrl/cart/add';        // Add item to cart
  static const String fetchCart = '$baseUrl/cart';            // Fetch cart items
  static const String clearCart = '$baseUrl/cart/clear';      // Clear the cart
  static const String getCartItemByOrderId = '$baseUrl/cart';      // Clear the cart
  static const String deleteCartItem = '$baseUrl/cart/delete';      // Clear the cart

  static const String getCartItemsByUserId = '$baseUrl/user/orders';      // Clear the cart
  static const String fetchOrdersByUserId = '$baseUrl/user/orders'; // Fetch pending orders by userId
  static const String fetchProductByCartId = '$baseUrl/user/cart';  // Endpoint for fetching product details by cartId

  static const String updateCartQuantity = '$baseUrl/cart/update-quantity';
  static const String acceptOrder = '$baseUrl/orders';
  static const String getOrderStatus = '$baseUrl/orders';

  static const String deliveryAddress = '$baseUrl/deliveryAddress/delivery-address';
  static const String getDeliveryAddresses = '$baseUrl/deliveryAddress/getDeliveryAddress';
  static const String deleteDeliveryAddress = '$baseUrl/deliveryAddress/deleteDeliveryAddress';
  static const String placedOrderWithPayment = '$baseUrl/orders/update-order';
  static const String updateOrderStatus = '$baseUrl/orders';
  static const String trackOrder = '$baseUrl/orders';
  static const String updatePrescriptionStatus = '$baseUrl/orders';


  static const String saveFcmToken = '$baseUrl/fcm/save-token';
  static const String saveVendorFcmToken = '$baseUrl/fcm/vendor/update';
  static const String removeFcmToken = '$baseUrl/fcm/delete-token';
  static const String removeVendorFcmToken = '$baseUrl/fcm/vendor/delete';

  static const String getMedicalStoreVendorById = '$baseUrl/vendor';

// 📌 Vendor APIs
  static const String toggleVendorStatus = '$baseUrl/vendors/toggle-status';
  static const String getVendorStatus = '$baseUrl/vendors/status';
  static const String getOrdersForOrderHistory = '$baseUrl/orders';


  static const String registerAmbulanceAgency = '$baseUrl/ambulance/register-agency';
  static const String getAmbulanceAgencyProfile = '$baseUrl/ambulance/profile';
  static const String updateMediaItem = '$baseUrl/ambulance/ambulance-agency';
  static const String deleteMediaItem = '$baseUrl/ambulance/ambulance-agency';
  static const String addMediaItem = '$baseUrl/ambulance/ambulance-agency';
  static const String updateAgencyProfile = '$baseUrl/ambulance/ambulance-agency';
  static const String getAmbulances = "$baseUrl/ambulance/ambulances";
  static const String createAmbulanceBooking = '$baseUrl/ambulanceBooking/request';
  static const String getPendingAmbulanceBookings = '$baseUrl/ambulanceBooking/pending';
  static const String acceptAmbulanceBooking = '$baseUrl/ambulanceBooking/accept-booking';
  static const String getAmbulanceBookingStatus = '$baseUrl/ambulanceBooking/booking-status';
  static const String getVehicleTypes = '$baseUrl/ambulance/ambulance-agency/vehicle-types';
  static const String updateAmbulanceServiceDetails = '$baseUrl/ambulanceBooking/update-service-details';
  static const String getActiveAmbulanceRequests = '$baseUrl/ambulanceBooking/active-requests/user';
  static const String completeAmbulanceBookingPayment = '$baseUrl/ambulanceBooking/update-payment-completed';

  static const String updateBookingStatusOnTheWay = '$baseUrl/ambulanceBooking/update-status/on-the-way';
  static const String updateBookingStatusPickedUp = '$baseUrl/ambulanceBooking/update-status/picked-up';
  static const String updateBookingStatusCompleted = '$baseUrl/ambulanceBooking/update-status/completed';
  static const String getCompletedRequestsByUserEndpoint = "$baseUrl/ambulanceBooking/completed-requests";
  static const String getCompletedRequestsByVendorEndpoint = "$baseUrl/ambulanceBooking/completed/vendor"; // e.g. /completed/vendor/:vendorId

  static const String bloodBankRegistration = "$baseUrl/blood-bank/register"; // e.g. /completed/vendor/:vendorId
  static const String bloodBankProfile = "$baseUrl/blood-bank/profile"; // e.g. /blood-bank/profile/:vendorId
  static const String AddBloodAvaibility = "$baseUrl/blood-bank/upsert"; // e.g. /blood-bank/profile/:vendorId
  static const String getBloodAvaibility = "$baseUrl/blood-bank/vendor"; // e.g. /blood-bank/profile/:vendorId
  static const String deleteBloodAvaibility = "$baseUrl/blood-bank/blood-inventory"; // e.g. /blood-bank/profile/:vendorId
  static const String getNearestBloodBankAndSendRequest = "$baseUrl/blood-bank/requests"; // e.g. /blood-bank/profile/:vendorId
  static const String getAllBloodBankAgencies = "$baseUrl/blood-bank/blood-bank-agencies"; // e.g. /blood-bank/profile/:vendorId
  static const String getAllBloodBankRequestByVendorId = "$baseUrl/blood-bank/vendor"; // e.g. /blood-bank/profile/:vendorId
  static const String updateBBrequestStatus = "$baseUrl/blood-bank/requests"; // e.g. /blood-bank/profile/:vendorId
  static const String acceptBloodBankRequest = "$baseUrl/blood-bank/requests"; // e.g. /blood-bank/requests/:requestId/accept
  static const String getBloodBankBookingsByVendorId = "$baseUrl/blood-bank-bookings/vendor"; // e.g. /blood-bank/profile/:vendorId
  static const String getBloodBankRequestById = "$baseUrl/blood-bank/requests"; // e.g. /blood-bank/profile/:vendorId
  static const String BloodBlankBookingwaitingforPaytmentStatus = "$baseUrl/blood-bank-bookings"; // e.g. /blood-bank/profile/:vendorId
  static const String getBloodBankBookingsByUserId = "$baseUrl/blood-bank-bookings/user"; // e.g. /blood-bank/profile/:vendorId
  static const String updatePaymentDetails = "$baseUrl/blood-bank-bookings"; // e.g. /blood-bank/profile/:vendorId
  static const String updateBookingStatusAsWaitingForPickup = "$baseUrl/blood-bank-bookings"; // e.g. /blood-bank/profile/:vendorId
  static const String BloodBankBookings = "$baseUrl/blood-bank-bookings"; // e.g. /blood-bank/profile/:vendorId
  static const String getCompletedBloodBankBookingsByUserId = "$baseUrl/blood-bank-bookings/user"; // e.g. /blood-bank-bookings/user/:userId/completed
  static const String getBloodBankRequestByUserId = "$baseUrl/blood-bank-bookings/user"; // e.g. /blood-bank/profile/:vendorId
  static const String registerHospital = "$baseUrl/hospitals/register"; // e.g. /blood-bank/profile/:vendorId
  static const String getHospitalProfile = "$baseUrl/hospitals/register"; // e.g. /blood-bank/profile/:vendorId
  static const String updateHospitalProfile = "$baseUrl/hospitals/register"; // e.g. /blood-bank/profile/:vendorId

}
