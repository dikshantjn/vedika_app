import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/BookingRequest/BookingDetailsCard.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/BookingRequest/ServiceDetailsCard.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/BookingRequest/ServiceDetailsDialog.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class ProcessBookingScreen extends StatefulWidget {
  final String requestId;

  const ProcessBookingScreen({super.key, required this.requestId});

  @override
  State<ProcessBookingScreen> createState() => _ProcessBookingScreenState();
}

class _ProcessBookingScreenState extends State<ProcessBookingScreen> {
  late AmbulanceBooking booking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false);
      viewModel.fetchVehicleTypes(); // ✅ This is safe
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context);
    booking = viewModel.bookingRequests.firstWhere((b) => b.requestId == widget.requestId);

    final isDetailsFilled = booking.pickupLocation.isNotEmpty &&
        booking.dropLocation.isNotEmpty &&
        booking.vehicleType.isNotEmpty &&
        booking.totalAmount != 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Process Booking'),
        backgroundColor: Colors.cyan,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.fetchPendingBookings(); // 🔁 Re-fetch booking requests
          await viewModel.fetchVehicleTypes(); // 🔁 Re-fetch service/vehicle types
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Booking Details", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              BookingDetailsCard(booking: booking),

              const SizedBox(height: 24),
              Text("Service Details", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ServiceDetailsCard(booking: booking, isFilled: isDetailsFilled),

              const SizedBox(height: 32),

              // Booking Status Menu with Toggle buttons displayed one by one
              Text("Change Booking Status", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Column(
                children: _buildStatusWidgets(viewModel),
              ),

              const SizedBox(height: 32),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    viewModel.prefillServiceDetails(
                      pickup: booking.pickupLocation,
                      drop: booking.dropLocation,
                      distance: booking.totalDistance,
                      costPerKm: booking.costPerKm,
                      baseCharge: booking.baseCharge,
                      vehicleType: booking.vehicleType,
                    );

                    showDialog(
                      context: context,
                      builder: (_) => ServiceDetailsDialog(viewModel: viewModel, requestId: widget.requestId),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.cyan, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    foregroundColor: Colors.cyan,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: Text(
                    isDetailsFilled ? "Edit Service Details" : "Add Service Details",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to return status widgets dynamically
  List<Widget> _buildStatusWidgets(AmbulanceBookingRequestViewModel viewModel) {
    List<Widget> statusWidgets = [];

    if (booking.status == "PaymentCompleted") {
      statusWidgets.add(_buildStatusBox("On-the-way", "OnTheWay", viewModel));
    }

    if (booking.status == "OnTheWay") {
      statusWidgets.add(_buildStatusBox("Picked-up", "PickedUp", viewModel));
    }

    if (booking.status == "PickedUp") {
      statusWidgets.add(_buildStatusBox("Completed", "Completed", viewModel));
    }

    return statusWidgets;
  }

  Widget _buildStatusBox(String label, String status, AmbulanceBookingRequestViewModel viewModel) {
    bool isActive = booking.status == status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Colors.cyan[100] : Colors.grey[300],
        border: Border.all(color: isActive ? Colors.cyan : Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isActive ? Colors.cyan : Colors.black)),
          Switch(
            value: isActive,
            onChanged: (value) {
              if (value) {
                viewModel.updateBookingStatus(widget.requestId, status);
              }
            },
          ),
        ],
      ),
    );
  }
}
