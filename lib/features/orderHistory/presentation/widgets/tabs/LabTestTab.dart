import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/LabTestOrderViewModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/ReportViewScreen.dart';

class LabTestTab extends StatefulWidget {
  @override
  _LabTestTabState createState() => _LabTestTabState();
}

class _LabTestTabState extends State<LabTestTab> {
  @override
  void initState() {
    super.initState();
    final userId = "GOrt7AWP82dMYs8tVejjLyvdPyy2";
    Future.microtask(() =>
        Provider.of<LabTestOrderViewModel>(context, listen: false)
            .fetchCompletedLabTestOrders(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LabTestOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  "Loading your lab tests...",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final orders = viewModel.orders;
        if (orders.isEmpty || (viewModel.error != null && viewModel.error!.contains("No completed bookings found"))) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  "No lab tests found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 12),
                Text(
                  "Unable to load lab tests",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderItem(context, orders[index]);
          },
        );
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, LabTestBooking order) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.science_outlined,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.diagnosticCenter?.name ?? 'Unknown Lab',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${order.bookingDate} at ${order.bookingTime}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.bookingStatus ?? 'Unknown'),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey.withOpacity(0.2)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoPill(
                  icon: Icons.science_outlined,
                  label: (order.selectedTests?.length ?? 0) > 1
                      ? "${order.selectedTests?.length ?? 0} Tests"
                      : order.selectedTests?.first ?? "No tests",
                ),
                _buildInfoPill(
                  icon: Icons.location_on_outlined,
                  label: order.homeCollectionRequired == true ? "Home Collection" : "At Center",
                ),
                Text(
                  "₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (order.reportUrls != null && order.reportUrls!.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Test Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 8),
              ...order.reportUrls!.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportViewScreen(
                              reportUrl: entry.value,
                              testName: entry.key,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.visibility_outlined, size: 16),
                      label: Text("View Report"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
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
      case 'ongoing':
        chipColor = Colors.orange;
        break;
      case 'pending':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch report URL')),
      );
    }
  }
}
