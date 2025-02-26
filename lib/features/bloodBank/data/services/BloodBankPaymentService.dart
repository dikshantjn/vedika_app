import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';

class BloodBankPaymentService {
  final Razorpay _razorpay = Razorpay();

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled;

  BloodBankPaymentService() {
    // Initialize Razorpay listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentCancelled); // Correct usage
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  // Handle payment cancellation (using PaymentFailureResponse here)
  void _handlePaymentCancelled(PaymentFailureResponse response) {
    if (onPaymentCancelled != null) {
      onPaymentCancelled!(response);
    }
  }

  // Open Razorpay payment gateway for blood bank payment
  void openPaymentGateway(int amount, String name, String description) {
    var options = {
      'key': ApiConstants.razorpayApiKey, // Use global API key
      'amount': amount * 100, // The amount in paise
      'name': name,
      'description': description,
      'prefill': {
        'contact': 'USER_PHONE_NUMBER', // Replace with the actual user's phone number
        'email': 'USER_EMAIL', // Replace with the actual user's email
      },
      'theme': {'color': '#38A3A5'},
    };

    try {
      _razorpay.open(options); // Open Razorpay payment gateway
    } catch (e) {
      print('Error: $e');
    }
  }

  void clear() {
    _razorpay.clear();
  }
}
