import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewModel/BloodBankBookingViewModel.dart';
import '../../data/model/BloodBankBooking.dart';
import '../../../../../core/auth/data/models/UserModel.dart';
import 'ProcessBloodBankBookingScreen.dart';

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
          child: _buildBookingCard(booking, user, bloodRequestDetails),
        );
      },
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.bloodtype,
                        color: Colors.purple[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Booking #${booking.bookingId?.substring(0, 8) ?? 'N/A'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.purple[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(booking.status),
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