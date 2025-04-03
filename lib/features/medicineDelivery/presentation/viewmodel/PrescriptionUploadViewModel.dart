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

class MedicineOrderViewModel extends ChangeNotifier {
  final MedicineOrderService _medicineOrderService;
  final PrescriptionService _prescriptionService = PrescriptionService();

  MedicineOrderViewModel(BuildContext context)
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

  // File picker for prescription upload
  Future<void> pickPrescription(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      _prescription = File(result.files.single.path!);
      notifyListeners();

      print('pickPrescription: Prescription file selected, path: ${_prescription?.path}');

      // Upload and fetch nearby stores after selecting prescription
      await uploadPrescription(context);
    }
  }

  Future<void> uploadPrescription(BuildContext context) async {
    String? userId = await StorageService.getUserId();
    if (_prescription == null) return;

    _isUploading = true;
    _uploadStatus = 'Uploading prescription...';
    notifyListeners();

    LoadingDialog.show(context, "Uploading prescription...");

    print('uploadPrescription: $_uploadStatus');

    FirebasePrescriptionUploadService uploadService = FirebasePrescriptionUploadService();
    String? prescriptionUrl = await uploadService.uploadPrescription(_prescription!);

    if (prescriptionUrl == null) {
      _uploadStatus = 'Failed to upload prescription';
      _isUploading = false;
      notifyListeners();
      LoadingDialog.hide(context);
      return;
    }

    _uploadStatus = 'Fetching user location...';
    notifyListeners();

    LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.fetchLocation();

    double? latitude = locationProvider.latitude;
    double? longitude = locationProvider.longitude;

    if (latitude == null || longitude == null) {
      _uploadStatus = 'Failed to get user location';
      _isUploading = false;
      notifyListeners();
      LoadingDialog.hide(context);
      return;
    }

    _uploadStatus = 'Sending prescription to nearby medical stores...';
    notifyListeners();

    var response = await _prescriptionService.uploadPrescription(
      prescriptionUrl: prescriptionUrl,
      userId: userId!,
      latitude: latitude,
      longitude: longitude,
    );

    if (response['success']) {
      _uploadStatus = 'Prescription uploaded successfully!';
      _isRequestBeingProcessed = true;
      notifyListeners();

      // Show BeforeVerificationWidget
      LoadingDialog.update(
        context,
        BeforeVerificationWidget(
          initialTime: 300, // 5-minute countdown
          onTimeExpired: () {
            // When time runs out, show FindMoreMedicalShopsWidget
            LoadingDialog.update(
              context,
              FindMoreMedicalShopsWidget(
                onFindMore: () {
                  print("Finding more shops");
                  Navigator.pop(context); // Close dialog
                  // uploadPrescription(context); // Retry finding stores
                },
                onCancel: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            );
          },
        ),
      );
      // **Start polling for prescription acceptance**
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        bool isAccepted = await checkPrescriptionStatus(context);
        print("isAccepted $isAccepted");
        if (isAccepted) timer.cancel(); // Stop polling when accepted
      });

    } else {
      _uploadStatus = 'Failed to upload prescription: ${response['message']}';
      LoadingDialog.hide(context);
    }

    _isUploading = false;
    notifyListeners();
  }


  Future<bool> enableLocation(BuildContext context) async {
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

        _isRequestAccepted = true;
        _isPrescriptionVerified = vendorName;
        notifyListeners();

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

        return true; // Stop polling
      } else {
        print("Failed to fetch vendor details.");
      }
    }

    return false; // Continue polling
  }

}
