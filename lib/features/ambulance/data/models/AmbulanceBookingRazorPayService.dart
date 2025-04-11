import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingService.dart';

class AmbulanceBookingRazorPayService {
  final Razorpay _razorpay = Razorpay();
  final AmbulanceBookingService _ambulanceBookingService = AmbulanceBookingService();  // Instantiate AmbulanceBookingService

  // Store the requestId for later use in payment success
  String? _requestId;

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled; // Use PaymentFailureResponse for cancellations

  AmbulanceBookingRazorPayService() {
    // Initialize Razorpay listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentCancelled); // Correct usage for cancellation
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }

    // Use the stored requestId for updating payment status
    if (_requestId != null) {
      try {
        await _ambulanceBookingService.updatePaymentCompleted(_requestId!);
        print('Payment status updated to completed successfully');
      } catch (e) {
        print('Failed to update payment status: $e');
      }
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

  // Open the payment gateway
  void openPaymentGateway({
    required double amount,
    required String key,
    required String name,
    required String description,
    required String phoneNumber,
    required String email,
    required String requestId,  // Accept requestId as a parameter
    Function()? onPaymentSuccess,

  }) {

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      if (onPaymentSuccess != null) {
        onPaymentSuccess();
      }
      // maybe show toast or alert
    });
    // Store the requestId so it can be used later in the success handler
    _requestId = requestId;

    int amountInPaise = (amount * 100).round(); // ✅ Use `.round()` to avoid precision issues

    var options = {
      'key': key,
      'amount': amountInPaise, // ✅ Ensure it's an integer
      'name': name,
      'description': description,
      'prefill': {
        'contact': phoneNumber, // Use actual user's phone number
        'email': email, // Use actual user's email
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

