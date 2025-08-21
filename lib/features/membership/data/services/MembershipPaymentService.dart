import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';


class MembershipPaymentService {
  final Razorpay _razorpay = Razorpay();
  final Dio _dio = Dio();

  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  MembershipPaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // Debug: confirm listeners registered
    // ignore: avoid_print
    print('🔔 Razorpay listeners registered');
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // ignore: avoid_print
    print('✅ Razorpay SUCCESS -> paymentId: ${response.paymentId}, orderId: ${response.orderId}, signature: ${response.signature}');
    if (onPaymentSuccess != null) onPaymentSuccess!(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // ignore: avoid_print
    print('❌ Razorpay ERROR -> code: ${response.code}, message: ${response.message}');
    if (onPaymentError != null) onPaymentError!(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // ignore: avoid_print
    print('📦 Razorpay EXTERNAL WALLET -> ${response.walletName}');
    if (onExternalWallet != null) onExternalWallet!(response);
  }

  /// Create membership order on the backend
  Future<Map<String, dynamic>?> createOrder(String membershipPlanId) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Debug: Print the exact URL being called
      ApiEndpoints.printEndpointUrl(ApiEndpoints.createMembershipOrder);

      print('📡 API Request Details:');
      print('   URL: ${ApiEndpoints.createMembershipOrder}');
      print('   Method: POST');
      print('   User ID: $userId');
      print('   Plan ID: $membershipPlanId');
      
      final requestPayload = {
        'userId': userId,
        'membershipPlanId': membershipPlanId,
      };
      print('   Request Body: $requestPayload');

      final response = await _dio.post(
        ApiEndpoints.createMembershipOrder,
        data: requestPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            // Don't throw for any status code, let us handle it manually
            return true;
          },
        ),
      );

      print('📡 API Response Details:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else if (response.statusCode == 500) {
        print('🔥 Server Error (500) Details:');
        print('   Response Data: ${response.data}');
        print('   Request Payload: $requestPayload');
        print('   🔍 Possible backend issues:');
        print('      - API endpoint not implemented');
        print('      - Database connection issues');
        print('      - Validation errors in request body');
        print('      - Missing required fields');
        print('      - Field type mismatches');
        throw Exception('Server error (500): ${response.data.toString()}');
      } else {
        throw Exception('Failed to create order: Status ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ DioException Details:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');
      print('   Request Options: ${e.requestOptions.data}');
      print('   Request URL: ${e.requestOptions.uri}');
      if (e.response?.statusCode == 500) {
        print('🔥 Server Error (500) - Check your backend logs');
        print('   Response Data: ${e.response?.data}');
        print('   🔍 Possible issues:');
        print('      - Backend server not running');
        print('      - Wrong IP address/port');
        print('      - API endpoint not implemented');
        print('      - Database connection issues');
        print('      - Validation errors in request body');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Error creating order: $e');
    }
  }

  /// Verify payment with the backend
  Future<bool> verifyPayment(String membershipPlanId, String paymentId) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      print('🔐 Verifying payment with backend...');
      print('   URL: ${ApiEndpoints.verifyMembershipPayment}');
      print('   Method: POST');
      print('   userId: $userId');
      print('   membershipPlanId: $membershipPlanId');
      print('   paymentId: $paymentId');

      final response = await _dio.post(
        ApiEndpoints.verifyMembershipPayment,
        data: {
          'userId': userId,
          'membershipPlanId': membershipPlanId,
          'paymentId': paymentId,
          'paymentMethod': 'razorpay',
        },
      );

      print('🔐 Verify Response -> status: ${response.statusCode}, data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final boolFlag = (data['success'] == true) || (data['verified'] == true);
          final hasMembership = data['membership'] != null;
          final msg = (data['message'] ?? '').toString().toLowerCase();
          final msgIndicatesSuccess = msg.contains('verified') || msg.contains('activated') || msg.contains('success');
          return boolFlag || hasMembership || msgIndicatesSuccess;
        }
        // If backend returns non-map but HTTP 200, assume success
        return true;
      } else {
        throw Exception('Failed to verify payment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ Verify DioException: ${e.message}, status: ${e.response?.statusCode}, data: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Verify Exception: $e');
      throw Exception('Error verifying payment: $e');
    }
  }

  void openPaymentGateway({
    required double amount,
    required String key,
    required String planName,
    String? userPhone,
    String? userEmail,
    String? orderId,
  }) {
    final options = {
      'key': key,
      'amount': (amount * 100).toInt(),
      'name': 'Vedika Healthcare',
      'description': 'Purchase: $planName',
      'prefill': {
        'contact': userPhone ?? '',
        'email': userEmail ?? '',
      },
      'theme': {'color': '#6B73FF'},
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    // ignore: avoid_print
    print('💳 Opening Razorpay with options: $options');

    try {
      _razorpay.open(options);
    } catch (e) {
      // ignore: avoid_print
      print('Error launching Razorpay: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
    // ignore: avoid_print
    print('🧹 Razorpay listeners cleared');
  }
}


