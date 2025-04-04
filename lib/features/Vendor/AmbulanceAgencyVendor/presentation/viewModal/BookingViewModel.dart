import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceBooking.dart';

class BookingViewModel extends ChangeNotifier {
  List<Booking> _bookings = []; // List to store booking requests

  List<Booking> get bookings => _bookings;

  // Method to add a new booking
  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  // Method to accept a booking request
  void acceptBooking(int index) {
    _bookings[index].isAccepted = true;
    notifyListeners();
  }

  // Method to decline a booking request
  void declineBooking(int index) {
    _bookings.removeAt(index);
    notifyListeners();
  }
}
