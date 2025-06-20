import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewModel/BloodBankBookingViewModel.dart';
import '../../data/model/BloodBankBooking.dart';
import '../../../../../core/auth/data/models/UserModel.dart';
import 'ProcessBloodBankBookingScreen.dart';
import '../../../../../features/orderHistory/data/reports/blood_bank_invoice_pdf.dart';

class BloodBankBookingScreen extends StatefulWidget {
  const BloodBankBookingScreen({Key? key}) : super(key: key);

  @override
  State<BloodBankBookingScreen> createState() => _BloodBankBookingScreenState();
}

class _BloodBankBookingScreenState extends State<BloodBankBookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodBankBookingViewModel>().loadBookings();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<BloodBankBookingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadBookings(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New bookings will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                child: SafeArea(
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(
                        child: Text(
                          'Confirmed (${viewModel.confirmedBookings.length})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Completed (${viewModel.completedBookings.length})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Cancelled (${viewModel.cancelledBookings.length})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.loadBookings();
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(viewModel.confirmedBookings, viewModel),
                      _buildBookingsList(viewModel.completedBookings, viewModel),
                      _buildBookingsList(viewModel.cancelledBookings, viewModel),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<BloodBankBooking> bookings, BloodBankBookingViewModel viewModel) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIconForTab(_tabController.index),
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessageForTab(_tabController.index),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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
        final user = booking.user;
        final bloodRequestDetails = viewModel.getBloodRequestDetailsForBooking(booking.bookingId!);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              if (_tabController.index == 1) { // Completed tab
                _showBookingDetailsBottomSheet(context, booking, user, bloodRequestDetails);
              }
            },
            child: _buildBookingCard(booking, user, bloodRequestDetails),
          ),
        );
      },
    );
  }

  void _showBookingDetailsBottomSheet(BuildContext context, BloodBankBooking booking, UserModel user, Map<String, dynamic>? bloodRequestDetails) {
    bool isGeneratingInvoice = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.bloodtype,
                              color: Colors.purple[700],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blood Bank Booking',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '#${booking.bookingId?.substring(0, 8) ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(booking.status),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Booking Details Section
                      _buildBottomSheetSection(
                        'Booking Details',
                        Icons.event_note,
                        [
                          _buildDetailRow('Date', DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt)),
                          _buildDetailRow('Blood Type', bloodRequestDetails?['bloodTypes']?.join(", ") ?? 'N/A'),
                          _buildDetailRow('Units', '${bloodRequestDetails?['units'] ?? 'N/A'} Units'),
                          _buildDetailRow('Delivery Type', booking.deliveryType ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Patient Details Section
                      _buildBottomSheetSection(
                        'Patient Details',
                        Icons.person,
                        [
                          _buildDetailRow('Name', user.name ?? 'N/A'),
                          _buildDetailRow('Phone', user.phoneNumber ?? 'N/A'),
                          if (user.emailId != null && user.emailId!.isNotEmpty)
                            _buildDetailRow('Email', user.emailId!),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Agency Details Section
                      _buildBottomSheetSection(
                        'Blood Bank Details',
                        Icons.local_hospital,
                        [
                          _buildDetailRow('Name', booking.agency?.agencyName ?? 'N/A'),
                          _buildDetailRow('Address', '${booking.agency?.completeAddress ?? ''}, ${booking.agency?.city ?? ''}, ${booking.agency?.state ?? ''}'),
                          _buildDetailRow('Contact', booking.agency?.phoneNumber ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Payment Details Section
                      _buildBottomSheetSection(
                        'Payment Details',
                        Icons.payment,
                        [
                          _buildDetailRow('Status', booking.paymentStatus),
                          _buildDetailRow('Amount', '₹${booking.totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Download Invoice Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isGeneratingInvoice
                              ? null
                              : () async {
                                  setState(() => isGeneratingInvoice = true);
                                  try {
                                    await generateAndDownloadBloodBankInvoicePDF(booking);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Invoice downloaded successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to generate invoice: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isGeneratingInvoice = false);
                                    }
                                  }
                                },
                          icon: isGeneratingInvoice
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(
                            isGeneratingInvoice ? 'Generating Invoice...' : 'Download Invoice',
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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

  Widget _buildBottomSheetSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BloodBankBooking booking, UserModel user, Map<String, dynamic>? bloodRequestDetails) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple[100]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.bloodtype,
                        color: Colors.purple[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Booking #${booking.bookingId?.substring(0, 8) ?? 'N/A'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.purple[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildStatusChip(booking.status),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  _buildInfoRow(Icons.person, 'Patient', user.name!),
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                    _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber!),
                ],
                const SizedBox(height: 16),
                if (bloodRequestDetails != null) ...[
                  _buildInfoRow(Icons.bloodtype, 'Blood Type', bloodRequestDetails['bloodTypes'].join(", ")),
                  _buildInfoRow(Icons.numbers, 'Units Required', bloodRequestDetails['units'].toString()),
                ],
                const SizedBox(height: 16),
                if (booking.status.toLowerCase() != 'cancelled' && booking.status.toLowerCase() != 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to ProcessBloodBankBookingScreen with the entire booking object
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProcessBloodBankBookingScreen(
                              booking: booking,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.medical_services),
                      label: const Text('Process Confirm Request'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple[700],
                        side: BorderSide(color: Colors.purple[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.purple[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: _getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEmptyIconForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Icons.check_circle_outline;
      case 1:
        return Icons.done_all;
      case 2:
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  String _getEmptyMessageForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'No confirmed bookings';
      case 1:
        return 'No completed bookings';
      case 2:
        return 'No cancelled bookings';
      default:
        return 'No bookings found';
    }
  }
} 