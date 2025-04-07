import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Dashboard/AmbulanceAgencyAnalyticsInsightsChart.dart';

class AmbulanceAgencyDashboardScreen extends StatelessWidget {
  final viewModel = Get.put(AgencyDashboardViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodaySummary(viewModel),
            const SizedBox(height: 24),
            _buildLiveBookingRequests(viewModel),
            const SizedBox(height: 24),
            AmbulanceAgencyAnalyticsInsightsChart(viewModel: viewModel),
          ],
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




  Widget _buildLiveBookingRequests(AgencyDashboardViewModel vm) {
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
          Text(" Booking Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          vm.liveRequests.isEmpty
              ? Text("No requests at the moment",
              style: TextStyle(color: Colors.grey[600]))
              : ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: vm.liveRequests.length,
            separatorBuilder: (_, __) => Divider(height: 24),
            itemBuilder: (context, index) {
              final request = vm.liveRequests[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    child:
                    Icon(Icons.local_hospital, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request["title"] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("From: ${request["route"]}",
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    label: Text("Accept Request"),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

}
