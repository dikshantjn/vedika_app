import 'package:razorpay_flutter/razorpay_flutter.dart';

class MedicineOrderDeliveryRazorPayService {
  final Razorpay _razorpay = Razorpay();

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled; // Use PaymentFailureResponse for cancellations

  MedicineOrderDeliveryRazorPayService() {
    // Initialize Razorpay listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentCancelled); // Correct usage for cancellation
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

  // Open Razorpay payment gateway
  void openPaymentGateway(double amount, String key, String name, String description) {
    var options = {
      'key': key,
      'amount': amount * 100, // Amount in paise (1 INR = 100 paise)
      'name': name,
      'description': description,
      'prefill': {
        'contact': 'USER_PHONE_NUMBER', // Replace with user's phone number
        'email': 'USER_EMAIL', // Replace with user's email
      },
      'theme': {'color': '#38A3A5'},
    };

    try {
      _razorpay.open(options); // Open Razorpay payment gateway
    } catch (e) {
      print('Error: $e');
    }
  }

  // Clear Razorpay instance
  void clear() {
    _razorpay.clear();
  }
}
