import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class CartPaymentService {
  final Razorpay _razorpay = Razorpay();
  bool _isInitialized = false;
  
  // Store current order details for medicine orders
  String? _currentOrderId;
  String? _currentAddressId;

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled;
  
  // Additional callback for order placement
  Function(String orderId, String addressId, String paymentId)? onOrderPlacementRequired;

  CartPaymentService() {
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
    
    // For medicine orders, notify about order placement requirement
    if (_currentOrderId != null && _currentAddressId != null && onOrderPlacementRequired != null) {
      debugPrint("📦 Medicine order payment successful, notifying order placement");
      onOrderPlacementRequired!(_currentOrderId!, _currentAddressId!, response.paymentId ?? '');
    }
    
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

  /// Open payment gateway for cart orders (products or medicines)
  /// 
  /// [amount] - Total amount in rupees
  /// [key] - Razorpay API key
  /// [name] - Company/App name
  /// [description] - Order description
  /// [orderType] - Type of order: 'product' or 'medicine'
  /// [orderId] - Order ID for medicine orders
  /// [addressId] - Address ID for medicine orders
  void openPaymentGateway({
    required double amount,
    required String key,
    required String name,
    required String description,
    required String orderType,
    String? orderId,
    String? addressId,
  }) {
    debugPrint("🚀 Opening payment gateway for $orderType order...");
    debugPrint("💰 Amount: $amount");
    debugPrint("🔑 Key: $key");
    debugPrint("📦 Order Type: $orderType");
    
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

    // Store order details for medicine orders
    if (orderType == 'medicine' && orderId != null && addressId != null) {
      _currentOrderId = orderId;
      _currentAddressId = addressId;
    }

    try {
      _razorpay.open(options);
      debugPrint("✅ Payment gateway opened successfully for $orderType order");
    } catch (e) {
      debugPrint("❌ Error opening payment gateway for $orderType order: $e");
      if (onPaymentError != null) {
        onPaymentError!(PaymentFailureResponse(
          0, // code
          "Failed to open payment gateway: $e", // message
          null // error
        ));
      }
    }
  }

  /// Open payment gateway for product orders
  void openProductPaymentGateway({
    required double amount,
    required String key,
    required String name,
    required String description,
  }) {
    openPaymentGateway(
      amount: amount,
      key: key,
      name: name,
      description: description,
      orderType: 'product',
    );
  }

  /// Open payment gateway for medicine orders
  void openMedicinePaymentGateway({
    required double amount,
    required String key,
    required String name,
    required String description,
    required String orderId,
    required String addressId,
  }) {
    openPaymentGateway(
      amount: amount,
      key: key,
      name: name,
      description: description,
      orderType: 'medicine',
      orderId: orderId,
      addressId: addressId,
    );
  }

  // Clear Razorpay instance
  void clear() {
    debugPrint("🧹 Clearing Razorpay instance");
    _razorpay.clear();
    _isInitialized = false;
    _currentOrderId = null;
    _currentAddressId = null;
  }

  // Dispose Razorpay instance
  void dispose() {
    debugPrint("🗑️ Disposing Razorpay instance");
    _razorpay.clear();
    _isInitialized = false;
    _currentOrderId = null;
    _currentAddressId = null;
  }
}
