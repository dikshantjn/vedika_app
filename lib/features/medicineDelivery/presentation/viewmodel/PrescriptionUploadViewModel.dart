import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
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
  Timer? _statusCheckTimer; // Add timer variable

  PrescriptionUploadViewModel(BuildContext context)
      : _medicineOrderService = MedicineOrderService(context);

  File? _prescription;
  bool _isUploading = false;
  String _uploadStatus = '';
  String _isPrescriptionVerified = '';
  bool _isPlaceOrderEnabled = false;
  bool _isRequestAccepted = false; // Added for Request Accepted status
  bool _isPrescriptionVerifiedStatus = false; // Added for Prescription Verified status
  bool _isItemsAddedToCart = false; // Added for Items Added to Cart status
  List<MedicalStore> _nearbyStores = []; // Store fetched medical stores
  bool _isRequestBeingProcessed = false; // New property for request processing status
  bool _disposed = false;

  File? get prescription => _prescription;
  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;
  String get isPrescriptionVerified => _isPrescriptionVerified;
  bool get isPlaceOrderEnabled => _isPlaceOrderEnabled;
  bool get isRequestAccepted => _isRequestAccepted; // Getter for Request Accepted status
  bool get isPrescriptionVerifiedStatus => _isPrescriptionVerifiedStatus; // Getter for Prescription Verified status
  bool get isItemsAddedToCart => _isItemsAddedToCart; // Getter for Items Added to Cart status
  List<MedicalStore> get nearbyStores => _nearbyStores;

  bool get isRequestBeingProcessed => _isRequestBeingProcessed;

  @override
  void dispose() {
    _disposed = true;
    _statusCheckTimer?.cancel(); // Cancel timer when disposing
    super.dispose();
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // File picker for prescription upload
  Future<void> pickPrescription(BuildContext context) async {
    if (_disposed) return;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      _prescription = File(result.files.single.path!);
      _safeNotifyListeners();

      print('pickPrescription: Prescription file selected, path: ${_prescription?.path}');

      // Upload and fetch nearby stores after selecting prescription
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

    LoadingDialog.show(context, "Uploading prescription...");

    print('uploadPrescription: $_uploadStatus');

    FirebasePrescriptionUploadService uploadService = FirebasePrescriptionUploadService();
    String? prescriptionUrl = await uploadService.uploadPrescription(_prescription!);

    if (prescriptionUrl == null) {
      _uploadStatus = 'Failed to upload prescription';
      _isUploading = false;
      _safeNotifyListeners();
      LoadingDialog.hide(context);
      return;
    }

    _uploadStatus = 'Fetching user location...';
    _safeNotifyListeners();

    LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.fetchLocation();

    double? latitude = locationProvider.latitude;
    double? longitude = locationProvider.longitude;

    if (latitude == null || longitude == null) {
      _uploadStatus = 'Failed to get user location';
      _isUploading = false;
      _safeNotifyListeners();
      LoadingDialog.hide(context);
      return;
    }

    _uploadStatus = 'Sending prescription to nearby medical stores...';
    _safeNotifyListeners();

    var response = await _prescriptionService.uploadPrescription(
      prescriptionUrl: prescriptionUrl,
      userId: userId!,
      latitude: latitude,
      longitude: longitude,
    );

    if (response['success']) {
      _uploadStatus = 'Prescription uploaded successfully!';
      _isRequestBeingProcessed = true;
      _safeNotifyListeners();

      // Show BeforeVerificationWidget
      LoadingDialog.update(
        context,
        BeforeVerificationWidget(
          initialTime: 300, // 5-minute countdown
          onTimeExpired: () {
            if (_disposed) return;
            // When time runs out, show FindMoreMedicalShopsWidget
            LoadingDialog.update(
              context,
              FindMoreMedicalShopsWidget(
                onFindMore: () {
                  print("Finding more shops");
                  Navigator.pop(context); // Close dialog
                },
                onCancel: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            );
          },
        ),
      );

      // Cancel any existing timer
      _statusCheckTimer?.cancel();
      
      // Start polling for prescription acceptance
      _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (_disposed) {
          timer.cancel();
          return;
        }
        bool isAccepted = await checkPrescriptionStatus(context);
        print("isAccepted $isAccepted");
        if (isAccepted) {
          timer.cancel();
          _statusCheckTimer = null;
        }
      });

    } else {
      _uploadStatus = 'Failed to upload prescription: ${response['message']}';
      LoadingDialog.hide(context);
    }

    _isUploading = false;
    _safeNotifyListeners();
  }


  Future<bool> enableLocation(BuildContext context) async {
    if (_disposed) return false;
    
    print('enableLocation: Started');
    Location location = Location();

    // Check if location services are enabled
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

    // Check location permissions
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

  /// Checks if the prescription has been accepted
  Future<bool> checkPrescriptionStatus(BuildContext context) async {
    if (_disposed) return false;
    
    String? userId = await StorageService.getUserId();
    if (userId == null) return false;

    String? acceptedByVendorId = await _prescriptionService.checkPrescriptionAcceptance(userId);
    print("Accepted by Vendor ID: $acceptedByVendorId");

    if (acceptedByVendorId != null) {
      // 🔹 Fetch Vendor Details
      VendorMedicalStoreProfile? vendor =
          await MedicalStoreVendorService().fetchVendorById(acceptedByVendorId);

      if (vendor != null) {
        String vendorName = vendor.name; // Extract vendor name
        print("Vendor Name: $vendorName");

        if (!_disposed) {
          _isRequestAccepted = true;
          _isPrescriptionVerified = vendorName;
          _safeNotifyListeners();

          // **Show AfterVerificationWidget**
          LoadingDialog.update(
            context,
            AfterVerificationWidget(
              medicalStoreName: vendorName,
              onTrackOrder: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamed(context, AppRoutes.trackOrderScreen); // Navigate to tracking screen
              },
            ),
          );
        }

        return true; // Stop polling
      } else {
        print("Failed to fetch vendor details.");
      }
    }

    return false; // Continue polling
  }

}
