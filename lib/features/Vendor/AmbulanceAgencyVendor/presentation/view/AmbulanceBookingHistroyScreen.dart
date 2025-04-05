import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingHistoryViewModel.dart';

class AmbulanceBookingHistoryScreen extends StatefulWidget {
  @override
  _AmbulanceBookingHistoryScreenState createState() => _AmbulanceBookingHistoryScreenState();
}

class _AmbulanceBookingHistoryScreenState extends State<AmbulanceBookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch booking history when the screen is initialized
    Future.microtask(() {
      Provider.of<AmbulanceBookingHistoryViewModel>(context, listen: false).fetchBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AmbulanceBookingHistoryViewModel>(
          builder: (context, viewModel, child) {
            final bookingHistory = viewModel.bookingHistory;

            // Show loading indicator while fetching data
            if (bookingHistory.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: bookingHistory.length,
              itemBuilder: (context, index) {
                final booking = bookingHistory[index];
                return _buildBookingCard(booking);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(AmbulanceBooking booking) {
    // Check if the requiredDateTime is in a valid format and then parse it
    DateTime bookingDateTime;
    try {
      // Assuming requiredDateTime is a valid ISO 8601 string (e.g., "2025-04-05T10:30:00")
    } catch (e) {
      // If parsing fails, fallback to the current date/time or handle the error
      bookingDateTime = DateTime.now();
    }

    // Formatting the date and time
    String formattedTime = DateFormat('d MMM yyyy, h:mm a').format(booking.requiredDateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50, // Lighter background for the card
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking ID and Status in one row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Booking ID
              Text(
                "Booking ID: ${booking.requestId}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Roboto', // Modern font
                ),
              ),
              // Status on the right
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: booking.status == 'Completed' ? Colors.green.shade100 : Colors.orange.shade100, // Lighter status color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Roboto', // Modern font
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Customer Info
          Text(
            "Customer: ${booking.customerName}",
            style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'Roboto'),
          ),
          Text(
            "Location: ${booking.pickupLocation} to ${booking.dropLocation}",
            style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'Roboto'),
          ),
          const SizedBox(height: 12),
          // Urgency and Vehicle Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Urgency: ${booking.urgency}",
                style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'Roboto'),
              ),
              Text(
                "Vehicle: ${booking.vehicleType}",
                style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'Roboto'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Total Amount
          Text(
            "Total Amount: ₹${booking.totalAmount}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade600,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          // Date and Time in formatted style
          Text(
            "Date/Time: $formattedTime",
            style: TextStyle(fontSize: 14, color: Colors.black45, fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }
}
