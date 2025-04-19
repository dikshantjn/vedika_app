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
      backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading bed bookings...',
                    style: TextStyle(
                      color: HospitalVendorColorPalette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: HospitalVendorColorPalette.errorRed),
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

          // Remove the status filtering to show all appointments
          final bookings = viewModel.appointments;

          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bed_outlined,
                    size: 64,
                    color: HospitalVendorColorPalette.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bed bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: HospitalVendorColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchAppointments();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BedBookingCard(booking: booking, viewModel: viewModel);
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: HospitalVendorColorPalette.borderLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: HospitalVendorColorPalette.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      booking.user.name?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: HospitalVendorColorPalette.textInverse,
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${booking.bookingDate.toString().split(' ')[0]} - ${booking.timeSlot}',
                              style: TextStyle(
                                color: HospitalVendorColorPalette.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.bedType,
                              style: TextStyle(
                                color: HospitalVendorColorPalette.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPending 
                        ? HospitalVendorColorPalette.warningYellow.withOpacity(0.1)
                        : HospitalVendorColorPalette.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : 'ACCEPTED',
                    style: TextStyle(
                      color: isPending 
                          ? HospitalVendorColorPalette.warningYellow
                          : HospitalVendorColorPalette.successGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: HospitalVendorColorPalette.textSecondary),
                const SizedBox(width: 6),
                Text(
                  booking.user.phoneNumber,
                  style: TextStyle(
                    color: HospitalVendorColorPalette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: HospitalVendorColorPalette.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${booking.hospital.address}, ${booking.hospital.city}, ${booking.hospital.state}',
                    style: TextStyle(
                      color: HospitalVendorColorPalette.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${booking.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HospitalVendorColorPalette.primaryBlue,
                  ),
                ),
                ElevatedButton(
                  onPressed: isPending
                      ? () => viewModel.acceptAppointment(booking.bedBookingId!)
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
                        : HospitalVendorColorPalette.primaryBlue,
                    foregroundColor: HospitalVendorColorPalette.textInverse,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isPending ? 'Accept' : 'Process',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 