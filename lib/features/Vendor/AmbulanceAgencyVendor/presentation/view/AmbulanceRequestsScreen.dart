import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';

class AmbulanceRequestsScreen extends StatefulWidget {
  @override
  _AmbulanceRequestsScreenState createState() =>
      _AmbulanceRequestsScreenState();
}

class _AmbulanceRequestsScreenState extends State<AmbulanceRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the booking requests after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the instance of AmbulanceBookingRequestViewModel and fetch data
      Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false)
          .fetchBookingRequests();
    });
  }

  // Refresh function to refresh the booking requests
  Future<void> _onRefresh() async {
    // Fetch the booking requests again when pull to refresh is triggered
    await Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false)
        .fetchBookingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AmbulanceBookingRequestViewModel>(
          builder: (context, viewModel, child) {
            final bookingRequests = viewModel.bookingRequests;
            if (bookingRequests.isEmpty) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh, // Call the refresh function when user pulls to refresh
              child: ListView.builder(
                itemCount: bookingRequests.length,
                itemBuilder: (context, index) {
                  return ChangeNotifierProvider.value(
                    value: bookingRequests[index],
                    child: _buildBookingRequestCard(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingRequestCard() {
    return Consumer<AmbulanceBookingRequestViewModel>(
      builder: (context, viewModel, child) {
        Color statusBgColor;
        if (viewModel.isAccepted) {
          statusBgColor = Colors.green.shade100;
        } else {
          statusBgColor = Colors.orange.shade100;
        }

        // Parse the time into a DateTime object
        DateTime bookingDateTime = DateTime.parse(viewModel.time); // Assuming `viewModel.time` is a valid date string

        // Format the DateTime object
        String formattedTime = DateFormat('d MMM yyyy, h:mm a').format(bookingDateTime);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Customer: ${viewModel.customerName}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.status,
                      style: TextStyle(
                        fontSize: 16,
                        color: viewModel.isAccepted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Time: $formattedTime",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      viewModel.toggleRequestStatus();
                    },
                    child: Text(
                      viewModel.isAccepted ? 'Proceed Request' : 'Accept Request',
                      style: TextStyle(color: Colors.cyan),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.cyan),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      minimumSize: Size(0, 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
