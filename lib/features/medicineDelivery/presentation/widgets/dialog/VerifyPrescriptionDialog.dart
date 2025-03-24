import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/ProductSelectionWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/RequestAcceptedWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/RequestSentWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/StepperWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/VerificationStatusWidget.dart';

class VerifyPrescriptionDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final List<MedicalStore> nearbyStores;

  VerifyPrescriptionDialog({required this.onSuccess, required this.nearbyStores});

  @override
  _VerifyPrescriptionDialogState createState() => _VerifyPrescriptionDialogState();
}

class _VerifyPrescriptionDialogState extends State<VerifyPrescriptionDialog> {
  int _currentStep = 0; // Stepper Progress (0 to 3)
  late Timer _timer;
  bool _isVerified = false;
  bool _storeAccepted = false;
  bool _showProductList = false;
  late MedicalStore _selectedStore;

  List<String> _availableProducts = ['Paracetamol', 'Aspirin', 'Cough Syrup'];

  @override
  void initState() {
    super.initState();
    _selectedStore = widget.nearbyStores.isNotEmpty
        ? widget.nearbyStores.first
        : MedicalStore(
      id: "N/A",
      name: "Unknown Store",
      address: "Not Available",
      latitude: 0.0,
      longitude: 0.0,
      contact: "N/A",
      medicines: [],
    );
    _startProcess();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startProcess() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });

        if (_currentStep == 1) {
          _storeAccepted = true; // Store accepts request
        }
        if (_currentStep == 2) {
          _isVerified = true; // Prescription verified
          widget.onSuccess(); // Callback to enable place order
        }
        if (_currentStep == 3) {
          _showProductList = true; // Show medicines
          _timer.cancel();
        }
      }
    });
  }

  void _goToCart(BuildContext context) {
    Navigator.pushNamed(context, "/goToCart");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StepperWidget(currentStep: _currentStep),
            SizedBox(height: 20),
            if (_currentStep == 0) RequestSentWidget(nearbyStores: widget.nearbyStores),
            if (_currentStep == 1) RequestAcceptedWidget(store: _selectedStore),
            if (_currentStep == 2) VerificationStatusWidget(),
            if (_currentStep == 3) ProductSelectionWidget(availableProducts: _availableProducts, onProceed: () => _goToCart(context)),
          ],
        ),
      ),
    );
  }
}
