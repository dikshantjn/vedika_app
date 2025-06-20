import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingHistoryViewModel.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceBookingHistoryScreen extends StatefulWidget {
  @override
  _AmbulanceBookingHistoryScreenState createState() => _AmbulanceBookingHistoryScreenState();
}

class _AmbulanceBookingHistoryScreenState extends State<AmbulanceBookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AmbulanceBookingHistoryViewModel>(context, listen: false).fetchBookingHistory();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<AmbulanceBookingHistoryViewModel>(context, listen: false).fetchBookingHistory();
  }

  void _showBookingDetails(BuildContext context, AmbulanceBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsBottomSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AmbulanceBookingHistoryViewModel>(
          builder: (context, viewModel, child) {
            final bookingHistory = viewModel.bookingHistory;
            final isLoading = viewModel.isLoading;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: bookingHistory.isEmpty
                  ? isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView(
                          children: [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                "No booking history found.",
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        )
                  : ListView.builder(
                      itemCount: bookingHistory.length,
                      itemBuilder: (context, index) {
                        final booking = bookingHistory[index];
                        return GestureDetector(
                          onTap: () => _showBookingDetails(context, booking),
                          child: _buildBookingCard(context, booking),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, AmbulanceBooking booking) {
    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(booking.requiredDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Customer name & status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.user.name!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildStatusChip(booking.status),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup to Drop location
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${booking.pickupLocation} → ${booking.dropLocation}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Vehicle and Distance (if available)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Vehicle: ${booking.vehicleType}",
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (booking.totalDistance != null)
                Expanded(
                  flex: 1,
                  child: Text(
                    "Distance: ${booking.totalDistance.toStringAsFixed(1)} km",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Total Amount and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Total: ₹${booking.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'ongoing':
        chipColor = Colors.orange;
        break;
      case 'pending':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _BookingDetailsBottomSheet extends StatelessWidget {
  final AmbulanceBooking booking;

  const _BookingDetailsBottomSheet({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(booking.requiredDateTime);
    final viewModel = Provider.of<AmbulanceBookingHistoryViewModel>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(height: 20),

          // Customer Details Section
          _buildDetailSection(
            'Customer Information',
            [
              _buildDetailRow('Name', booking.user.name ?? 'N/A'),
              _buildDetailRow('Phone', booking.user.phoneNumber ?? 'N/A'),
              _buildDetailRow('Booking ID', booking.requestId),
            ],
          ),
          SizedBox(height: 20),

          // Journey Details Section
          _buildDetailSection(
            'Journey Details',
            [
              _buildDetailRow('Vehicle Type', booking.vehicleType),
              _buildDetailRow('Pickup', booking.pickupLocation),
              _buildDetailRow('Drop', booking.dropLocation),
              if (booking.totalDistance != null)
                _buildDetailRow('Distance', '${booking.totalDistance.toStringAsFixed(1)} km'),
              _buildDetailRow('Date & Time', formattedDate),
            ],
          ),
          SizedBox(height: 20),

          // Payment Details Section
          _buildDetailSection(
            'Payment Details',
            [
              _buildDetailRow('Base Fare', '₹${booking.baseCharge.toStringAsFixed(2)}'),

              _buildDetailRow('Total Amount', '₹${booking.totalAmount.toStringAsFixed(2)}', isHighlighted: true),
            ],
          ),
          SizedBox(height: 24),

          // Download Invoice Button (only for completed bookings)
          if (booking.status.toLowerCase() == 'completed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isGeneratingInvoiceForBooking(booking.requestId)
                    ? null
                    : () async {
                        try {
                          await viewModel.generateInvoice(booking.requestId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invoice downloaded successfully!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to generate invoice')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewModel.isGeneratingInvoiceForBooking(booking.requestId)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Generating Invoice...',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      )
                    : Text(
                        'Download Invoice',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green[700] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
