import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/AppointmentViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/ProcessAppointmentScreen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch appointments when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
      viewModel.fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: HospitalVendorColorPalette.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading bed bookings...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.fetchAppointments(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HospitalVendorColorPalette.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Remove the status filtering to show all appointments
          final bookings = viewModel.appointments;

          if (bookings.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bed_outlined,
                        size: 48,
                        color: HospitalVendorColorPalette.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Bed Bookings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HospitalVendorColorPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have no bed booking requests at the moment',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchAppointments();
            },
            color: HospitalVendorColorPalette.primaryBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BedBookingCard(
                  key: ValueKey(booking.bedBookingId),
                  booking: booking,
                  viewModel: viewModel,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BedBookingCard extends StatelessWidget {
  final BedBooking booking;
  final AppointmentViewModel viewModel;

  const BedBookingCard({
    Key? key,
    required this.booking,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status.toLowerCase() == 'pending';
    final isWaitingForPayment = booking.status == 'WaitingForPayment';
    final isCompleted = booking.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      booking.user.name?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: HospitalVendorColorPalette.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.user.name ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: HospitalVendorColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking #${booking.bedBookingId?.substring(0, 8) ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
                    color: isPending
                        ? HospitalVendorColorPalette.warningYellow.withOpacity(0.1)
                        : isWaitingForPayment
                            ? HospitalVendorColorPalette.primaryBlue.withOpacity(0.1)
                            : HospitalVendorColorPalette.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: isPending
                          ? HospitalVendorColorPalette.warningYellow
                          : isWaitingForPayment
                              ? HospitalVendorColorPalette.primaryBlue
                              : HospitalVendorColorPalette.successGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.bed,
                  'Bed Type',
                  booking.bedType,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date & Time',
                  '${booking.bookingDate.toString().split(' ')[0]} - ${booking.timeSlot}',
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.phone,
                  'Contact',
                  booking.user.phoneNumber,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.location_on,
                  'Location',
                  '${booking.hospital.address}, ${booking.hospital.city}',
                  Colors.red,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${booking.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: HospitalVendorColorPalette.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    if (!isCompleted)
                      ElevatedButton(
                        onPressed: isPending
                            ? () => viewModel.acceptAppointment(booking.bedBookingId!)
                            : isWaitingForPayment
                                ? () => viewModel.notifyUserPayment(booking.bedBookingId!)
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProcessAppointmentScreen(
                                          booking: booking,
                                        ),
                                      ),
                                    );
                                  },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPending
                              ? HospitalVendorColorPalette.successGreen
                              : isWaitingForPayment
                                  ? HospitalVendorColorPalette.warningYellow
                                  : HospitalVendorColorPalette.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPending
                                  ? Icons.check
                                  : isWaitingForPayment
                                      ? Icons.notifications
                                      : Icons.arrow_forward,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPending
                                  ? 'Accept'
                                  : isWaitingForPayment
                                      ? 'Notify Payment'
                                      : 'Process',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HospitalVendorColorPalette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 