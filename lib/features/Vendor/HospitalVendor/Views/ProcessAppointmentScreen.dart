import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/ProcessAppointmentViewModel.dart';

class ProcessAppointmentScreen extends StatefulWidget {
  final BedBooking booking;

  const ProcessAppointmentScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<ProcessAppointmentScreen> createState() => _ProcessAppointmentScreenState();
}

class _ProcessAppointmentScreenState extends State<ProcessAppointmentScreen> {
  @override
  void initState() {
    super.initState();
    // Set the current booking ID in the ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProcessAppointmentViewModel>().setCurrentBookingId(widget.booking.bedBookingId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Process Bed Booking'),
        backgroundColor: HospitalVendorColorPalette.primaryBlue,
        foregroundColor: HospitalVendorColorPalette.textInverse,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ProcessAppointmentViewModel>(
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
                    onPressed: () => viewModel.resetState(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Details Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: HospitalVendorColorPalette.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: HospitalVendorColorPalette.primaryBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.booking.user.name?[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    color: HospitalVendorColorPalette.textInverse,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
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
                                    widget.booking.user.name ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: HospitalVendorColorPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Booking #${widget.booking.bedBookingId?.substring(0, 8) ?? 'N/A'}',
                                      style: TextStyle(
                                        color: HospitalVendorColorPalette.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          Icons.phone,
                          'Contact Number',
                          widget.booking.user.phoneNumber,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on,
                          'Hospital',
                          '${widget.booking.hospital.name}, ${widget.booking.hospital.city}',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.bed,
                          'Bed Type',
                          widget.booking.bedType,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.access_time,
                          'Booking Date',
                          '${widget.booking.bookingDate.toString().split(' ')[0]} - ${widget.booking.timeSlot}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Payment Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: HospitalVendorColorPalette.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HospitalVendorColorPalette.textPrimary,
                          ),
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
                                    color: HospitalVendorColorPalette.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${widget.booking.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: HospitalVendorColorPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: (viewModel.isPaymentCompleted || widget.booking.paymentStatus.toLowerCase() == 'paid')
                                    ? HospitalVendorColorPalette.successGreen.withOpacity(0.1)
                                    : HospitalVendorColorPalette.warningYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    (viewModel.isPaymentCompleted || widget.booking.paymentStatus.toLowerCase() == 'paid')
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    size: 20,
                                    color: (viewModel.isPaymentCompleted || widget.booking.paymentStatus.toLowerCase() == 'paid')
                                        ? HospitalVendorColorPalette.successGreen
                                        : HospitalVendorColorPalette.warningYellow,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    (viewModel.isPaymentCompleted || widget.booking.paymentStatus.toLowerCase() == 'paid')
                                        ? 'COMPLETED'
                                        : widget.booking.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: (viewModel.isPaymentCompleted || widget.booking.paymentStatus.toLowerCase() == 'paid')
                                          ? HospitalVendorColorPalette.successGreen
                                          : HospitalVendorColorPalette.warningYellow,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Notify User Button
                if (!viewModel.isPaymentCompleted && widget.booking.paymentStatus.toLowerCase() != 'paid')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isLoading || viewModel.isNotifyingPayment
                          ? null
                          : () => viewModel.notifyPayment(widget.booking.bedBookingId!),
                      icon: viewModel.isLoading || viewModel.isNotifyingPayment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: HospitalVendorColorPalette.textInverse,
                              ),
                            )
                          : const Icon(Icons.notifications, size: 20),
                      label: Text(
                        viewModel.isNotifyingPayment
                            ? 'Waiting for Payment...'
                            : viewModel.isLoading 
                                ? 'Sending...' 
                                : widget.booking.status == 'WaitingForPayment'
                                    ? 'Notify Again About Payment'
                                    : 'Notify User About Payment',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: viewModel.isNotifyingPayment
                            ? HospitalVendorColorPalette.warningYellow
                            : widget.booking.status == 'WaitingForPayment'
                                ? HospitalVendorColorPalette.warningYellow
                                : HospitalVendorColorPalette.primaryBlue,
                        foregroundColor: HospitalVendorColorPalette.textInverse,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: HospitalVendorColorPalette.primaryBlue,
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
                  color: HospitalVendorColorPalette.textSecondary,
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
    );
  }
} 