import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BloodBankOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/blood_bank_invoice_pdf.dart';
import 'package:intl/intl.dart';

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
          onTap: () => _showBookingBottomSheet(context, booking),
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

  void _showBookingBottomSheet(BuildContext context, BloodBankBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BloodBankBookingBottomSheet(booking: booking),
    );
  }
}

class BloodBankBookingBottomSheet extends StatefulWidget {
  final BloodBankBooking booking;

  const BloodBankBookingBottomSheet({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<BloodBankBookingBottomSheet> createState() => _BloodBankBookingBottomSheetState();
}

class _BloodBankBookingBottomSheetState extends State<BloodBankBookingBottomSheet> {
  bool _isGeneratingInvoice = false;

  Future<void> _generateInvoice() async {
    setState(() {
      _isGeneratingInvoice = true;
    });

    try {
      await generateAndDownloadBloodBankInvoicePDF(widget.booking);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingInvoice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Agency Details
                  _buildDetailCard(
                    title: 'Blood Bank Agency',
                    icon: Icons.local_hospital,
                    iconColor: Colors.red,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.agency?.agencyName ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.booking.agency?.completeAddress ?? ''}, ${widget.booking.agency?.city ?? ''}, ${widget.booking.agency?.state ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (widget.booking.agency?.phoneNumber != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Contact: ${widget.booking.agency?.phoneNumber}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Booking Details
                  _buildDetailCard(
                    title: 'Booking Information',
                    icon: Icons.event_note,
                    iconColor: Colors.blue,
                    child: Column(
                      children: [
                        _buildInfoRow('Blood Group', widget.booking.bloodType.isNotEmpty ? widget.booking.bloodType[0] : 'N/A'),
                        _buildInfoRow('Units Required', '${widget.booking.units} Units'),
                        _buildInfoRow('Delivery Type', widget.booking.deliveryType ?? 'N/A'),
                        _buildInfoRow('Booking Date', DateFormat('dd MMM yyyy').format(widget.booking.createdAt)),
                        _buildInfoRow('Status', widget.booking.status ?? 'N/A'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recipient Details
                  _buildDetailCard(
                    title: 'Recipient Information',
                    icon: Icons.person,
                    iconColor: Colors.green,
                    child: Column(
                      children: [
                        _buildInfoRow('Name', widget.booking.user?.name ?? 'N/A'),
                        _buildInfoRow('Phone', widget.booking.user?.phoneNumber ?? 'N/A'),
                        if (widget.booking.user?.emailId != null)
                          _buildInfoRow('Email', widget.booking.user?.emailId ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cost Details
                  _buildDetailCard(
                    title: 'Cost Details',
                    icon: Icons.receipt_long,
                    iconColor: Colors.orange,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Price per Unit',
                          '₹${(widget.booking.totalAmount / (widget.booking.units > 0 ? widget.booking.units : 1)).toStringAsFixed(2)}',
                        ),
                        _buildInfoRow('Number of Units', '${widget.booking.units}'),
                        if ((widget.booking.deliveryFees) > 0)
                          _buildInfoRow('Delivery Fee', '₹${widget.booking.deliveryFees.toStringAsFixed(2)}'),
                        if ((widget.booking.gst) > 0)
                          _buildInfoRow('GST (${widget.booking.gst}%)', '₹${((widget.booking.totalAmount + widget.booking.deliveryFees) * widget.booking.gst / 100).toStringAsFixed(2)}'),
                        if ((widget.booking.discount) > 0)
                          _buildInfoRow('Discount', '-₹${widget.booking.discount.toStringAsFixed(2)}'),
                        const Divider(),
                        _buildInfoRow(
                          'Total Amount',
                          '₹${widget.booking.totalAmount.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Payment Status',
                          widget.booking.paymentStatus,
                          isTotal: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Download Invoice Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingInvoice ? null : _generateInvoice,
                      icon: _isGeneratingInvoice
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.download, color: Colors.white),
                      label: Text(
                        _isGeneratingInvoice ? 'Generating Invoice...' : 'Download Invoice',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}