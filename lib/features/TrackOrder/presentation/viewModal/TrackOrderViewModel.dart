import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/TrackOrder/data/Services/TrackOrderService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:web_socket_channel/io.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';

class TrackOrderViewModel extends ChangeNotifier {
  final TrackOrderService _service = TrackOrderService(); // Service instance

  List<MedicineOrderModel> _orders = [];
  Map<String, List<CartModel>> _orderItems = {}; // ✅ Store cart items by orderId
  bool _isLoading = false;
  String? _error;
  IOWebSocketChannel? _channel; // WebSocket channel

  List<MedicineOrderModel> get orders => _orders;
  Map<String, List<CartModel>> get orderItems => _orderItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AmbulanceBooking> _ambulanceBookings = [];
  List<AmbulanceBooking> get ambulanceBookings => _ambulanceBookings;

  List<BloodBankBooking> _bloodBankBookings = [];
  List<BloodBankBooking> get bloodBankBookings => _bloodBankBookings;

  /// **✅ Fetch Orders and Cart Items**
  Future<void> fetchOrdersAndCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      _orders = await _service.fetchUserOrders(userId);
      _error = null;
      _orderItems.clear(); // Clear existing cart items

      for (var order in _orders) {
        List<CartModel> cartItems = await fetchCartItemsByOrderId(order.orderId);
        _orderItems[order.orderId] = cartItems; // ✅ Store cart items by order ID
      }
    } catch (e) {
      _error = 'No Order Found';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **✅ Fetch Cart Items by Order ID**
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      return await _service.fetchCartItemsByOrderId(orderId);
    } catch (e) {
      debugPrint("❌ Error fetching cart items: $e");
      return [];
    }
  }

  /// **Format Delivery Date**
  String formatDeliveryDate(DateTime? dateTime) {
    if (dateTime == null) return "Calculating...";
    try {
      return DateFormat("EEE, dd MMM yyyy • hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  /// ✅ Fetch active ambulance bookings for current user
  Future<void> fetchActiveAmbulanceBookings() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("📦 Starting to fetch active ambulance bookings...");

    try {
      String? userId = await StorageService.getUserId();
      debugPrint("👤 User ID: $userId");

      if (userId == null) {
        debugPrint("❌ User ID not found");
        throw Exception("User ID not found");
      }

      _ambulanceBookings = await _service.fetchActiveAmbulanceBookings(userId);
      debugPrint("✅ Ambulance bookings fetched: ${_ambulanceBookings.length}");

      for (var booking in _ambulanceBookings) {
        debugPrint("🚑 Booking ID: ${booking.requestId}, Status: ${booking.status}");
      }

      _error = null;
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching ambulance bookings: $e");
      debugPrint("🔍 Stack Trace:\n$stackTrace");

      _ambulanceBookings = [];
      _error = "No Ambulance Booking Found";
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("📦 Done fetching ambulance bookings.");
    }
  }

  /// ✅ Fetch blood bank bookings for current user
  Future<void> fetchBloodBankBookings() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("📦 Starting to fetch blood bank bookings...");

    try {
      String? userId = await StorageService.getUserId();
      String? token = await AuthRepository().getToken();

      if (userId == null || token == null) {
        throw Exception("User ID or token not found");
      }

      _bloodBankBookings = await _service.getBookings(userId, token);
      debugPrint("✅ Blood bank bookings fetched: ${_bloodBankBookings.length}");

      for (var booking in _bloodBankBookings) {
        debugPrint("🩸 Booking ID: ${booking.bookingId}, Status: ${booking.status}");
      }

      _error = null;
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching blood bank bookings: $e");
      debugPrint("🔍 Stack Trace:\n$stackTrace");

      _bloodBankBookings = [];
      _error = "No Blood Bank Bookings Found";
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("📦 Done fetching blood bank bookings.");
    }
  }

  /// **Dispose WebSocket when not needed**
  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}