import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../../data/model/BloodBankRequest.dart';
import '../../data/services/BloodBankRequestService.dart';
import '../../../../../core/auth/data/models/UserModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'dart:convert';

class BloodBankRequestViewModel extends ChangeNotifier {
  final BloodBankRequestService _service = BloodBankRequestService();
  final VendorLoginService _loginService = VendorLoginService(); // Vendor Login Service
  IO.Socket? _socket;

  List<BloodBankRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BloodBankRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<BloodBankRequest> get pendingRequests => 
      _requests.where((request) => request.status == 'pending').toList();
  
  List<BloodBankRequest> get expiredRequests =>
      _requests.where((request) => request.status == 'expired').toList();
  
  List<BloodBankRequest> get acceptedRequests =>
      _requests.where((request) => request.status == 'accepted').toList();

  BloodBankRequestViewModel() {
    _initSocketConnection();
  }

  void _initSocketConnection() async {
    String? vendorId = await _loginService.getVendorId();
    if (vendorId == null) return;

    _socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000,
      'forceNew': true,
      'upgrade': true,
      'rememberUpgrade': true,
      'path': '/socket.io/',
      'query': {'vendorId': vendorId},
    });

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected for BloodBankRequestViewModel');
      _socket!.emit('registerVendor', vendorId);
    });

    _socket!.onConnectError((data) {
      debugPrint('❌ Socket connection error: $data');
    });

    _socket!.onError((data) {
      debugPrint('❌ Socket error: $data');
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
    });

    // Listen for vendor blood bank updates
    _socket!.on('vendorBloodBankUpdate', (data) {
      debugPrint('🩸 Received vendor blood bank update: $data');
      _handleVendorBloodBankUpdate(data);
    });

    _socket!.connect();
  }

  void _handleVendorBloodBankUpdate(dynamic data) async {
    debugPrint('🩸 Processing vendor blood bank update: $data');
    try {
      // Parse the data if it's a string
      Map<String, dynamic> requestData = data is String ? json.decode(data) : data;
      debugPrint('🩸 Parsed data: $requestData');

      // Check if this is a new request
      if (requestData['data'] != null && requestData['data'] is List) {
        // This is a new request, refresh the list
        await loadRequests();
        return;
      }

      final requestId = requestData['requestId'];
      final status = requestData['status'];

      if (requestId != null && status != null) {
        // Check if request already exists
        final existingIndex = _requests.indexWhere((r) => r.requestId == requestId);
        
        if (existingIndex == -1) {
          // If it's a new request, refresh the list
          await loadRequests();
        } else {
          // If it's an existing request, update it
          _requests[existingIndex] = _requests[existingIndex].copyWith(
            status: status,
          );
          notifyListeners();
        }
      } else {
        // If we can't parse the data properly, do a full refresh
        await loadRequests();
      }
    } catch (e) {
      debugPrint('❌ Error handling blood bank update: $e');
      // If there's an error, refresh the list to ensure we have the latest data
      await loadRequests();
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> loadRequests() async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _requests = await _service.getRequests(vendorId!, token!);
    } catch (e) {
      _error = 'Failed to load requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId) async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.acceptRequest(requestId, vendorId!, token!);
      await loadRequests(); // Reload the requests to get updated data
    } catch (e) {
      _error = 'Failed to accept request';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processRequest(String requestId) async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateRequestStatus(requestId, 'processed', token!);
      await loadRequests(); // Reload the requests to get updated data
    } catch (e) {
      _error = 'Failed to process request';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getPrescriptionUrls(String requestId) async {
    try {
      final request = _requests.firstWhere((r) => r.requestId == requestId);
      return request.prescriptionUrls;
    } catch (e) {
      _error = 'Failed to load prescription URLs';
      notifyListeners();
      return [];
    }
  }

  // Get user details for a request
  UserModel? getUserDetails(String requestId) {
    try {
      final request = _requests.firstWhere((r) => r.requestId == requestId);
      return request.user;
    } catch (e) {
      return null;
    }
  }
} 