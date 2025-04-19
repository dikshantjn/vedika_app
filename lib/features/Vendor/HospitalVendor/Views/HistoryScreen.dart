import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/AppointmentViewModel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch appointments when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentViewModel>().fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Bed Booking History'),
        backgroundColor: HospitalVendorColorPalette.primaryBlue,
        foregroundColor: HospitalVendorColorPalette.textInverse,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: HospitalVendorColorPalette.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: const TextStyle(
                      color: HospitalVendorColorPalette.errorRed,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchAppointments(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HospitalVendorColorPalette.primaryBlue,
                      foregroundColor: HospitalVendorColorPalette.textInverse,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final bookings = viewModel.appointments;
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    color: HospitalVendorColorPalette.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No booking history found',
                    style: TextStyle(
                      color: HospitalVendorColorPalette.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: HospitalVendorColorPalette.borderLight,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to booking details screen
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  booking.user.name?[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    color: HospitalVendorColorPalette.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.user.name ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: HospitalVendorColorPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Booking #${booking.bedBookingId?.substring(0, 8) ?? 'N/A'}',
                                    style: TextStyle(
                                      color: HospitalVendorColorPalette.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: booking.paymentStatus == 'completed'
                                    ? HospitalVendorColorPalette.successGreen.withOpacity(0.1)
                                    : HospitalVendorColorPalette.warningYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    booking.paymentStatus == 'completed'
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    size: 16,
                                    color: booking.paymentStatus == 'completed'
                                        ? HospitalVendorColorPalette.successGreen
                                        : HospitalVendorColorPalette.warningYellow,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: booking.paymentStatus == 'completed'
                                          ? HospitalVendorColorPalette.successGreen
                                          : HospitalVendorColorPalette.warningYellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoItem(
                              Icons.bed,
                              'Bed Type',
                              booking.bedType,
                            ),
                            const SizedBox(width: 16),
                            _buildInfoItem(
                              Icons.access_time,
                              'Date',
                              '${booking.bookingDate.toString().split(' ')[0]} - ${booking.timeSlot}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${booking.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HospitalVendorColorPalette.textPrimary,
                              ),
                            ),
                            Text(
                              '${booking.hospital.name}, ${booking.hospital.city}',
                              style: TextStyle(
                                color: HospitalVendorColorPalette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: HospitalVendorColorPalette.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: HospitalVendorColorPalette.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: HospitalVendorColorPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 