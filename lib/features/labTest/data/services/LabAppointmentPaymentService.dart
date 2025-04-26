import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/labTest/data/services/LabTestService.dart';

class LabAppointmentPaymentService {
  final Razorpay _razorpay = Razorpay();
  final LabTestService _labTestService = LabTestService();

  // Callback functions to handle payment response
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(PaymentFailureResponse)? onPaymentCancelled; // Use PaymentFailureResponse
  
  // Callbacks for booking process
  Function(Map<String, dynamic>)? onBookingSuccess;
  Function(String)? onBookingError;

  LabAppointmentPaymentService() {
    // Initialize Razorpay listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentCancelled); // Correct usage
  }

  // Handle successful payment and create booking
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // First notify payment success
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
    
    if (_bookingData != null) {
      try {
        // Update the booking with payment information
        Map<String, dynamic> bookingData = _bookingData!.toJson();
        
        // Add payment details
        bookingData['paymentId'] = response.paymentId;
        bookingData['paymentStatus'] = 'Completed';
        
        // Ensure all required fields are present
        if (bookingData['userId'] == null) {
          print('Error: userId is required but not provided');
          if (onBookingError != null) {
            onBookingError!('UserId is required but not provided');
          }
          return;
        }
        
        // Log the complete booking data for debugging
        print('Creating booking with data: $bookingData');
        
        // Create a new booking object with the updated data
        final booking = LabTestBooking.fromJson(bookingData);
        
        // Create the booking after successful payment
        final result = await _labTestService.createLabTestBooking(booking);
        
        if (result['success'] == true) {
          if (onBookingSuccess != null) {
            onBookingSuccess!(result);
          }
        } else {
          if (onBookingError != null) {
            onBookingError!(result['message'] ?? 'Failed to create booking');
          }
        }
      } catch (e) {
        print('Error creating booking: $e');
        if (onBookingError != null) {
          onBookingError!('Error creating booking: $e');
        }
      }
    } else {
      print('Warning: No booking data available when payment succeeded');
      if (onBookingError != null) {
        onBookingError!('No booking data available');
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

  // Booking data to be used after payment success
  LabTestBooking? _bookingData;

  // Open Razorpay payment gateway for lab appointment
  void openLabAppointmentPaymentGateway({
    LabTestBooking? booking,
    required int amount,
    required String key,
    required String patientName,
    required String labName,
    required String appointmentDetails,
  }) {
    // Store booking data for use after payment
    _bookingData = booking;
    
    var options = {
      'key': key,
      'amount': amount * 100, // The amount in paise
      'name': labName,
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
      if (onBookingError != null) {
        onBookingError!('Failed to open payment gateway: $e');
      }
    }
  }

  void clear() {
    _razorpay.clear();
  }
}
