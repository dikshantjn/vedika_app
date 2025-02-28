import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/AfterVerificationWidget.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/dialog/BeforeVerificationWidget.dart';

class VerifyPrescriptionDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final List<MedicalStore> nearbyStores;

  VerifyPrescriptionDialog({required this.onSuccess, required this.nearbyStores});

  @override
  _VerifyPrescriptionDialogState createState() => _VerifyPrescriptionDialogState();
}

class _VerifyPrescriptionDialogState extends State<VerifyPrescriptionDialog> {
  int _remainingTime = 300;
  late Timer _timer;
  bool _isVerified = false;
  bool _showSuccessMessage = false;
  bool _isVerificationInProgress = false;
  List<String> _medicines = ['Medicine A', 'Medicine B', 'Medicine C'];
  List<String> _medicineImages = [
    'assets/category/category.png',
    'assets/category/category.png',
    'assets/category/category.png'
  ];
  late MedicalStore _selectedStore;

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
    _startCountdown();
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });

        if (_remainingTime == 290 && !_isVerificationInProgress) {
          setState(() {
            _isVerificationInProgress = true;
          });
          Timer(Duration(seconds: 5), () {
            setState(() {
              _showSuccessMessage = true;
              _isVerified = true;
            });
            widget.onSuccess();
          });
        }
      } else {
        _timer.cancel();
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              _isVerified ? 'assets/animations/verified.json' : 'assets/animations/scanPrescription.json',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            _showSuccessMessage
                ? AfterVerificationWidget(
              selectedStore: _selectedStore,
              onGoToCart: () => _goToCart(context), // Pass function reference properly
            )
                : BeforeVerificationWidget(
              remainingTime: _remainingTime,
            ),
          ],
        ),
      ),
    );
  }
}
