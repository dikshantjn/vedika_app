import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/VerifyPrescriptionDialog.dart'; // Import the Location package

class MedicineOrderViewModel extends ChangeNotifier {
  File? _prescription;
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _isPrescriptionVerified = false;
  bool _isPlaceOrderEnabled = false; // Flag to control the Place Order button

  File? get prescription => _prescription;
  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;
  bool get isPrescriptionVerified => _isPrescriptionVerified;
  bool get isPlaceOrderEnabled => _isPlaceOrderEnabled; // Expose the flag to the UI

  // File picker for prescription upload
  Future<void> pickPrescription(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      _prescription = File(result.files.single.path!);
      notifyListeners();

      print('pickPrescription: Prescription file selected, path: ${_prescription?.path}');

      // Call uploadPrescription immediately after the prescription is picked
      await uploadPrescription(context);
    }
  }

  Future<void> uploadPrescription(BuildContext context) async {
    if (_prescription == null) return;

    _uploadStatus = 'Prescription selected successfully!';
    notifyListeners();
    print('uploadPrescription: ${_uploadStatus}'); // Add a log here to check if it's getting called

    // Show the verification dialog immediately after selecting the file
    bool success = await _showVerifyPrescriptionDialog(context);

    if (success) {
      _isPrescriptionVerified = true;
      enablePlaceOrderButton(); // Enable the Place Order button after successful verification
    }

    notifyListeners();
  }


  Future<bool> _showVerifyPrescriptionDialog(BuildContext context) async {
    print('showVerifyPrescriptionDialog: Showing verify dialog...');
    bool? success = await showDialog<bool>(
      context: context,
      builder: (context) {
        return VerifyPrescriptionDialog(onSuccess: _onPrescriptionVerified);
      },
    );
    print('showVerifyPrescriptionDialog: Dialog result: $success');
    if (success == true) {
      _isPrescriptionVerified = true;
      print('showVerifyPrescriptionDialog: Prescription verified');
      enablePlaceOrderButton();
    }

    notifyListeners();
    return success ?? false;
  }

  // Callback method for successful prescription verification
  void _onPrescriptionVerified() {
    print('_onPrescriptionVerified: Prescription verified callback triggered');
    // You can perform any additional logic after the prescription is verified here if needed.
    enablePlaceOrderButton(); // Enable the place order button here
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
      print('enableLocation: Location service is not enabled, requesting service...');
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('enableLocation: Location service is still not enabled');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location services are required to proceed.")),
        );
        return false;
      }
    } else {
      print('enableLocation: Location service is already enabled');
    }

    // Check location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      print('enableLocation: Location permission denied, requesting permission...');
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('enableLocation: Location permission still not granted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required.")),
        );
        return false;
      }
    } else {
      print('enableLocation: Location permission granted');
    }

    print('enableLocation: Finished');
    return true; // Return true if both service and permission are granted
  }

}
