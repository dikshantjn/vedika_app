import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/ProcessBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceRequestsScreen extends StatefulWidget {
  @override
  _AmbulanceRequestsScreenState createState() => _AmbulanceRequestsScreenState();
}

class _AmbulanceRequestsScreenState extends State<AmbulanceRequestsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false)
          .fetchPendingBookings();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false)
        .fetchPendingBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AmbulanceBookingRequestViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.bookingRequests.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading bookings...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final bookingRequests = viewModel.bookingRequests;

            if (bookingRequests.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.airport_shuttle_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No pending bookings',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    itemCount: bookingRequests.length,
                    itemBuilder: (context, index) {
                      final booking = bookingRequests[index];
                      return _buildBookingRequestCard(booking);
                    },
                  ),
                ),
                if (viewModel.isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade200),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingRequestCard(AmbulanceBooking booking) {
    final formattedTime = DateFormat('d MMM yyyy, h:mm a').format(booking.timestamp);

    // Check if the status is "pending"
    final isPending = booking.status.toLowerCase() == "pending";

    // Show "Proceed Request" for any status other than "pending"
    final showProceedButton = !isPending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Name
          Text(
            "Customer Name: ${booking.user.name}",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.visible, // allow wrapping if needed
          ),
          const SizedBox(height: 6),

          // Mobile Number
          Text(
            "Mob No: ${booking.user.phoneNumber}",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 6),

          // Time
          Text(
            "Time: $formattedTime",
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 12),

          // Status and Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.shade100
                      : Colors.green.shade100, // Other statuses are considered accepted
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPending ? Colors.orange : Colors.green, // Treat non-pending statuses as accepted
                  ),
                ),
              ),

              // Action Button
              OutlinedButton(
                onPressed: () async {
                  final viewModel =
                  Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false);

                  if (!isPending) {
                    // Navigate to the ProcessBookingScreen if status is not pending
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProcessBookingScreen(requestId: booking.requestId),
                        ),
                      );
                    }
                  } else {
                    // If the status is "pending", accept the request
                    await viewModel.toggleRequestStatus(booking.requestId);

                    if (context.mounted) {
                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Success!',
                          message: 'Booking request accepted successfully.',
                          contentType: ContentType.success,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                },
                child: Text(
                  showProceedButton ? 'Proceed Request' : 'Accept Request',
                  style: const TextStyle(color: Color(0xFF38A3A5)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF38A3A5)),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  minimumSize: const Size(0, 30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
