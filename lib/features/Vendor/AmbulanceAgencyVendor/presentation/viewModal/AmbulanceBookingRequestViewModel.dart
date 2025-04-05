import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import Fluttertoast
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceBooking.dart';

class AmbulanceBookingRequestViewModel extends ChangeNotifier {
  bool _isAccepted = false;
  List<AmbulanceBookingRequestViewModel> bookingRequests = [];

  // Getters for title, customer name, etc.
  String get title => "Booking Request #1";
  String get customerName => "John Doe";
  String get time => DateTime.now().toString();
  bool get isAccepted => _isAccepted;
  String get status => _isAccepted ? "Accepted" : "Pending";

  // Fetch method to populate the bookingRequests list
  Future<void> fetchBookingRequests() async {
    bookingRequests = [
      AmbulanceBookingRequestViewModel().._isAccepted = false,
      AmbulanceBookingRequestViewModel().._isAccepted = true,
    ];
    notifyListeners();
  }

  // Toggle the booking status (Accepted/Not Accepted) and show Toast
  void toggleRequestStatus() {
    _isAccepted = !_isAccepted;
    notifyListeners();

    // Show a Toast message after toggling the request status
    Fluttertoast.showToast(
      msg: _isAccepted
          ? "Request Accepted"
          : "Request Rejected", // Change message based on status
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _isAccepted ? Colors.green : Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
