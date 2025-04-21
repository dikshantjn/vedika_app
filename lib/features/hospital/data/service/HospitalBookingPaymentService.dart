import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalService.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';

class HospitalBookingPaymentService {
  final _razorpay = Razorpay();
  final _hospitalService = HospitalService();
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentSuccessResponse)? onPaymentCancelled;

  HospitalBookingPaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet if needed
  }

  void openPaymentGateway(int amount, String bookingId, String name, String description) {
    var options = {
      'key': ApiConstants.razorpayApiKey,
      'amount': amount * 100, // Convert to paise
      'name': name,
      'description': description,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening payment gateway: $e');
    }
  }

  Future<void> updatePaymentStatus(String bookingId) async {
    try {
      final result = await _hospitalService.updatePaymentStatus(bookingId);
      if (result['success']) {
        print('Payment status updated successfully');
      } else {
        print('Failed to update payment status: ${result['message']}');
      }
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  void clear() {
    _razorpay.clear();
  }
}
