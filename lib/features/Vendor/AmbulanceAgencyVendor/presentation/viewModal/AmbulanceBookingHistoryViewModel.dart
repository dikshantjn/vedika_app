import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceBookingHistoryViewModel extends ChangeNotifier {
  List<AmbulanceBooking> bookingHistory = [];

  Future<void> fetchBookingHistory() async {
    // bookingHistory = [
    //   AmbulanceBooking(
    //     requestId: '1',
    //     userId: 'user123',
    //     vendorId: 'vendor123',
    //     customerName: 'John Doe',
    //     customerContact: '1234567890',
    //     pickupLocation: 'Address 1',
    //     dropLocation: 'Address 2',
    //     urgency: 'Urgent',
    //     vehicleType: 'BLS',
    //     totalAmount: 550.0,
    //     timestamp: DateTime.now().subtract(const Duration(days: 1)),
    //     requiredDateTime: DateTime.now().add(const Duration(hours: 2)),
    //     status: 'Completed',
    //     user: null, // Replace with dummy user object if needed
    //   ),
    //   AmbulanceBooking(
    //     requestId: '2',
    //     userId: 'user124',
    //     vendorId: 'vendor124',
    //     customerName: 'Jane Smith',
    //     customerContact: '0987654321',
    //     pickupLocation: 'Address 3',
    //     dropLocation: 'Address 4',
    //     urgency: 'Non-Urgent',
    //     vehicleType: 'ALS',
    //     totalAmount: 650.0,
    //     timestamp: DateTime.now().subtract(const Duration(days: 2)),
    //     requiredDateTime: DateTime.now().add(const Duration(hours: 4)),
    //     status: 'Pending Payment',
    //     user: null, // Replace with dummy user object if needed
    //   ),
    // ];

    notifyListeners();
  }
}
