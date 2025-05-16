import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/FirebasePrescriptionUploadService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/PrescriptionService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/AfterVerificationWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/BeforeVerificationWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/FindMoreMedicalShopsWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/PrescriptionUploadLoadingDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class PrescriptionUploadViewModel extends ChangeNotifier {
  final MedicineOrderService _medicineOrderService;
  final PrescriptionService _prescriptionService = PrescriptionService();
  Timer? _statusCheckTimer;
  IO.Socket? _socket;
  bool _disposed = false;
  BuildContext? _context;

  PrescriptionUploadViewModel(BuildContext context)
      : _medicineOrderService = MedicineOrderService(context) {
    _context = context;
    debugPrint("🏗️ PrescriptionUploadViewModel initialized");
    // Initialize socket connection immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSocketConnection();
    });
  }

  File? _prescription;
  bool _isUploading = false;
  String _uploadStatus = '';
  String _isPrescriptionVerified = '';
  bool _isPlaceOrderEnabled = false;
  bool _isRequestAccepted = false;
  bool _isPrescriptionVerifiedStatus = false;
  bool _isItemsAddedToCart = false;
  List<MedicalStore> _nearbyStores = [];
  bool _isRequestBeingProcessed = false;

  File? get prescription => _prescription;
  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;
  String get isPrescriptionVerified => _isPrescriptionVerified;
  bool get isPlaceOrderEnabled => _isPlaceOrderEnabled;
  bool get isRequestAccepted => _isRequestAccepted;
  bool get isPrescriptionVerifiedStatus => _isPrescriptionVerifiedStatus;
  bool get isItemsAddedToCart => _isItemsAddedToCart;
  List<MedicalStore> get nearbyStores => _nearbyStores;

  bool get isRequestBeingProcessed => _isRequestBeingProcessed;

  void initSocketConnection() async {
    debugPrint("🚀 Starting socket initialization...");
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        debugPrint("❌ User ID not found for socket registration");
        return;
      }

      debugPrint("👤 User ID for socket: $userId");

      // Close existing socket if any
      if (_socket != null) {
        debugPrint("🔄 Closing existing socket connection");
        _socket!.disconnect();
        _socket!.dispose();
      }

      debugPrint("🔌 Creating new socket connection...");
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
        'query': {'userId': userId},
      });

      debugPrint("🎯 Setting up socket event listeners...");

      // Set up event listeners
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected for prescription verification');
        debugPrint('📡 Emitting register event with userId: $userId');
        _socket!.emit('register', userId);
      });

      _socket!.onConnectError((data) {
        debugPrint('❌ Socket connection error: $data');
        _attemptReconnect();
      });

      _socket!.onError((data) {
        debugPrint('❌ Socket error: $data');
      });

      _socket!.onDisconnect((_) {
        debugPrint('❌ Socket disconnected');
        _attemptReconnect();
      });

      // Add event listener for prescription verification
      _socket!.on('orderStatusUpdated', (data) {
        debugPrint('🔄 Received orderStatusUpdated event: $data');
        _handlePrescriptionStatusUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        debugPrint('📡 Received ping');
        _socket!.emit('pong');
        debugPrint('📡 Sent pong');
      });

      // Connect to the socket
      debugPrint("🔌 Attempting to connect socket...");
      _socket!.connect();
      debugPrint("✅ Socket initialization completed");
    } catch (e, stackTrace) {
      debugPrint("❌ Socket connection error: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    debugPrint("🔄 Scheduling reconnection attempt...");
    Future.delayed(Duration(seconds: 2), () {
      if (_socket != null && !_socket!.connected && !_disposed) {
        debugPrint('🔄 Attempting to reconnect...');
        _socket!.connect();
      } else {
        debugPrint('❌ Cannot reconnect: socket=${_socket != null}, connected=${_socket?.connected}, disposed=$_disposed');
      }
    });
  }

  Future<void> _handlePrescriptionStatusUpdate(dynamic data) async {
    try {
      debugPrint('📝 Processing prescription status update: $data');
      
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;
      debugPrint('📝 Parsed data: $orderData');
      
      final orderId = orderData['orderId'];
      final status = orderData['status'];
      
      if (orderId != null && status != null) {
        debugPrint('📝 Processing status: $status for order: $orderId');
        
        // Update status flags
        _isPrescriptionVerifiedStatus = status == 'PrescriptionVerified';
        _isRequestAccepted = true;
        
        // If status is PrescriptionVerified, show AfterVerificationWidget immediately
        if (status == 'PrescriptionVerified' && !_disposed && _context != null && _context!.mounted) {
          debugPrint('📝 Prescription verified, showing AfterVerificationWidget');
          
          // Fetch vendor details if available
          String? vendorId = orderData['vendorId'];
          if (vendorId != null) {
            debugPrint('📝 Fetching vendor details for ID: $vendorId');
            VendorMedicalStoreProfile? vendor = await MedicalStoreVendorService().fetchVendorById(vendorId);
            if (vendor != null) {
              _isPrescriptionVerified = vendor.name;
              debugPrint('📝 Found vendor name: ${vendor.name}');
            }
          }

          // Show AfterVerificationWidget immediately
          debugPrint('📝 Showing AfterVerificationWidget');
          LoadingDialog.update(
            _context!,
            AfterVerificationWidget(
              medicalStoreName: _isPrescriptionVerified,
              onTrackOrder: () {
                Navigator.pop(_context!);
                Navigator.pushNamed(_context!, AppRoutes.trackOrderScreen);
              },
            ),
          );
        }
        
        _safeNotifyListeners();
      } else {
        debugPrint('❌ Missing orderId or status in data: $orderData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling prescription status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint("🗑️ Disposing PrescriptionUploadViewModel");
    _disposed = true;
    _statusCheckTimer?.cancel();
    if (_socket != null) {
      debugPrint("🔌 Disconnecting socket");
      _socket!.disconnect();
      _socket!.dispose();
    }
    _context = null;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> pickPrescription(BuildContext context) async {
    if (_disposed) return;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      _prescription = File(result.files.single.path!);
      _safeNotifyListeners();

      print('pickPrescription: Prescription file selected, path: ${_prescription?.path}');

      await uploadPrescription(context);
    }
  }

  Future<void> uploadPrescription(BuildContext context) async {
    if (_disposed) return;
    
    String? userId = await StorageService.getUserId();
    if (_prescription == null) return;

    _isUploading = true;
    _uploadStatus = 'Uploading prescription...';
    _safeNotifyListeners();

    debugPrint("📤 Starting prescription upload...");
    LoadingDialog.show(context, "Uploading prescription...");

    FirebasePrescriptionUploadService uploadService = FirebasePrescriptionUploadService();
    String? prescriptionUrl = await uploadService.uploadPrescription(_prescription!);

    if (prescriptionUrl == null) {
      debugPrint("❌ Failed to upload prescription");
      _uploadStatus = 'Failed to upload prescription';
      _isUploading = false;
      _safeNotifyListeners();
      LoadingDialog.hide(context);
      return;
    }

    debugPrint("✅ Prescription uploaded successfully. URL: $prescriptionUrl");
    _uploadStatus = 'Fetching user location...';
    _safeNotifyListeners();

    LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.fetchLocation();

    double? latitude = locationProvider.latitude;
    double? longitude = locationProvider.longitude;

    if (latitude == null || longitude == null) {
      debugPrint("❌ Failed to get user location");
      _uploadStatus = 'Failed to get user location';
      _isUploading = false;
      _safeNotifyListeners();
      LoadingDialog.hide(context);
      return;
    }

    debugPrint("📍 Location fetched: $latitude, $longitude");
    _uploadStatus = 'Sending prescription to nearby medical stores...';
    _safeNotifyListeners();

    // Show BeforeVerificationWidget immediately after location is fetched
    if (!_disposed && context.mounted) {
      debugPrint("🔄 Showing BeforeVerificationWidget immediately");
      LoadingDialog.update(
        context,
        BeforeVerificationWidget(
          initialTime: 300, // 5-minute countdown
          onTimeExpired: () {
            if (_disposed) return;
            debugPrint("⏰ Time expired, showing FindMoreMedicalShopsWidget");
            if (context.mounted) {
              LoadingDialog.update(
                context,
                FindMoreMedicalShopsWidget(
                  onFindMore: () {
                    debugPrint("🔍 Finding more shops");
                    Navigator.pop(context);
                  },
                  onCancel: () {
                    debugPrint("❌ Cancelled finding more shops");
                    Navigator.pop(context);
                  },
                ),
              );
            }
          },
        ),
      );
    }

    var response = await _prescriptionService.uploadPrescription(
      prescriptionUrl: prescriptionUrl,
      userId: userId!,
      latitude: latitude,
      longitude: longitude,
    );

    if (response['success']) {
      debugPrint("✅ Prescription sent to medical stores successfully");
      _uploadStatus = 'Prescription uploaded successfully!';
      _isRequestBeingProcessed = true;
      _safeNotifyListeners();
    } else {
      debugPrint("❌ Failed to send prescription to medical stores: ${response['message']}");
      _uploadStatus = 'Failed to upload prescription: ${response['message']}';
      if (context.mounted) {
        LoadingDialog.hide(context);
      }
    }

    _isUploading = false;
    _safeNotifyListeners();
  }

  Future<bool> enableLocation(BuildContext context) async {
    if (_disposed) return false;
    
    print('enableLocation: Started');
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      print('enableLocation: Requesting location service...');
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('enableLocation: Location service not enabled');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location services are required to proceed.")),
        );
        return false;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      print('enableLocation: Requesting location permission...');
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('enableLocation: Location permission not granted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required.")),
        );
        return false;
      }
    }

    print('enableLocation: Location access granted');
    return true;
  }

  Future<bool> checkPrescriptionStatus(BuildContext context) async {
    if (_disposed) return false;
    
    String? userId = await StorageService.getUserId();
    if (userId == null) return false;

    String? acceptedByVendorId = await _prescriptionService.checkPrescriptionAcceptance(userId);
    print("Accepted by Vendor ID: $acceptedByVendorId");

    if (acceptedByVendorId != null) {
      VendorMedicalStoreProfile? vendor =
          await MedicalStoreVendorService().fetchVendorById(acceptedByVendorId);

      if (vendor != null) {
        String vendorName = vendor.name;
        print("Vendor Name: $vendorName");

        if (!_disposed) {
          _isRequestAccepted = true;
          _isPrescriptionVerified = vendorName;
          _safeNotifyListeners();

          LoadingDialog.update(
            context,
            AfterVerificationWidget(
              medicalStoreName: vendorName,
              onTrackOrder: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.trackOrderScreen);
              },
            ),
          );
        }

        return true;
      } else {
        print("Failed to fetch vendor details.");
      }
    }

    return false;
  }
}
