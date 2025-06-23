import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/BookingRequest/BookingDetailsCard.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/BookingRequest/ServiceDetailsCard.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/ServiceDetailsScreen.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProcessBookingScreen extends StatefulWidget {
  final String requestId;

  const ProcessBookingScreen({super.key, required this.requestId});

  @override
  State<ProcessBookingScreen> createState() => _ProcessBookingScreenState();
}

class _ProcessBookingScreenState extends State<ProcessBookingScreen> {
  AmbulanceBooking? booking;
  String? selectedStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false);
      await viewModel.fetchVehicleTypes();
      await viewModel.fetchPendingBookings();
      
      // Initialize the booking
      final initialBooking = viewModel.bookingRequests
          .cast<AmbulanceBooking?>()
          .firstWhere(
            (b) => b?.requestId == widget.requestId,
            orElse: () => null,
          );
      
      if (mounted) {
        setState(() {
          booking = initialBooking;
          isLoading = false;
        });
      }

      // Add listener for payment completed status
      viewModel.addListener(() {
        if (mounted) {
          final updatedBooking = viewModel.bookingRequests
              .cast<AmbulanceBooking?>()
              .firstWhere(
                (b) => b?.requestId == widget.requestId,
                orElse: () => null,
              );
          
          if (updatedBooking != null && updatedBooking.status.toLowerCase() == 'paymentcompleted') {
            setState(() {
              booking = updatedBooking;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context, listen: false);
    viewModel.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceBookingRequestViewModel>(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Process Booking"),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.cyan,
          ),
        ),
      );
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Booking Status"),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
            "This booking has been completed.",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final isDetailsFilled = booking!.isPaymentBypassed
        ? booking!.bypassReason != null &&
          booking!.bypassReason!.isNotEmpty &&
          booking!.bypassApprovedBy != null &&
          booking!.bypassApprovedBy!.isNotEmpty
        : booking!.pickupLocation.isNotEmpty &&
        booking!.dropLocation.isNotEmpty &&
        booking!.vehicleType.isNotEmpty &&
        booking!.totalAmount != 0;

    final statusOptions = _getNextStatusOptions(booking!.status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Process Booking'),
        backgroundColor: Colors.cyan,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: Colors.cyan,
        onRefresh: () async {
          setState(() => isLoading = true);
          await viewModel.fetchPendingBookings();
          await viewModel.fetchVehicleTypes();
          
          final updatedBooking = viewModel.bookingRequests
              .cast<AmbulanceBooking?>()
              .firstWhere(
                (b) => b?.requestId == widget.requestId,
                orElse: () => null,
              );
          
          if (mounted) {
            setState(() {
              booking = updatedBooking;
              isLoading = false;
            });
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.bookmark_outline, color: Colors.cyan[700], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Booking Details",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: BookingDetailsCard(booking: booking!),
                ),
              ),

              const SizedBox(height: 24),
              
              // Service Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.medical_services_outlined, color: Colors.cyan[700], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Service Details",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan[700],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        viewModel.prefillServiceDetails(
                          pickup: booking!.pickupLocation,
                          drop: booking!.dropLocation,
                          distance: booking!.totalDistance,
                          costPerKm: booking!.costPerKm,
                          baseCharge: booking!.baseCharge,
                          vehicleType: booking!.vehicleType,
                        );
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsScreen(
                              viewModel: viewModel,
                              requestId: widget.requestId,
                            ),
                          ),
                        );
                        
                        if (result == true && mounted) {
                          try {
                            setState(() => isLoading = true);
                            await viewModel.fetchPendingBookings();
                            
                            final updatedBooking = viewModel.bookingRequests
                                .cast<AmbulanceBooking?>()
                                .firstWhere(
                                  (b) => b?.requestId == widget.requestId,
                                  orElse: () => null,
                                );
                            
                            if (mounted) {
                              if (updatedBooking != null) {
                                setState(() {
                                  booking = updatedBooking;
                                  isLoading = false;
                                });
                              } else {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text('Booking not found after update'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Error updating booking: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: Icon(
                        isDetailsFilled ? Icons.edit : Icons.add,
                        size: 20,
                        color: Colors.cyan[700],
                      ),
                      label: Text(
                        isDetailsFilled ? "Edit Details" : "Add Details",
                        style: TextStyle(color: Colors.cyan[700]),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.cyan[700]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ServiceDetailsCard(booking: booking!, isFilled: isDetailsFilled),
                ),
              ),

              const SizedBox(height: 24),
              
              // Status Update Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.update, color: Colors.cyan[700], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Update Status",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: statusOptions.isNotEmpty
                    ? DropdownButtonFormField<String>(
                      value: selectedStatus,
                        hint: Text("Select Status", style: TextStyle(color: Colors.grey[600])),
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
                        }
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.cyan),
                          ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      )
                    : Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "No further status updates available.",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
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
