import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductCartPaymentService {
  late final Razorpay _razorpay;

  VoidCallback? _onExternalDispose;

  ProductCartPaymentService() {
    _razorpay = Razorpay();
  }

  void setOnExternalDispose(VoidCallback cb) {
    _onExternalDispose = cb;
  }

  void openPaymentGateway({
    required double amount,
    required String apiKey,
    required String title,
    required String description,
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
  }) {
    // Razorpay expects amount in paise (integer)
    final int amountInPaise = (amount * 100).round();

    final Map<String, Object?> options = <String, Object?>{
      'key': apiKey,
      'amount': amountInPaise,
      'name': title,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': <String, String?>{
        'contact': '',
        'email': '',
      },
      'theme': <String, String>{'color': '#0E5FD8'},
    };

    _razorpay.clear();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});

    _razorpay.open(options);
  }

  void dispose() {
    try {
      _razorpay.clear();
    } finally {
      _onExternalDispose?.call();
    }
  }
}


