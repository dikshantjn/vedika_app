import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceFee.dart';

class FeeViewModel extends ChangeNotifier {
  Fee _fee = Fee(baseFee: 100.0, gst: 18.0, discount: 10.0, totalAmount: 108.0);

  Fee get fee => _fee;

  // Method to update the fee details
  void updateFee(double baseFee, double gst, double discount) {
    _fee = Fee(
      baseFee: baseFee,
      gst: gst,
      discount: discount,
      totalAmount: baseFee + gst - discount,
    );
    notifyListeners();
  }

  // Method to calculate the total fee (base fee + GST - discount)
  void calculateTotalFee() {
    _fee.totalAmount = _fee.baseFee + _fee.gst - _fee.discount;
    notifyListeners();
  }
}
