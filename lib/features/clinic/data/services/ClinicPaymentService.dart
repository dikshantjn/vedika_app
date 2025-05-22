import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicService.dart';

class ClinicPaymentService {
  final Razorpay _razorpay = Razorpay();
  final ClinicService _clinicService = ClinicService();

  // Callback functions
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled;
  Function()? onRefreshData;

  // Store appointment data to use after success
  late Map<String, dynamic> _appointmentData;

  ClinicPaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentCancelled);
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      print("✅ Payment successful with ID: ${response.paymentId}");

      // Parse the date back to DateTime for the API call
      DateTime appointmentDate = DateTime.parse(_appointmentData['date']);

      // Use the saved appointment data to create appointment
      final result = await _clinicService.createClinicAppointment(
        doctorId: _appointmentData['doctorId'],
        userId: _appointmentData['userId'],
        status: _appointmentData['status'],
        isOnline: _appointmentData['isOnline'],
        date: appointmentDate,
        time: _appointmentData['time'],
        paidAmount: _appointmentData['paidAmount'],
        paymentStatus: 'paid', // Update payment status
        vendorId: _appointmentData['vendorId'],
        userResponseStatus: _appointmentData['userResponseStatus'],
        meetingUrl: _appointmentData['meetingUrl'],
      );

      print('✅ Appointment creation result: $result');

      // Call the refresh callback after successful payment
      if (onRefreshData != null) {
        print('🔄 Refreshing data after payment success');
        await onRefreshData!();
      }

      // Call payment success callback after all operations are complete
      if (onPaymentSuccess != null) {
        onPaymentSuccess!(response);
      }
    } catch (e) {
      print('❌ Error creating appointment: $e');
      // Still call payment success callback even if appointment creation fails
      if (onPaymentSuccess != null) {
        onPaymentSuccess!(response);
      }
    }
  }

  // Error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Payment failed: ${response.message}');
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  // Cancel handler
  void _handlePaymentCancelled(PaymentFailureResponse response) {
    print('❌ Payment cancelled: ${response.message}');
    if (onPaymentCancelled != null) {
      onPaymentCancelled!(response);
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
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    Function(PaymentFailureResponse)? onPaymentError,
    Function(PaymentFailureResponse)? onPaymentCancelled,
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
      'date': formattedDate, // Use the formatted date string
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

    // Configure payment options
    var options = {
      'key': ApiConstants.razorpayApiKey,
      'amount': amount * 100, // Convert to smallest currency unit (paise)
      'name': 'Vedika Healthcare',
      'description': 'Doctor Consultation Fee',
      'prefill': {
        'contact': patientPhone ?? '',
        'email': patientEmail ?? '',
      },
      'notes': _appointmentData,
      'theme': {'color': '#328E6E'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('❌ Error opening Razorpay: $e');
    }
  }

  void clear() {
    _razorpay.clear();
  }
} 