import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicService.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ClinicPaymentService {
  final ClinicService _clinicService = ClinicService();

  // Callback functions
  Function(Map<String, dynamic>)? onPaymentSuccess;
  Function(String)? onPaymentError;
  Function(String)? onPaymentCancelled;
  Function()? onRefreshData;

  // Store appointment data to use after success
  late Map<String, dynamic> _appointmentData;

  ClinicPaymentService() {
    // Initialize PhonePe SDK
    _initializePhonePe();
  }

  Future<void> _initializePhonePe() async {
    try {
      const String environment = "UAT_SIM";  // Define as constant to ensure consistency
      print('🔄 Initializing PhonePe SDK...');
      print('📱 Environment: $environment');
      print('🔑 App ID: ${ApiConstants.phonePeAppId}');
      print('🏢 Merchant ID: ${ApiConstants.phonePeMerchantId}');
      print('📦 Package Name: com.vedika.heath.vedika_healthcare');

      // Initialize SDK with proper configuration
      bool isInitialized = await PhonePePaymentSdk.init(
        environment,  // Use the constant environment
        ApiConstants.phonePeMerchantId,  // Merchant ID
        ApiConstants.phonePeAppId,  // App ID
        true  // Enable logging
      );

      if (!isInitialized) {
        throw Exception("Failed to initialize PhonePe SDK");
      }

      // Wait for SDK configuration sync
      await Future.delayed(Duration(seconds: 2));
      
      print('✅ PhonePe SDK initialized successfully');
    } catch (e) {
      print('❌ Error initializing PhonePe SDK: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw Exception("Failed to initialize PhonePe SDK: $e");
    }
  }

  // Make _initializePhonePe public so it can be called from OnlineDoctorDetailPage
  Future<void> initializePhonePe() async {
    await _initializePhonePe();
  }


  // Handle successful payment
  Future<void> _handlePaymentSuccess(Map<String, dynamic> response) async {
    try {
      print('\n🎉 Processing Successful Payment...');
      print('📦 Response Data:');
      print(response);

      print('\n📅 Parsing Appointment Date...');
      DateTime appointmentDate = DateTime.parse(_appointmentData['date']);
      print('📅 Appointment Date: $appointmentDate');

      print('\n📝 Creating Appointment...');
      final result = await _clinicService.createClinicAppointment(
        doctorId: _appointmentData['doctorId'],
        userId: _appointmentData['userId'],
        status: _appointmentData['status'],
        isOnline: _appointmentData['isOnline'],
        date: appointmentDate,
        time: _appointmentData['time'],
        paidAmount: _appointmentData['paidAmount'],
        paymentStatus: 'paid',
        vendorId: _appointmentData['vendorId'],
        userResponseStatus: _appointmentData['userResponseStatus'],
        meetingUrl: _appointmentData['meetingUrl'],
      );

      print('\n✅ Appointment Creation Result:');
      print(result);

      if (onRefreshData != null) {
        print('\n🔄 Refreshing Data...');
        await onRefreshData!();
      }

      if (onPaymentSuccess != null) {
        print('\n📢 Calling Payment Success Callback...');
        onPaymentSuccess!(response);
      }
    } catch (e, stackTrace) {
      print('\n❌ Error in Payment Success Handler:');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      if (onPaymentSuccess != null) {
        onPaymentSuccess!(response);
      }
    }
  }

  // Error handler
  void _handlePaymentError(String error) {
    print('\n❌ Payment Error Handler:');
    print('Error Message: $error');
    if (onPaymentError != null) {
      print('📢 Calling Payment Error Callback...');
      onPaymentError!(error);
    }
  }

  // Cancel handler
  void _handlePaymentCancelled(String reason) {
    print('❌ Payment cancelled: $reason');
    if (onPaymentCancelled != null) {
      onPaymentCancelled!(reason);
    }
  }

  // Payment Gateway trigger with appointment data storage
  Future<void> openPaymentGateway({
    required String doctorId,
    required bool isOnline,
    required DateTime date,
    required String time,
    required double amount,
    required String vendorId,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? patientPhone,
    String? patientEmail,
    String? meetingUrl,
    required Function(Map<String, dynamic>) onPaymentSuccess,
    Function(String)? onPaymentError,
    Function(String)? onPaymentCancelled,
    Function()? onRefreshData,
  }) async {
    // Get user ID from storage
    String? userId = await StorageService.getUserId();

    if (userId == null) {
      print('❌ User ID not found in storage');
      return;
    }

    // Convert DateTime to string to avoid serialization issues
    String formattedDate = date.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD

    // Store appointment data for use after payment success
    _appointmentData = {
      'doctorId': doctorId,
      'userId': userId,
      'status': 'pending',
      'isOnline': isOnline,
      'date': formattedDate,
      'time': time,
      'paidAmount': amount,
      'paymentStatus': 'pending',
      'vendorId': vendorId,
      'userResponseStatus': 'pending',
      'meetingUrl': meetingUrl,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'patientPhone': patientPhone,
      'patientEmail': patientEmail,
    };

    // Store callbacks
    this.onPaymentSuccess = onPaymentSuccess;
    this.onPaymentError = onPaymentError;
    this.onPaymentCancelled = onPaymentCancelled;
    this.onRefreshData = onRefreshData;

    await _initiatePhonePePayment(amount);
  }

  // Generate a unique transaction ID following PhonePe's rules
  String _generateTransactionId() {
    // Get current timestamp in seconds
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    
    // Generate a random number between 1000-9999
    final random = (1000 + (DateTime.now().microsecond % 9000)).toString();
    
    // Format: MT + timestamp (last 9 digits) + random (4 digits)
    // This ensures a consistent length of 15 characters (MT + 13 digits)
    String combined = "MT${timestamp.substring(timestamp.length - 9)}$random";
    
    print('Generated Transaction ID: $combined (length: ${combined.length})');
    return combined;
  }

  // Generate a random number for merchantUserId
  String _getRandomNumber() {
    // Generate a 12-digit random number
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String random = (1000 + (DateTime.now().microsecond % 9000)).toString();
    return "${timestamp.substring(timestamp.length - 8)}$random";
  }

  Future<void> _initiatePhonePePayment(double amount) async {
    try {
      print('\n🔍 Starting PhonePe Payment Flow...');
      print('💰 Amount to be paid: $amount');

      // Validate merchant ID
      if (ApiConstants.phonePeMerchantId.isEmpty || ApiConstants.phonePeMerchantId != "M2202R7N3WE25") {
        throw Exception("Invalid merchant ID configured. Please verify with PhonePe.");
      }

      // Ensure SDK is initialized
      await _initializePhonePe();

      String transactionId = _generateTransactionId();
      String merchantUserId = "MU${_getRandomNumber()}";

      // Validate transaction ID format
      if (!RegExp(r'^MT\d{13}$').hasMatch(transactionId)) {
        throw Exception("Invalid transaction ID format: $transactionId");
      }

      print('\n📝 Generating Request Parameters:');
      print('🆔 Transaction ID: $transactionId');
      print('👤 Merchant User ID: $merchantUserId');
      print('📱 Mobile Number: ${_appointmentData['patientPhone'] ?? "9370320066"}');

      Map<String, dynamic> requestBody = {
        "merchantId": ApiConstants.phonePeMerchantId,
        "merchantTransactionId": transactionId,
        "merchantUserId": merchantUserId,
        "amount": (amount * 100).toInt(),
        "callbackUrl": ApiConstants.phonePeCallbackUrl,
        "mobileNumber": _appointmentData['patientPhone'] ?? "9370320066",
        "deviceContext": {
          "deviceOS": "ANDROID"
        },
        "paymentInstrument": {
          "type": "UPI_INTENT",
          "targetApp": "com.phonepe.app"
        }
      };

      print('\n📦 Original Request Body:');
      print(json.encode(requestBody));

      // Convert to JSON string and encode to base64 without padding
      String jsonString = json.encode(requestBody);
      String base64Body = base64.encode(utf8.encode(jsonString))
          .replaceAll('=', '') // Remove padding
          .replaceAll('+', '-') // URL-safe base64
          .replaceAll('/', '_');

      print('\n🔐 Base64 Encoded Body (without padding):');
      print(base64Body);

      // Calculate checksum using the correct format
      String apiEndPoint = "/pg/v1/pay";
      String dataToHash = "$base64Body$apiEndPoint${ApiConstants.phonePeSaltKey}";
      
      print('\n🔑 Data for Checksum:');
      print(dataToHash);

      String checksum = sha256.convert(utf8.encode(dataToHash)).toString() + "###" + ApiConstants.phonePeSaltKeyIndex.toString();
      
      print('\n🔒 Generated X-VERIFY:');
      print(checksum);

      // Create the final request body
      Map<String, dynamic> finalRequestBody = {
        "request": base64Body
      };

      print('\n📤 Final Request Body:');
      print(json.encode(finalRequestBody));

      // Validate API endpoint
      if (!ApiConstants.phonePeApiEndpoint.contains("api-preprod.phonepe.com")) {
        throw Exception("Invalid API endpoint. Please use the sandbox endpoint for testing.");
      }

      print('\n🌐 API Endpoint: ${ApiConstants.phonePeApiEndpoint}');

      print('\n🚀 Initiating PhonePe Transaction...');
      final result = await PhonePePaymentSdk.startTransaction(
        json.encode(finalRequestBody),
        ApiConstants.phonePeApiEndpoint,
      );

      print('\n📥 PhonePe Response:');
      print(result);

      if (result != null && result is Map<String, dynamic>) {
        print('\n🔍 Processing Response...');
        if (result.containsKey('status') && result['status'] == 'SUCCESS') {
          print('✅ Payment Successful!');
          _handlePaymentSuccess(result);
        } else if (result.containsKey('error')) {
          String error = result['error'].toString();
          if (error.contains('INVALID_MERCHANT_ID')) {
            print('❌ Invalid Merchant ID: $error');
            _handlePaymentError("Invalid merchant ID configured. Please verify with PhonePe.");
          } else if (error == 'Invalid orderId!') {
            print('❌ Invalid Transaction ID: $error');
            _handlePaymentError("Merchant Transaction ID is invalid. Please try again.");
          } else {
            print('❌ Payment Error: $error');
            _handlePaymentError(error);
          }
        } else {
          print('❌ Payment Failed: Unknown error');
          _handlePaymentError("Payment failed");
        }
      } else {
        print('❌ Invalid Response Format');
        _handlePaymentError("Invalid response format from PhonePe");
      }
    } catch (e, stackTrace) {
      print('\n❌ Error in Payment Flow:');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      _handlePaymentError(e.toString());
    }
  }


  void clear() {
    // Clear any resources if needed
  }
} 