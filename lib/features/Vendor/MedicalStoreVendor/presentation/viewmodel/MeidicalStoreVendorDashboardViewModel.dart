import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreAnalyticsModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineReturnRequestModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/OrderService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MedicalStoreVendorDashboardViewModel extends ChangeNotifier {
  bool isServiceOnline = true;
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();
  final MedicalStoreVendorService _medicalStoreService = MedicalStoreVendorService();

  // Store Information
  String? _storeName;
  String? _storeAddress;
  String? _storePhone;
  String? _storeEmail;
  VendorMedicalStoreProfile? _storeProfile;

  // Getters for store information
  String? get storeName => _storeProfile?.name ?? _storeName;
  String? get storeAddress => _storeProfile?.address ?? _storeAddress;
  String? get storePhone => _storeProfile?.contactNumber ?? _storePhone;
  String? get storeEmail => _storeProfile?.emailId ?? _storeEmail;

  // ✅ List to hold fetched orders and return requests
  List<MedicineOrderModel> orders = [];
  List<MedicineReturnRequestModel> returnRequests = [];

  // ✅ Store Analytics Data
  MedicalStoreAnalyticsModel analytics = MedicalStoreAnalyticsModel(
    totalOrders: 0,
    averageOrderValue: 0,
    ordersToday: 0,
    returnsThisWeek: 0,
  );

  final OrderService _orderService = OrderService();

  // ✅ Loading and Active Status
  bool _isLoading = false;
  bool _isActive = false; // Default inactive
  String _status = "Offline"; // New status field

  bool get isLoading => _isLoading;
  bool get isActive => _isActive;
  String get status => _status;

  // ✅ Fetch Store Information
  Future<void> fetchStoreInformation() async {
    try {
      String? token = await _loginService.getVendorToken();
      if (token != null) {
        _storeProfile = await _medicalStoreService.fetchVendorProfile(token);
        if (_storeProfile != null) {
          _storeName = _storeProfile!.name;
          _storeAddress = _storeProfile!.address;
          _storePhone = _storeProfile!.contactNumber;
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching store information: $e");
    }
  }

  // ✅ Fetch Vendor's Initial Active Status
  Future<void> fetchVendorStatus() async {
    String? vendorId = await _loginService.getVendorId();

    _isLoading = true;
    notifyListeners();

    try {
      bool currentStatus = await _vendorService.getVendorStatus(vendorId!); // API call to get status
      _isActive = currentStatus;
    } catch (e) {
      print("Error fetching vendor status: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Toggle Vendor Status (Activate/Deactivate)
  Future<void> toggleVendorStatus() async {
    String? vendorId = await _loginService.getVendorId();

    _isLoading = true;
    notifyListeners();

    try {
      bool newStatus = await _vendorService.toggleVendorStatus(vendorId!);
      _isActive = newStatus; // Update status based on API response
    } catch (e) {
      print("Error in toggleVendorStatus: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Function to Toggle Online/Offline Status
  void toggleServiceStatus() {
    isServiceOnline = !isServiceOnline;
    notifyListeners();
  }

  // ✅ Fetch Orders and Return Requests from API
  Future<void> fetchOrdersAndRequests() async {
    try {
      String? vendorId = await _loginService.getVendorId();

      // Fetch store information
      await fetchStoreInformation();

      // Fetch orders
      orders = await _orderService.getOrders(vendorId!);

      // Fetch return requests
      returnRequests = await _fetchReturnRequests();

      // Update analytics
      _updateAnalytics();

      notifyListeners();
    } catch (e) {
      print("Error fetching orders or return requests: $e");
    }
  }

  // ✅ Fetching Return Requests (Placeholder, implement this service method)
  Future<List<MedicineReturnRequestModel>> _fetchReturnRequests() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      MedicineReturnRequestModel(orderId: '006', customerName: 'Mark Lee', status: 'Pending', createdAt: DateTime.now().subtract(Duration(days: 1))),
      MedicineReturnRequestModel(orderId: '007', customerName: 'Sophia Martinez', status: 'Approved', createdAt: DateTime.now().subtract(Duration(days: 2))),
      MedicineReturnRequestModel(orderId: '008', customerName: 'Olivia Taylor', status: 'Rejected', createdAt: DateTime.now().subtract(Duration(days: 3))),
      MedicineReturnRequestModel(orderId: '009', customerName: 'Daniel Harris', status: 'Processing', createdAt: DateTime.now().subtract(Duration(days: 4))),
      MedicineReturnRequestModel(orderId: '010', customerName: 'James Anderson', status: 'Completed', createdAt: DateTime.now().subtract(Duration(days: 5))),
    ];
  }

  // ✅ Update Analytics based on fetched data
  void _updateAnalytics() {
    int totalOrders = orders.length;
    double averageOrderValue = _calculateAverageOrderValue();
    int ordersToday = _countOrdersToday();
    int returnsThisWeek = returnRequests.where((request) => _isRequestThisWeek(request)).length;

    analytics = MedicalStoreAnalyticsModel(
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue.toInt(),
      ordersToday: ordersToday,
      returnsThisWeek: returnsThisWeek,
    );
  }

  // ✅ Calculate Average Order Value
  double _calculateAverageOrderValue() {
    double totalValue = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    return orders.isNotEmpty ? totalValue / orders.length : 0.0;
  }

  // ✅ Count orders for today
  int _countOrdersToday() {
    DateTime todayStart = DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
    return orders.where((order) => order.createdAt.isAfter(todayStart)).length;
  }

  // ✅ Check if the return request is within this week
  bool _isRequestThisWeek(MedicineReturnRequestModel request) {
    DateTime requestDate = request.createdAt;
    DateTime now = DateTime.now();
    int weekOfYear = _getWeekOfYear(now);
    int requestWeekOfYear = _getWeekOfYear(requestDate);
    return weekOfYear == requestWeekOfYear;
  }

  // ✅ Get Week of the year
  int _getWeekOfYear(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - 1) / 7).floor() + 1;
  }

  // ✅ Set Vendor Status
  Future<void> setStatus(bool isOnline) async {
    String? vendorId = await _loginService.getVendorId();

    _isLoading = true;
    notifyListeners();

    try {
      if (isOnline) {
        _status = "Online";
        _isActive = true;
      } else {
        _status = "Offline";
        _isActive = false;
      }
      
      // Update status in the backend
      await _vendorService.toggleVendorStatus(vendorId!);
      
      // Show toast message
      Fluttertoast.showToast(
        msg: "You are now $_status",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: _status == "Online" 
            ? MedicalStoreVendorColorPalette.successColor
            : MedicalStoreVendorColorPalette.errorColor,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      print("Error setting vendor status: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Set Busy Status
  Future<void> setBusyStatus() async {
    String? vendorId = await _loginService.getVendorId();

    _isLoading = true;
    notifyListeners();

    try {
      _status = "Busy";
      _isActive = false;
      
      // Update status in the backend
      await _vendorService.toggleVendorStatus(vendorId!);
      
      // Show toast message
      Fluttertoast.showToast(
        msg: "You are now Busy",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: MedicalStoreVendorColorPalette.warningColor,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      print("Error setting busy status: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
