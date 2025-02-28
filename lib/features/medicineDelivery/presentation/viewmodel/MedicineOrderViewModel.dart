import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:location/location.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/VerifyPrescriptionDialog.dart';

class MedicineOrderViewModel extends ChangeNotifier {
  final MedicineOrderService _medicineOrderService;

  MedicineOrderViewModel(BuildContext context)
      : _medicineOrderService = MedicineOrderService(context);

  File? _prescription;
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _isPrescriptionVerified = false;
  bool _isPlaceOrderEnabled = false;
  List<MedicalStore> _nearbyStores = []; // Store fetched medical stores

  File? get prescription => _prescription;
  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;
  bool get isPrescriptionVerified => _isPrescriptionVerified;
  bool get isPlaceOrderEnabled => _isPlaceOrderEnabled;
  List<MedicalStore> get nearbyStores => _nearbyStores; // Expose stores to UI if needed

  // File picker for prescription upload
  Future<void> pickPrescription(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      _prescription = File(result.files.single.path!);
      notifyListeners();

      print('pickPrescription: Prescription file selected, path: ${_prescription?.path}');

      // Upload and fetch nearby stores after selecting prescription
      await uploadPrescription(context);
    }
  }

  Future<void> uploadPrescription(BuildContext context) async {
    if (_prescription == null) return;

    _uploadStatus = 'Prescription selected successfully!';
    notifyListeners();
    print('uploadPrescription: $_uploadStatus');

    // Fetch nearby stores
    await _fetchNearbyMedicalStores();

    // Show verification dialog after fetching stores
    bool success = await _showVerifyPrescriptionDialog(context);

    if (success) {
      _isPrescriptionVerified = true;
      enablePlaceOrderButton();
    }

    notifyListeners();
  }

  Future<void> _fetchNearbyMedicalStores() async {
    print('_fetchNearbyMedicalStores: Fetching nearby stores...');
    try {
      _nearbyStores = await _medicineOrderService.fetchNearbyStores();
      print('_fetchNearbyMedicalStores: Fetched ${_nearbyStores.length} stores');
    } catch (e) {
      print('_fetchNearbyMedicalStores: Error fetching stores - $e');
      _nearbyStores = []; // Ensure the list is reset on failure
    }
    notifyListeners();
  }

  Future<bool> _showVerifyPrescriptionDialog(BuildContext context) async {
    print('showVerifyPrescriptionDialog: Showing verify dialog...');
    bool? success = await showDialog<bool>(
      context: context,
      builder: (context) {
        return VerifyPrescriptionDialog(
          onSuccess: _onPrescriptionVerified,
          nearbyStores: _nearbyStores, // Pass the fetched stores
        );
      },
    );

    print('showVerifyPrescriptionDialog: Dialog result: $success');
    if (success == true) {
      _isPrescriptionVerified = true;
      enablePlaceOrderButton();
    }

    notifyListeners();
    return success ?? false;
  }

  // Callback method for successful prescription verification
  void _onPrescriptionVerified() {
    print('_onPrescriptionVerified: Prescription verified callback triggered');
    enablePlaceOrderButton();
  }

  // Enable the place order button
  void enablePlaceOrderButton() {
    print('enablePlaceOrderButton: Enabling place order button');
    _isPlaceOrderEnabled = true;
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
}
