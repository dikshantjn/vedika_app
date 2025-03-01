import 'package:razorpay_flutter/razorpay_flutter.dart';

class LabAppointmentPaymentService {
  final Razorpay _razorpay = Razorpay();

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled; // Use PaymentFailureResponse

  LabAppointmentPaymentService() {
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

  // Open Razorpay payment gateway for lab appointment
  void openLabAppointmentPaymentGateway({
    required int amount,
    required String key,
    required String patientName,
    required String labName,
    required String appointmentDetails,
  }) {
    var options = {
      'key': key,
      'amount': amount * 100, // The amount in paise
      'name': patientName,
      'description': appointmentDetails,
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

  void clear() {
    _razorpay.clear();
  }
}
