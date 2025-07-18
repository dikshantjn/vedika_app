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
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/PrescriptionFlowBottomSheet.dart';

class PrescriptionUploadViewModel extends ChangeNotifier {
  final MedicineOrderService _medicineOrderService;
  final PrescriptionService _prescriptionService = PrescriptionService();
  Timer? _statusCheckTimer;
  IO.Socket? _socket;
  bool _disposed = false;
  BuildContext? _context;
  String? _currentPrescriptionId;
  double _currentSearchRadius = 0.5; // Default radius in kilometers
  PrescriptionFlowController? _flowController;
  Map<String, dynamic>? _lastVerificationResponse;
  ScaffoldMessengerState? _scaffoldMessenger;

  PrescriptionUploadViewModel(BuildContext context)
      : _medicineOrderService = MedicineOrderService(context) {
    _context = context;
    _scaffoldMessenger = ScaffoldMessenger.of(context);
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

  void updateScaffoldMessenger(BuildContext context) {
    if (context.mounted) {
      _scaffoldMessenger = ScaffoldMessenger.of(context);
    }
  }

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

      // Step 1: Extract text from prescription using google_mlkit_text_recognition
      _isUploading = true;
      _uploadStatus = 'Extracting text from prescription...';
      _safeNotifyListeners();
      _flowController = PrescriptionFlowController(
        PrescriptionFlowState.loading,
        message: 'Extracting text from prescription...'
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PrescriptionFlowBottomSheet(controller: _flowController!),
      );
      try {
        final inputImage = InputImage.fromFile(_prescription!);
        final textRecognizer = TextRecognizer();
        RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        await textRecognizer.close();
        String extractedText = recognizedText.text;
        _flowController?.update(
          state: PrescriptionFlowState.verifying,
          message: 'Verifying prescription...',
          countdown: 300,
        );
        final verificationResponse = await _prescriptionService.verifyPrescriptionTextAI(extractedText);
        print("Prescription Verification Response : $verificationResponse");
        if (verificationResponse['verified'] == true) {
          _lastVerificationResponse = verificationResponse;
          _uploadStatus = 'Prescription is verified!';
          _safeNotifyListeners();
          // Step 3: Call uploadPrescription (DB call) and show searching bottom sheet
          await uploadPrescription(context, showSearchingDialog: true);
        } else {
          String reason = verificationResponse['reason'] ?? verificationResponse['message'] ?? 'Prescription verification failed.';
          _uploadStatus = 'Prescription verification failed: $reason';
          _isUploading = false;
          _safeNotifyListeners();
          _flowController?.update(
            state: PrescriptionFlowState.notVerified,
            message: 'Prescription not verified',
            lottieAsset: 'assets/animations/paymentfailed.json',
            onClose: () {
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            countdown: 300,
          );
          _scaffoldMessenger?.showSnackBar(
            SnackBar(content: Text(_uploadStatus)),
          );
        }
      } catch (e, st) {
        print('Error in pickPrescription: $e');
        print(st);
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _scaffoldMessenger?.showSnackBar(
          SnackBar(content: Text('Failed to extract or verify prescription.')),
        );
        _isUploading = false;
        _safeNotifyListeners();
        return;
      }
    }
  }

