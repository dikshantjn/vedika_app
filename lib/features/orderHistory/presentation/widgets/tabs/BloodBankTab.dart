import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BloodBankOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomBloodBankOrderInfoDialog.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';

class BloodBankTab extends StatefulWidget {
  @override
  _BloodBankTabState createState() => _BloodBankTabState();
}

class _BloodBankTabState extends State<BloodBankTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<BloodBankOrderViewModel>(context, listen: false).fetchCompletedBookings());
  }

  Future<void> _refreshBookings() async {
    await Provider.of<BloodBankOrderViewModel>(context, listen: false).fetchCompletedBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodBankOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.bookings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = viewModel.bookings;
        if (bookings.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshBookings,
            child: ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text(
                      "No blood bank bookings found.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshBookings,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingItem(context, bookings[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingItem(BuildContext context, BloodBankBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showBookingDetails(context, booking),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.agency?.agencyName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.bloodtype,
                      label: '${booking.units} Units',
                      color: Colors.red.shade100,
                      textColor: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.local_shipping,
                      label: booking.deliveryType ?? 'N/A',
                      color: Colors.blue.shade100,
                      textColor: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price per Unit',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${(booking.totalAmount / (booking.units > 0 ? booking.units : 1)).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${booking.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
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
      case 'cancelled':
        chipColor = Colors.red;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12.0),
      ),
      backgroundColor: chipColor,
      shape: const StadiumBorder(),
    );
  }

  void _showBookingDetails(BuildContext context, BloodBankBooking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomBloodBankOrderInfoDialog(booking: booking);
      },
    );
  }
}