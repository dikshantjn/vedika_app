import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreAnalyticsModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineReturnRequestModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/OrderService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicalStoreAnalyticsService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreInsightsModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreDashboardChartsModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/NewOrders/NewOrdersService.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MedicalStoreVendorDashboardViewModel extends ChangeNotifier {
  bool isServiceOnline = true;
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();
  final MedicalStoreVendorService _medicalStoreService = MedicalStoreVendorService();
  final NewOrdersService _newOrdersService = NewOrdersService();
  
  // Socket connection for real-time updates
  IO.Socket? _socket;
  bool _disposed = false;
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

  // ✅ Insights
  MedicalStoreInsightsModel? insights;

  // ✅ Charts
  MedicalStoreDashboardChartsModel? charts;

  final OrderService _orderService = OrderService();

  // ✅ Loading and Active Status
  bool _isLoading = false;
  bool _isActive = false; // Default inactive
  String _status = "Offline"; // New status field

  // ✅ Prescription Count
  int _prescriptionCount = 0;
  bool _isLoadingPrescriptions = false;

  // ✅ Time Filter for Analytics
  String _selectedTimeFilter = 'Today';
  List<String> _timeFilterOptions = ['Today', 'Week', 'Month', 'Year'];

  bool get isLoading => _isLoading;
  bool get isActive => _isActive;
  String get status => _status;
  String get selectedTimeFilter => _selectedTimeFilter;
  List<String> get timeFilterOptions => _timeFilterOptions;
  int get prescriptionCount => _prescriptionCount;
  bool get isLoadingPrescriptions => _isLoadingPrescriptions;

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
      
      // Also fetch prescription count when initializing
      await fetchPrescriptionCount();
      
      // Initialize socket connection for real-time updates
      await _initializeSocketConnection();
    } catch (e) {
      print("Error fetching vendor status: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Fetch Prescription Count
  Future<void> fetchPrescriptionCount() async {
    String? vendorId = await _loginService.getVendorId();
    
    if (vendorId == null) {
      print("Error: Vendor ID is null");
      return;
    }

    _isLoadingPrescriptions = true;
    notifyListeners();

    try {
      final prescriptions = await _newOrdersService.getPrescriptions(vendorId);
      _prescriptionCount = prescriptions.length;
      print("📊 [DashboardViewModel] Fetched ${_prescriptionCount} prescriptions");
    } catch (e) {
      print("Error fetching prescription count: $e");
      _prescriptionCount = 0;
    }

    _isLoadingPrescriptions = false;
    notifyListeners();
  }

  // ✅ Refresh Prescription Count (for real-time updates)
  Future<void> refreshPrescriptionCount() async {
    print('🔄 [DashboardViewModel] Manually refreshing prescription count...');
    await fetchPrescriptionCount();
  }

  // ✅ Force Refresh Prescription Count (for debugging)
  Future<void> forceRefreshPrescriptionCount() async {
    print('🔄 [DashboardViewModel] Force refreshing prescription count...');
    _prescriptionCount = 0; // Reset to 0 first
    notifyListeners();
    await fetchPrescriptionCount();
  }

  // ✅ Initialize Socket Connection for Real-time Updates
  Future<void> _initializeSocketConnection() async {
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        print("❌ [DashboardViewModel] Vendor ID not found for socket connection");
        return;
      }

      print("🚀 [DashboardViewModel] Initializing socket connection for prescription count updates...");

      // Close existing socket if any
      _socket?.disconnect();
      _socket?.dispose();

      _socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'query': {'vendorId': vendorId},
      });

      // Set up event listeners
      _socket!.onConnect((_) {
        print('✅ [DashboardViewModel] Socket connected for prescription count updates');
        _socket!.emit('registerVendor', vendorId);
      });

      _socket!.onConnectError((data) {
        print('❌ [DashboardViewModel] Socket connection error: $data');
        _attemptReconnect();
      });

      _socket!.onError((data) {
        print('❌ [DashboardViewModel] Socket error: $data');
      });

      _socket!.onDisconnect((_) {
        print('❌ [DashboardViewModel] Socket disconnected');
        _attemptReconnect();
      });

      // Handle updatePrescriptionCount event
      _socket!.on('updatePrescriptionCount', (data) async {
        print('🔄 [DashboardViewModel] updatePrescriptionCount event received: $data');
        print('🔄 [DashboardViewModel] Socket connected: ${_socket?.connected}');
        print('🔄 [DashboardViewModel] Disposed: $_disposed');
        await _handlePrescriptionCountUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      print('🔄 [DashboardViewModel] Attempting to connect socket for prescription count updates...');
    } catch (e) {
      print("❌ [DashboardViewModel] Socket connection error: $e");
      _attemptReconnect();
    }
  }

  // ✅ Handle Prescription Count Update from Socket
  Future<void> _handlePrescriptionCountUpdate(dynamic data) async {
    try {
      print('🔄 [DashboardViewModel] Processing prescription count update: $data');
      print('🔄 [DashboardViewModel] Current prescription count before update: $_prescriptionCount');
      
      // Refresh prescription count when updatePrescriptionCount event is received
      await refreshPrescriptionCount();
      
      print('✅ [DashboardViewModel] Prescription count refreshed after update event');
      print('✅ [DashboardViewModel] New prescription count: $_prescriptionCount');
    } catch (e) {
      print('❌ [DashboardViewModel] Error handling prescription count update: $e');
    }
  }

  // ✅ Attempt Socket Reconnection
  void _attemptReconnect() {
    Future.delayed(Duration(seconds: 3), () {
      if (_socket != null && !_socket!.connected && !_disposed) {
        print('🔄 [DashboardViewModel] Attempting to reconnect socket...');
        _socket!.connect();
      }
    });
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

  // ✅ Update Time Filter
  Future<void> updateTimeFilter(String timeFilter) async {
    _selectedTimeFilter = timeFilter;
    await fetchOrdersAndRequests();
  }

  // ✅ Fetch Orders and Return Requests from API with Time Filter
  Future<void> fetchOrdersAndRequests() async {
    try {
      String? vendorId = await _loginService.getVendorId();

      // Fetch store information
      await fetchStoreInformation();

      // Fetch orders with time filter
      orders = await MedicalStoreAnalyticsService.getOrders(_selectedTimeFilter);

      // Fetch return requests with time filter
      returnRequests = await MedicalStoreAnalyticsService.getReturnRequests(_selectedTimeFilter);

      // Update analytics with time filter
      analytics = await MedicalStoreAnalyticsService.getAnalytics(_selectedTimeFilter);

      // Fetch Insights with time filter
      insights = await MedicalStoreAnalyticsService.getInsights(_selectedTimeFilter);

      // Fetch Charts with time filter
      charts = await MedicalStoreAnalyticsService.getDashboardCharts(_selectedTimeFilter);

      notifyListeners();
    } catch (e) {
      print("Error fetching orders or return requests: $e");
    }
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

  // ✅ Dispose method to clean up socket connection
  @override
  void dispose() {
    _disposed = true;
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
