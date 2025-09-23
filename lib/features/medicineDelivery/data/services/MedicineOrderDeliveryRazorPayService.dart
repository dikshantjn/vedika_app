import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class MedicineOrderDeliveryRazorPayService {
  final Razorpay _razorpay = Razorpay();
  bool _isInitialized = false;

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled;

  MedicineOrderDeliveryRazorPayService() {
    _initializeListeners();
  }

  void _initializeListeners() {
    if (!_isInitialized) {

      // Remove any existing listeners first
      _razorpay.clear();
      
      // Set up new listeners
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      _isInitialized = true;
    }
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("🎯 Payment success event received");
    debugPrint("💰 Payment ID: ${response.paymentId}");
    debugPrint("🔑 Order ID: ${response.orderId}");
    debugPrint("💳 Signature: ${response.signature}");
    debugPrint("📦 Response Data: ${response.data}");
    
    if (onPaymentSuccess != null) {
      debugPrint("📞 Calling payment success callback");
      onPaymentSuccess!(response);
      debugPrint("✅ Payment success callback executed");
    } else {
      debugPrint("⚠️ No payment success callback registered");
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ Payment error event received");
    debugPrint("🔢 Error code: ${response.code}");
    debugPrint("💬 Error message: ${response.message}");
    debugPrint("❌ Error details: ${response.error}");
    
    if (onPaymentError != null) {
      debugPrint("📞 Calling payment error callback");
      onPaymentError!(response);
      debugPrint("✅ Payment error callback executed");
    } else {
      debugPrint("⚠️ No payment error callback registered");
    }
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("👛 External wallet event received");
    debugPrint("🏦 Wallet name: ${response.walletName}");
  }

  void openPaymentGateway(double amount, String key, String name, String description) {
    debugPrint("🚀 Opening payment gateway...");
    debugPrint("💰 Amount: $amount");
    debugPrint("🔑 Key: $key");
    
    // Ensure listeners are initialized
    _initializeListeners();
    
    int amountInPaise = (amount * 100).round();
    debugPrint("💵 Amount in paise: $amountInPaise");

    var options = {
      'key': key,
      'amount': amountInPaise,
      'name': name,
      'description': description,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'theme': {
        'color': '#38A3A5',
        'hide_topbar': false,
        'backdrop_color': '#FFFFFF'
      },
      'config': {
        'display': {
          'hide': ['upi_intent'],
          'blocks': {
            'banks': {
              'name': 'Pay using UPI',
              'instruments': [
                {
                  'method': 'upi',
                  'flows': ['intent', 'collect']
                }
              ]
            }
          }
        }
      }
    };

    try {
      _razorpay.open(options);
      debugPrint("✅ Payment gateway opened successfully");
    } catch (e) {
      debugPrint("❌ Error opening payment gateway: $e");
      if (onPaymentError != null) {
        onPaymentError!(PaymentFailureResponse(
          0, // code
          "Failed to open payment gateway: $e", // message
          null // error
        ));
      }
    }
  }

  // Clear Razorpay instance
  void clear() {
    debugPrint("🧹 Clearing Razorpay instance");
    _razorpay.clear();
    _isInitialized = false;
  }

  // Dispose Razorpay instance
  void dispose() {
    debugPrint("🗑️ Disposing Razorpay instance");
    _razorpay.clear();
    _isInitialized = false;
  }
}
