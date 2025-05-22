import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/ProcessBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Dashboard/AmbulanceAgencyAnalyticsInsightsChart.dart';

class AmbulanceAgencyDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AgencyDashboardViewModel, AmbulanceMainViewModel>(
      builder: (context, viewModel, mainViewModel, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: RefreshIndicator(
            onRefresh: () async {
              await viewModel.refreshDashboardData();
              await mainViewModel.fetchVendorStatus();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, viewModel, mainViewModel),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTodaySummary(viewModel),
                        const SizedBox(height: 24),
                        _buildLiveBookingRequests(viewModel, context),
                        const SizedBox(height: 24),
                        AmbulanceAgencyAnalyticsInsightsChart(viewModel: viewModel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AgencyDashboardViewModel viewModel, AmbulanceMainViewModel mainViewModel) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(viewModel.agencyProfile?.officePhotos.firstOrNull?['url'] ?? 'https://via.placeholder.com/150'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Agency Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.agencyProfile?.agencyName ?? 'Agency Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.agencyProfile?.email ?? 'agency@email.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Toggle
                GestureDetector(
                  onTap: () async {
                    if (!mainViewModel.isLoading) {
                      final newStatus = await mainViewModel.toggleVendorStatus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: AwesomeSnackbarContent(
                            title: newStatus ? 'Status Updated' : 'Error',
                            message: newStatus ? 'You are now ${newStatus ? 'Active' : 'Inactive'}' : 'Failed to update status',
                            contentType: newStatus ? ContentType.success : ContentType.failure,
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: mainViewModel.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: mainViewModel.isActive ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mainViewModel.isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                mainViewModel.isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          )
                        else ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mainViewModel.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          mainViewModel.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: mainViewModel.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick Stats Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _quickStatItem(Icons.phone, '${viewModel.totalBookings}', 'Total Calls'),
                _quickStatItem(Icons.timer, '${viewModel.avgResponseTime} min', 'Avg Response'),
                _quickStatItem(Icons.local_shipping, '${viewModel.operationalKms} km', 'Distance'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStatItem(IconData icon, String value, String label) {
    return Container(
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(AgencyDashboardViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _summaryBox("Total Bookings", "${vm.totalBookings}", Colors.blue),
                const SizedBox(width: 16),
                _summaryBox("Today's Bookings", "${vm.todaysBookings}", Colors.green),
                const SizedBox(width: 16),
                _summaryBox("Response Time", "${vm.avgResponseTime} min", Colors.orange),
                const SizedBox(width: 16),
                _summaryBox("Operational KMs", "${vm.operationalKms} km", Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(String title, String count, Color color) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.analytics, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBookingRequests(AgencyDashboardViewModel vm, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Live Booking Requests",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${vm.pendingBookings.length} Active",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          vm.pendingBookings.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No ongoing bookings right now",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: vm.pendingBookings.length,
                  separatorBuilder: (_, __) => Divider(height: 24),
                  itemBuilder: (context, index) {
                    final request = vm.pendingBookings[index];
                    return _buildBookingRequestCard(request, context);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBookingRequestCard(dynamic request, BuildContext context) {
    final customerName = request.user.name ?? "Unknown";
    final contact = request.user.phoneNumber ?? "";
    final pickup = request.pickupLocation;
    final drop = request.dropLocation;
    final status = request.status;
    final time = request.requiredDateTime;

    final isPending = status.toLowerCase() == "pending";
    Color statusColor = isPending ? Colors.orange : Colors.green;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                radius: 24,
                child: Icon(Icons.person, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact,
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: Icon(Icons.call, color: Colors.green, size: 18),
                label: Text("Call"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => launchUrl(Uri.parse('tel:$contact')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pickup,
                        style: TextStyle(color: Colors.grey[800]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drop,
                        style: TextStyle(color: Colors.grey[800]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(time.toLocal()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
