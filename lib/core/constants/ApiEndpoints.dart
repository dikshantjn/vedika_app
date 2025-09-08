class ApiEndpoints {
  // ✅ Base URL
  // static const String socketUrl = "http://192.168.1.36:5000";  // Current IP address
  // static const String baseUrl = "http://192.168.1.36:5000/api";  // Current IP address
  // static const String baseUrl = "https://vedika-healthcare-backend-257351484310.us-central1.run.app/api";
  // static const String socketUrl = "https://vedika-healthcare-backend-257351484310.us-central1.run.app";  // Current IP address
  // static const String socketUrl = "http://172.20.10.5:5000";  // Current IP address
  // static const String baseUrl = "http://172.20.10.5:5000/api";  // Current IP address

  static const String socketUrl = "https://947a075b3d46.ngrok-free.app";
  static const String baseUrl = "https://947a075b3d46.ngrok-free.app/api";


  // 📌 Auth APIs
  static const String verifyOtp = '$baseUrl/otp/verify-otp';
  static const String signUp = '$baseUrl/auth/signup';
  static const String updatePlatform = '$baseUrl/auth/platform-update';

  // 📌 User Profile APIs
  static const String getUserProfile = '$baseUrl/user';
  static const String saveUserProfile = '$baseUrl/user/save';
  static const String editUserProfile = '$baseUrl/user/edit';
  static const String updateUserProfile = '$baseUrl/user/update-profile';  // Added new endpoint
  static const String updateUserCoordinates = '$baseUrl/user/update-coordinates';  // NEW: endpoint for updating user coordinates

  // 📌 Medical Profile APIs
  static const String medicalProfile = '$baseUrl/medical-profile';
  static const String registerVendor = '$baseUrl/vendors/register';
  static const String loginVendor = '$baseUrl/vendors/login';
  static const String logoutVendor = '$baseUrl/vendors/logout';
  static const String updateMedicalStore = '$baseUrl/vendors/update';
  static const String getVendorProfile = '$baseUrl/vendors/profile';

  // 📌 Clinic APIs
  static const String registerClinic = '$baseUrl/clinic/register-clinic';
  static const String getClinicProfile = '$baseUrl/clinic/profile';
  static const String updateClinicProfile = '$baseUrl/clinic/profile';
  static const String getActiveOfflineClinics = '$baseUrl/clinic/active/offline';
  static const String getActiveOnlineClinics = '$baseUrl/clinic/active/online';
  static const String createClinicAppointment = '$baseUrl/clinic-appointments';
  static const String generateMettingLink = '$baseUrl/clinic-appointments';
  static const String generateMeetingUrl = '$baseUrl/clinic-appointments/appointments';  // NEW: endpoint for generating meeting URL
  static const String completeClinicAppointment = '$baseUrl/clinic-appointments/complete';  // NEW: endpoint for marking appointment as completed after meeting ends
  static const String getClinicAppointmentsByUserId = '$baseUrl/clinic-appointments/user'; // Example: /clinic-appointments/user/:userId
  static const String getPendingClinicAppointmentsByVendor = '$baseUrl/clinic-appointments/vendor'; // E.g. /clinic-appointments/vendor/:vendorId/pending
  static const String getCompletedClinicAppointmentsByVendor = '$baseUrl/clinic-appointments/vendor'; // E.g. /clinic-appointments/vendor/:vendorId/completed
  static const String getOngoingMeetings = '$baseUrl/clinic-appointments/ongoing-meetings';
  static const String shareHealthRecords = '$baseUrl/clinic-appointments/share-health-records';
  static const String getHealthRecordsByAppointmentId = '$baseUrl/clinic-appointments/health-records';  // NEW: endpoint for getting health records by appointment ID
  static const String updateClinicAppointmentNote = '$baseUrl/clinic-appointments'; // PUT /clinic-appointments/:appointmentId/note
  static const String uploadClinicAppointmentFiles = '$baseUrl/clinic-appointments'; // POST /clinic-appointments/:appointmentId/files
  static const String rescheduleClinicAppointment = '$baseUrl/clinic-appointments'; // PUT /clinic-appointments/:appointmentId/reschedule
  static const String updateAppointmentAttendance = '$baseUrl/clinic-appointments'; // PUT /clinic-appointments/:appointmentId/attendance

  // 📌 Medicine Product APIs
  static const String addProduct = '$baseUrl/medicineProduct/add-product';
  static const String getAllProductsbyVendor = '$baseUrl/medicineProduct/products/vendor';
  static const String getProductById = '$baseUrl/medicineProduct/products/';
  static const String updateProduct = '$baseUrl/medicineProduct/products/';
  static const String deleteProduct = '$baseUrl/medicineProduct/products/';

  // 📌 Inventory APIs
  static const String getInventory = '$baseUrl/inventory/vendor';

  // 📌 Prescription Upload API
  static const String uploadPrescription = '$baseUrl/prescription/upload-prescription';
  static const String checkPrescriptionAcceptanceStatus = '$baseUrl/prescription/check-prescription-acceptance';
  static const String getPrescritionRequests = '$baseUrl/prescription/requests';
  static const String searchMoreVendors = '$baseUrl/prescription'; // Base URL for prescription endpoints
  static const String verifyPrescription = '$baseUrl/prescription/verify-prescription'; // New endpoint for prescription verification

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
  static const String trackOrder = '$baseUrl/orders';
  static const String updatePrescriptionStatus = '$baseUrl/orders';
  static const String enableSelfDelivery = '$baseUrl/orders';  // PATCH to enable self delivery
  static const String getSelfDeliveryStatus = '$baseUrl/orders';  // GET to check self delivery status


  static const String saveFcmToken = '$baseUrl/fcm/save-token';
  static const String saveVendorFcmToken = '$baseUrl/fcm/vendor/update';
  static const String removeFcmToken = '$baseUrl/fcm/delete-token';
  static const String removeVendorFcmToken = '$baseUrl/fcm/vendor/delete';

  static const String getMedicalStoreVendorById = '$baseUrl/vendor';

// 📌 Vendor APIs
  static const String toggleVendorStatus = '$baseUrl/vendors/toggle-status';
  static const String getVendorStatus = '$baseUrl/vendors/status';
  static const String getOrdersForOrderHistory = '$baseUrl/orders';
  static const String registerProductPartner = '$baseUrl/productPartner/register-product-partner';
  static const String getProductPartnerProfile = '$baseUrl/productPartner/vendor';
  static const String getProductPartnerOverview = '$baseUrl/productPartner/vendor';
  static const String addProductPartnerProduct = '$baseUrl/vendor-product/add';
  static const String getVendorProducts = '$baseUrl/vendor-product/products/vendor';  // Get all products for a vendor
  static const String getVendorProduct = '$baseUrl/vendor-product/products';  // Get a single product
  static const String updateVendorProduct = '$baseUrl/vendor-product/products';  // Update a product
  static const String deleteVendorProduct = '$baseUrl/vendor-product/products';  // Delete a product
  static const String getProductsByCategory = '$baseUrl/vendor-product/get-product-by-category';  // Get products by category
  static const String addToProductCart = '$baseUrl/product-cart/add';  // Add item to product cart
  static const String checkProductInCart = '$baseUrl/product-cart/check';  // Check if product is in cart
  static const String getProductCartItems = '$baseUrl/product-cart/get-cart-items';  // Get product cart items
  static const String deleteProductCartItem = '$baseUrl/product-cart/delete-cart-item';  // Delete product cart item
  static const String updateProductCartQuantity = '$baseUrl/product-cart/update-cart-item-qantity';  // Update product cart quantity

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
  static const String registerHospital = "$baseUrl/hospitals/register";
  static const String getHospitalProfile = "$baseUrl/hospitals/profile";
  static const String updateHospitalProfile = "$baseUrl/hospitals/profile";
  static const String getHospitalProfileById = "$baseUrl/hospitals/profile";
  static const String getAllHospitals = "$baseUrl/hospitals/getAllHospitals";
  static const String createBedBooking = "$baseUrl/hospitals/bed-booking";
  static const String getHospitalBookingsByVendor = "$baseUrl/hospitals/by-vendor";
  static const String acceptAppointment = "$baseUrl/hospitals/appointment/accept";
  static const String notifyUserPayment = "$baseUrl/hospitals/appointment/notify-payment";
  static const String getUserOngoingBookings = "$baseUrl/hospitals/by-user";
  static const String updatePaymentStatus = "$baseUrl/hospitals/appointment/payment-status";
  static const String getCompletedBookingsByVendor = "$baseUrl/hospitals/appointment/completed/vendor";
  static const String getCompletedAppointmentsByUser = "$baseUrl/hospitals/appointment/completed/user";
  static const String updateBedAvailability = "$baseUrl/hospitals/updateBed";
  // Add ward management endpoints
  static const String addWard = "$baseUrl/hospitals/wards";
  static const String editWard = "$baseUrl/hospitals/wards";

  // 📌 Clinic Time Slots APIs
  static const String getClinicTimeslotsByVendor = '$baseUrl/clinic-timeslots/vendor'; // /clinic-timeslots/vendor/:vendorId
  static const String getClinicTimeslotsByVendorAndDate = '$baseUrl/clinic-timeslots/vendor'; // /clinic-timeslots/vendor/:vendorId/date/:date
  static const String createClinicTimeslot = '$baseUrl/clinic-timeslots'; // POST /clinic-timeslots
  static const String updateClinicTimeslot = '$baseUrl/clinic-timeslots'; // PUT /clinic-timeslots/:timeSlotID
  static const String deleteClinicTimeslot = '$baseUrl/clinic-timeslots'; // DELETE /clinic-timeslots/:timeSlotID

  // 📌 Lab Test APIs
  static const String uploadFile = '$baseUrl/lab-test/upload-file';
  static const String uploadMultipleFiles = '$baseUrl/lab-test/upload-multiple-files';
  static const String registerDiagnosticCenter = '$baseUrl/lab-test/register';
  static const String getAllLabDiagnosticCenters = '$baseUrl/lab-test/all-diagnostic-centers';
  static const String createLabTestBooking = '$baseUrl/labtest-booking/create';
  static const String getPendingBookingsByVendorId = '$baseUrl/labtest-booking/bookings/vendor/pending';
  static const String acceptLabTestBooking = '$baseUrl/labtest-booking/bookings/accept';
  static const String getAcceptedBookingsByVendorId = '$baseUrl/labtest-booking/bookings/vendor/accepted';
  static const String getCompletedBookingsByVendorId = '$baseUrl/labtest-booking/bookings/vendor/completed';
  static const String updateLabTestBookingStatus = '$baseUrl/labtest-booking/bookings/update-status';
  static const String updateLabTestReportUrls = '$baseUrl/labtest-booking/update-labtest-report-urls';  // NEW: endpoint for updating report URLs
  static const String getCompletedLabTestBookingsByUserId = '$baseUrl/labtest-booking/bookings/user/completed'; // NEW: endpoint for getting completed lab test bookings by user ID

  // New Lab Test Profile APIs
  static const String getLabProfile = '$baseUrl/lab-test/profile';
  static const String updateLabProfile = '$baseUrl/lab-test/profile';

  // 📌 Product Order APIs
  static const String placeProductOrder = '$baseUrl/product-order/order';
  static const String getPendingOrdersByVendorId = '$baseUrl/product-order/pending-orders';  // Get pending orders by vendor ID
  static const String getConfirmedOrdersByVendorId = '$baseUrl/product-order/confirmed-orders';  // Get confirmed orders by vendor ID
  static const String getDeliveredOrdersByVendorId = '$baseUrl/product-order/delivered-orders';  // Get delivered orders by vendor ID
  static const String updateProductOrderStatus = '$baseUrl/product-order/order';  // Update product order status
  static const String getProductOrdersByUserId = '$baseUrl/product-order/orders/user';  // Get product orders by user ID
  static const String getDeliveredProductOrdersByUserId = '$baseUrl/product-order/orders/user';  // Get delivered product orders by user ID

  // 📌 VedikaAI Prescription Scanning API
  static const String scanPrescription = '$baseUrl/ai/scanPrescription';
  static const String interpretSymptoms = '$baseUrl/ai/symptoms/interpret';  // NEW: endpoint for VedikaAI symptoms interpretation
  static const String analyzePrescription = '$baseUrl/ai/analyze-prescription';  // NEW: endpoint for analyzing prescription
  static const String verifyPrescriptionText = '$baseUrl/ai/verify-prescription'; // NEW: endpoint for verifying prescription text

  // 📌 Health Record APIs
  static const String addHealthRecord = '$baseUrl/health-record/add-health-record';
  static const String getHealthRecords = '$baseUrl/health-record/get-health-record';
  static const String deleteHealthRecord = '$baseUrl/health-record/delete-health-record';
  static const String checkHealthRecordPassword = '$baseUrl/health-record/user';
  static const String setHealthRecordPassword = '$baseUrl/health-record/user';
  static const String verifyHealthRecordPassword = '$baseUrl/health-record/user';

  static const String fallAlert = '$baseUrl/emergency/fall-alert';

  // 📌 Medicine Order Invoice API
  static const String generateMedicineOrderInvoice = '$baseUrl/orders/medicine-order-generate-invoice';  // NEW: endpoint for generating medicine order invoice
  static const String getPrescriptionData = '$baseUrl/orders';  // NEW: endpoint for generating medicine order invoice
  static const String blogPosts = '$baseUrl/blogs/posts';

  // 📌 SpeakAI
  static const String speakAIIntent = '$baseUrl/speakAI/intent';

  // 📌 Membership APIs
  static const String getMembershipPlans = '$baseUrl/membership/plans';
  static const String createMembershipOrder = '$baseUrl/membership/order';
  static const String verifyMembershipPayment = '$baseUrl/membership/verify-payment';

  // 📌 Medicine Delivery APIs
  static const String getMedicalStores = '$baseUrl/medicine-delivery/medicalstores';
  static const String sendPrescription = '$baseUrl/medicine-delivery/send';
  static const String getPendingPrescriptions = '$baseUrl/medicine-delivery/prescriptions/pending';
  static const String acceptPrescription = '$baseUrl/medicine-delivery/prescriptions';
  static const String rejectPrescription = '$baseUrl/medicine-delivery/prescriptions';
  static const String getOrdersByVendor = '$baseUrl/medicine-delivery/orders/vendor';
  static const String updateOrderPayment = '$baseUrl/medicine-delivery/orders';
  static const String updateOrderNote = '$baseUrl/medicine-delivery/orders';
  static const String updateOrderStatus = '$baseUrl/medicine-delivery/update-status'; // Update order status
  static const String getPendingPaymentOrders = '$baseUrl/medicine-delivery/orders/user'; // Get orders waiting for payment
  static const String placeMedicineOrder = '$baseUrl/medicine-delivery/place-medicine-order'; // Place medicine order after payment
  static const String getActiveMedicineDeliveryOrders = '$baseUrl/medicine-delivery/orders/active'; // Get active medicine delivery orders by user ID
  static const String getDeliveredMedicineOrders = '$baseUrl/medicine-delivery/orders/delivered'; // Get delivered medicine orders by user ID
  static const String downloadMedicineDeliveryInvoice = '$baseUrl/medicine-delivery/invoice'; // Download medicine delivery invoice
  static const String getMedicineCartCount = '$baseUrl/medicine-delivery/medicine-cart-count'; // Get medicine cart count by user ID

  // 📌 Notification APIs
  static const String getNotifications = '$baseUrl/notifications'; // GET /notifications?userId=:userId or ?vendorId=:vendorId
  static String markNotificationAsRead(String notificationId) => '$baseUrl/notifications/$notificationId/read'; // PUT /notifications/:notificationId/read
  static String deleteNotification(String notificationId) => '$baseUrl/notifications/$notificationId'; // DELETE /notifications/:notificationId

  // Build URL: Get user's current membership plan
  static String userCurrentMembership(String userId) => '$baseUrl/membership/user/$userId/current-plan';
}
