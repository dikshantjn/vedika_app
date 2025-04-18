import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/Appointment.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/ProcessAppointmentViewModel.dart';

class ProcessAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const ProcessAppointmentScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<ProcessAppointmentScreen> createState() => _ProcessAppointmentScreenState();
}

class _ProcessAppointmentScreenState extends State<ProcessAppointmentScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the view model state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProcessAppointmentViewModel>().resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Process Appointment'),
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
                                  widget.appointment.patientName[0].toUpperCase(),
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
                                    widget.appointment.patientName,
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
                                      'Appointment #${widget.appointment.id}',
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
                          widget.appointment.phoneNumber,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on,
                          'Address',
                          widget.appointment.address,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.access_time,
                          'Appointment Time',
                          widget.appointment.appointmentTime,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Health Records Section
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Health Records',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HospitalVendorColorPalette.textPrimary,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to health records screen
                              },
                              icon: const Icon(Icons.medical_services, size: 16),
                              label: const Text('View Records'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HospitalVendorColorPalette.secondaryTeal,
                                foregroundColor: HospitalVendorColorPalette.textInverse,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'View detailed health records and medical history of the patient.',
                          style: TextStyle(
                            color: HospitalVendorColorPalette.textSecondary,
                            fontSize: 14,
                          ),
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
                                  '₹${widget.appointment.amount}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: HospitalVendorColorPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (!viewModel.isPaymentCompleted)
                              ElevatedButton.icon(
                                onPressed: viewModel.isNotifyingPayment
                                    ? null
                                    : () => viewModel.notifyPayment(widget.appointment.id),
                                icon: viewModel.isNotifyingPayment
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: HospitalVendorColorPalette.textInverse,
                                        ),
                                      )
                                    : const Icon(Icons.payment, size: 16),
                                label: Text(
                                  viewModel.isNotifyingPayment ? 'Processing...' : 'Notify Payment',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HospitalVendorColorPalette.primaryBlue,
                                  foregroundColor: HospitalVendorColorPalette.textInverse,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: HospitalVendorColorPalette.successGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: HospitalVendorColorPalette.successGreen,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Payment Completed',
                                      style: TextStyle(
                                        color: HospitalVendorColorPalette.successGreen,
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
                // Complete Button
                if (viewModel.isPaymentCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isProcessing
                          ? null
                          : () => viewModel.completeAppointment(widget.appointment.id),
                      icon: viewModel.isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: HospitalVendorColorPalette.textInverse,
                              ),
                            )
                          : const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        viewModel.isProcessing ? 'Processing...' : 'Mark as Completed',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HospitalVendorColorPalette.successGreen,
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