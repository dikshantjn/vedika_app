import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/ProcessBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Dashboard/AmbulanceAgencyAnalyticsInsightsChart.dart';

class AmbulanceAgencyDashboardScreen extends StatelessWidget {
  final viewModel = Get.put(AgencyDashboardViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() => RefreshIndicator(
        onRefresh: () async {
          await viewModel.refreshDashboardData();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // important for RefreshIndicator to work
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaySummary(viewModel),
              const SizedBox(height: 24),
              _buildLiveBookingRequests(viewModel,context),
              const SizedBox(height: 24),
              AmbulanceAgencyAnalyticsInsightsChart(viewModel: viewModel),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildTodaySummary(AgencyDashboardViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _summaryBox("Total Bookings", "${vm.totalBookings.value}", Colors.blueAccent),
          const SizedBox(width: 16),
          _summaryBox("Today's Bookings", "${vm.todaysBookings.value}", Colors.green),
          const SizedBox(width: 16),
          _summaryBox("Response Time", "${vm.avgResponseTime.value} min", Colors.orange),
          const SizedBox(width: 16),
          _summaryBox("Operational KMs", "${vm.operationalKms.value} km", Colors.purple),
          const SizedBox(width: 16),
          // You can add more summary boxes here
        ],
      ),
    );
  }


  Widget _summaryBox(String title, String count, Color color) {
    return Container(
      width: 180, // Fixed width for horizontal scrolling
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.analytics, color: color),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }


  Widget _buildLiveBookingRequests(AgencyDashboardViewModel vm, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ongoing Booking Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          vm.pendingBookings.isEmpty
              ? SizedBox(
            width: double.infinity,
            child: Text(
              "No ongoing bookings right now",
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: vm.pendingBookings.length,
            separatorBuilder: (_, __) => Divider(height: 24),
            itemBuilder: (context, index) {
              final request = vm.pendingBookings[index];
              final customerName = request.user.name ?? "Unknown";
              final contact = request.user.phoneNumber ?? "";
              final pickup = request.pickupLocation;
              final drop = request.dropLocation;
              final status = request.status;
              final requestId = request.requestId;
              final time = request.requiredDateTime;

              final isPending = status.toLowerCase() == "pending";
              Color statusColor = isPending ? Colors.orange : Colors.green;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Avatar + Name + Contact + Call
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: Icon(Icons.person, color: Colors.blueAccent),
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
                                  Expanded(
                                    child: Text(contact,
                                        style: TextStyle(color: Colors.grey[700])),
                                  ),
                                  OutlinedButton.icon(
                                    icon: Icon(Icons.call, color: Colors.green, size: 18),
                                    label: Text("Call", style: TextStyle(color: Colors.green)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.green),
                                      shape: StadiumBorder(),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      launchUrl(Uri.parse('tel:$contact'));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),
                    if (pickup.isNotEmpty && drop.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "$pickup → $drop",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    const SizedBox(height: 6),

                    /// Time + Status
                    /// Time + Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Time: ${DateFormat('dd MMMM yyyy hh:mm a').format(time.toLocal())}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
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
            },
          ),
        ],
      ),
    );
  }


}
