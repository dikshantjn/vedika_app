import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/BookingViewModel.dart';

class BookingRequestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookingViewModel = Provider.of<BookingViewModel>(context);

    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: bookingViewModel.bookings.length,
              itemBuilder: (context, index) {
                final booking = bookingViewModel.bookings[index];
                return ListTile(
                  title: Text(booking.userName),
                  subtitle: Text(booking.vehicleType),
                  trailing: IconButton(
                    icon: Icon(booking.isAccepted ? Icons.check : Icons.remove),
                    onPressed: () {
                      booking.isAccepted
                          ? bookingViewModel.declineBooking(index)
                          : bookingViewModel.acceptBooking(index);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
