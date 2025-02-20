import 'package:razorpay_flutter/razorpay_flutter.dart';

class AmbulancePaymentService {
  final Razorpay _razorpay = Razorpay();

  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  AmbulancePaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ✅ Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  // ❌ Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  // 🔄 Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  // 🚀 **Open Razorpay Payment Gateway**
  void openPaymentGateway({
    required double amount, // Amount in INR (₹)
    required String key,
    required String userPhone,
    required String userEmail,
  }) {
    var options = {
      'key': key,
      'amount': amount * 100, // Convert INR to paise
      'name': 'Ambulance Service',
      'description': 'Payment for ambulance ride',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      },
      'theme': {'color': '#38A3A5'}, // Theme color
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error launching Razorpay: $e');
    }
  }

  // Cleanup function
  void dispose() {
    _razorpay.clear();
  }
}
