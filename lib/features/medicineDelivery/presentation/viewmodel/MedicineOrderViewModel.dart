import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/FirebasePrescriptionUploadService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/PrescriptionService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/VerifyPrescriptionDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class MedicineOrderViewModel extends ChangeNotifier {
  final MedicineOrderService _medicineOrderService;
  final PrescriptionService _prescriptionService = PrescriptionService();

  MedicineOrderViewModel(BuildContext context)
      : _medicineOrderService = MedicineOrderService(context);

  File? _prescription;
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _isPrescriptionVerified = false;
  bool _isPlaceOrderEnabled = false;
  bool _isRequestAccepted = false; // Added for Request Accepted status
  bool _isPrescriptionVerifiedStatus = false; // Added for Prescription Verified status
  bool _isItemsAddedToCart = false; // Added for Items Added to Cart status
  List<MedicalStore> _nearbyStores = []; // Store fetched medical stores
  bool _isRequestBeingProcessed = false; // New property for request processing status

  File? get prescription => _prescription;
  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;
  bool get isPrescriptionVerified => _isPrescriptionVerified;
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

    _showLoadingDialog(context, "Uploading prescription...");

    print('uploadPrescription: $_uploadStatus');

    FirebasePrescriptionUploadService uploadService = FirebasePrescriptionUploadService();
    String? prescriptionUrl = await uploadService.uploadPrescription(_prescription!);

    if (prescriptionUrl == null) {
      _uploadStatus = 'Failed to upload prescription';
      print('uploadPrescription: $_uploadStatus');
      _isUploading = false;
      notifyListeners();
      Navigator.pop(context);
      return;
    }

    _uploadStatus = 'Fetching user location...';
    notifyListeners();
    print('uploadPrescription: $_uploadStatus');

    LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.fetchLocation();

    double? latitude = locationProvider.latitude;
    double? longitude = locationProvider.longitude;

    if (latitude == null || longitude == null) {
      _uploadStatus = 'Failed to get user location';
      print('uploadPrescription: $_uploadStatus');
      _isUploading = false;
      notifyListeners();
      Navigator.pop(context);
      return;
    }

    _uploadStatus = 'Sending prescription to nearby medical stores...';
    notifyListeners();
    print('uploadPrescription: $_uploadStatus');

    var response = await _prescriptionService.uploadPrescription(
      prescriptionUrl: prescriptionUrl,
      userId: userId!,
      latitude: latitude,
      longitude: longitude,
    );

    Navigator.pop(context); // Close loading dialog

    if (response['success']) {
      _uploadStatus = 'Prescription uploaded successfully!';
      _isRequestBeingProcessed = true;
      print('uploadPrescription: ${response['message']}');


    } else {
      _uploadStatus = 'Failed to upload prescription: ${response['message']}';
      print('uploadPrescription: $_uploadStatus');
    }

    _isUploading = false;
    notifyListeners();
  }


  // Enable the place order button
  void enablePlaceOrderButton() {
    print('enablePlaceOrderButton: Enabling place order button');
    _isPlaceOrderEnabled = true;
    notifyListeners();
  }

  // **New Methods**
  void setRequestAccepted() {
    _isRequestAccepted = true;
    _uploadStatus = 'Request accepted by store';
    notifyListeners();
  }

  void setPrescriptionVerified() {
    _isPrescriptionVerifiedStatus = true;
    _uploadStatus = 'Prescription verified';
    notifyListeners();
  }

  void addItemsToCart() {
    _isItemsAddedToCart = true;
    _uploadStatus = 'Items added to cart';
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

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing dialog
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(message, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

