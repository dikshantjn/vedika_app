import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankAgencyService.dart';

class BloodBankPaymentService {
  final Razorpay _razorpay = Razorpay();
  final BloodBankAgencyService _bloodBankAgencyService = BloodBankAgencyService();

  // Callback functions
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled;

  // Store bookingId to use after success
  late String _currentBookingId;

  BloodBankPaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentCancelled); // optional
  }

  // ✅ Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }

    try {
      print("Calling update API for bookingId: $_currentBookingId");
      await _bloodBankAgencyService.updatePaymentDetails(_currentBookingId);
      print('✅ Payment details updated successfully.');
    } catch (e) {
      print('❌ Error updating payment details: $e');
    }
  }

  // Error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  // Cancel handler
  void _handlePaymentCancelled(PaymentFailureResponse response) {
    if (onPaymentCancelled != null) {
      onPaymentCancelled!(response);
    }
  }

  // ✅ Payment Gateway trigger with bookingId storage
  void openPaymentGateway({
    required double amount,
    required String name,
    required String description,
    required String bookingId,
    required Function onPaymentSuccess,
  }) {
    _currentBookingId = bookingId; // ✅ Save for later use in success callback

    // Optional immediate success callback (before actual payment)
    onPaymentSuccess();

    var options = {
      'key': ApiConstants.razorpayApiKey,
      'amount': amount * 100,
      'name': name,
      'description': description,
      'prefill': {
        'contact': 'USER_PHONE_NUMBER', // Replace with dynamic values
        'email': 'USER_EMAIL',
      },
      'theme': {'color': '#38A3A5'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('❌ Error opening Razorpay: $e');
    }
  }

  void clear() {
    _razorpay.clear();
  }
}

