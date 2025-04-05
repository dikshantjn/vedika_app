import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceBooking.dart';

class AmbulanceBookingHistoryViewModel extends ChangeNotifier {
  List<AmbulanceBooking> bookingHistory = [];

  // Fetch booking history (This would be typically from an API or database)
  Future<void> fetchBookingHistory() async {
    // For now, adding dummy data. Replace with actual data fetching.
    bookingHistory = [
      AmbulanceBooking(
        requestId: '1',
        userId: 'user123',  // Add a valid userId
        vendorId: 'vendor123',  // Add a valid vendorId
        customerName: 'John Doe',
        phoneNumber: '1234567890',  // Add a valid phoneNumber
        pickupLocation: 'Address 1',
        dropLocation: 'Address 2',
        urgency: 'Urgent',
        vehicleType: 'BLS',
        numberOfPersons: 2,
        requiredDateTime: DateTime.now(),
        fees: 500,
        gst: 18,
        discount: 50,
        totalAmount: 550,
        status: 'Completed',
      ),
      AmbulanceBooking(
        requestId: '2',
        userId: 'user124',  // Add a valid userId
        vendorId: 'vendor124',  // Add a valid vendorId
        customerName: 'Jane Smith',
        phoneNumber: '0987654321',  // Add a valid phoneNumber
        pickupLocation: 'Address 3',
        dropLocation: 'Address 4',
        urgency: 'Non-Urgent',
        vehicleType: 'ALS',
        numberOfPersons: 1,
        requiredDateTime: DateTime.now(),
        fees: 700,
        gst: 18,
        discount: 70,
        totalAmount: 650,
        status: 'Pending Payment',
      ),
      // Add more sample bookings as needed
    ];
    notifyListeners();
  }
}
