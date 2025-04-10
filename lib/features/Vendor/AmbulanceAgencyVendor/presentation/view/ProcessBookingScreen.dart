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
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false);
      viewModel.fetchVehicleTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context);
    AmbulanceBooking? booking = viewModel.bookingRequests
        .cast<AmbulanceBooking?>()
        .firstWhere(
          (b) => b?.requestId == widget.requestId,
      orElse: () => null,
    );

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Booking Status"),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "This booking has been completed.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }


    final isDetailsFilled = booking.pickupLocation.isNotEmpty &&
        booking.dropLocation.isNotEmpty &&
        booking.vehicleType.isNotEmpty &&
        booking.totalAmount != 0;

    final statusOptions = _getNextStatusOptions(booking.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Process Booking'),
        backgroundColor: Colors.cyan,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.fetchPendingBookings();
          await viewModel.fetchVehicleTypes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              Text("Change Booking Status", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),

              if (statusOptions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      hint: const Text("Select Status"),
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status.value,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                          viewModel.updateBookingStatus(widget.requestId, value);

                          // Optional: Show a feedback message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Status updated to ${value.toString()}")),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                )
              else
                const Text("No further status updates available.", style: TextStyle(color: Colors.grey)),

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
                      builder: (_) => ServiceDetailsDialog(
                        viewModel: viewModel,
                        requestId: widget.requestId,
                      ),
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

  List<_StatusOption> _getNextStatusOptions(String currentStatus) {
    return [
      _StatusOption("OnTheWay", "On-the-way"),
      _StatusOption("PickedUp", "Picked-up"),
      _StatusOption("Completed", "Completed"),
    ];
  }

}

class _StatusOption {
  final String value;
  final String label;

  _StatusOption(this.value, this.label);
}