  Future<void> uploadPrescription(BuildContext context, {bool showSearchingDialog = true}) async {
    if (_disposed) return;

    String? userId = await StorageService.getUserId();
    if (_prescription == null) return;

    _isUploading = true;
    _uploadStatus = 'Prescription is Verified and Uploading prescription...';
    _safeNotifyListeners();

    if (showSearchingDialog && _flowController != null) {
      _flowController!.update(
        state: PrescriptionFlowState.loading,
        message: 'Prescription is Verified and Uploading prescription...'
      );
    }

    FirebasePrescriptionUploadService uploadService = FirebasePrescriptionUploadService();
    String? prescriptionUrl = await uploadService.uploadPrescription(_prescription!);

    if (prescriptionUrl == null) {
      debugPrint("❌ Failed to upload prescription to Firebase, proceeding to call backend API anyway.");
      _uploadStatus = 'Failed to upload prescription image, sending request to backend...';
      _safeNotifyListeners();
      // Do NOT return here; proceed to call backend API with prescriptionUrl as null or empty string
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
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    debugPrint("📍 Location fetched: $latitude, $longitude");
    _uploadStatus = 'Sending prescription to nearby medical stores...';
    _safeNotifyListeners();

    if (!_disposed && context.mounted && showSearchingDialog && _flowController != null) {
      _flowController!.update(
        state: PrescriptionFlowState.searching,
        message: 'Your prescription is verified!\nSearching Nearest Medical Shops...',
        countdown: 300,
        lottieAsset: 'assets/animations/scanPrescription.json',
        onCancel: () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        onFindMore: () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          searchMoreVendors(context);
        },
        onClose: () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      );
    }

    var response = await _prescriptionService.uploadPrescription(
      prescriptionUrl: prescriptionUrl ?? '',
      userId: userId!,
      latitude: latitude,
      longitude: longitude,
      jsonPrescription: _lastVerificationResponse ?? {},
    );

    if (response['success']) {
      debugPrint("✅ Prescription sent to medical stores successfully");
      _uploadStatus = 'Prescription uploaded successfully!';
      _isRequestBeingProcessed = true;
      // Store the prescription ID from the response
      if (response['data'] != null && response['data']['prescription'] != null) {
        _currentPrescriptionId = response['data']['prescription']['prescriptionId'];
      }
      _safeNotifyListeners();
    } else {
      debugPrint("❌ Failed to send prescription to medical stores: ${response['message']}");
      _uploadStatus = 'Failed to upload prescription: ${response['message']}';
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close bottom sheet
      }
    }

    _isUploading = false;
    _safeNotifyListeners();
  }

  Future<void> searchMoreVendors(BuildContext context) async {
    if (_disposed || _currentPrescriptionId == null) return;

    _isUploading = true;
    _uploadStatus = 'Searching for more medical stores...';
    _safeNotifyListeners();
    if (_flowController != null) {
      _flowController!.update(
        state: PrescriptionFlowState.searching,
        message: 'Searching Nearest Medical Shops...',
        countdown: 300,
        lottieAsset: 'assets/animations/scanPrescription.json',
        onFindMore: () async {
          // When user clicks 'Search More', restart countdown and call API
          _flowController!.update(
            state: PrescriptionFlowState.searching,
            message: 'Searching Nearest Medical Shops...',
            countdown: 300,
            lottieAsset: 'assets/animations/scanPrescription.json',
            onFindMore: _flowController!.onFindMore, // keep the same callback
          );
          await Future.delayed(const Duration(milliseconds: 500)); // allow UI to update
          searchMoreVendors(context);
        },
        onCancel: () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        noMoreVendors: false,
      );
    }

    LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.fetchLocation();

    double? latitude = locationProvider.latitude;
    double? longitude = locationProvider.longitude;

    if (latitude == null || longitude == null) {
      debugPrint("❌ Failed to get user location");
      _uploadStatus = 'Failed to get user location';
      _isUploading = false;
      _safeNotifyListeners();
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    // Increase the search radius by 0.5 km
    _currentSearchRadius += 0.5;

    var response = await _prescriptionService.searchMoreVendors(
      prescriptionId: _currentPrescriptionId!,
      latitude: latitude,
      longitude: longitude,
      searchRadius: _currentSearchRadius,
    );

    if (response['success']) {
      debugPrint("✅ Search for more vendors completed");
      _uploadStatus = response['message'];

      if (response['moreVendorsAvailable'] == false && _flowController != null) {
        // No more vendors available, show FindMoreMedicalShopsWidget with noMoreVendors state
        _flowController!.update(
          state: PrescriptionFlowState.findMore,
          onFindMore: () {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            searchMoreVendors(context);
          },
          onCancel: () {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          noMoreVendors: true,
        );
      }
      // If more vendors are available, do nothing (countdown will show again)
    } else {
      debugPrint("❌ Failed to search for more vendors: ${response['message']}");
      _uploadStatus = 'Failed to search for more vendors: ${response['message']}';
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        _scaffoldMessenger?.showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
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
        _scaffoldMessenger?.showSnackBar(
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
        _scaffoldMessenger?.showSnackBar(
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