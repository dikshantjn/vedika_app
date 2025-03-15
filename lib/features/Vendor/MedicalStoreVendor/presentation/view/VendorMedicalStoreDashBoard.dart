import 'package:flutter/material.dart';

class VendorMedicalStoreDashBoardScreen extends StatefulWidget {
  @override
  _VendorMedicalStoreDashBoardState createState() => _VendorMedicalStoreDashBoardState();
}

class _VendorMedicalStoreDashBoardState extends State<VendorMedicalStoreDashBoardScreen> {
  bool isServiceOnline = true; // To track the service status (On/Off)

  // Dummy data for orders (replace with actual dynamic data)
  List<Map<String, String>> orders = [
    {'orderId': '001', 'customerName': 'John Doe', 'status': 'Pending'},
    {'orderId': '002', 'customerName': 'Jane Smith', 'status': 'Accepted'},
  ];

  // Dummy data for return requests
  List<Map<String, String>> returnRequests = [
    {'orderId': '003', 'customerName': 'Mark Lee', 'status': 'Pending'},
  ];

  // Dummy data for analytics
  Map<String, int> analytics = {
    'totalOrders': 150,
    'averageOrderValue': 100,
    'ordersToday': 20,
    'returnsThisWeek': 5,
  };

  // Function to toggle service on/off
  void toggleService() {
    setState(() {
      isServiceOnline = !isServiceOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vendor Medical Store Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Service Status Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Status: ${isServiceOnline ? "Online" : "Offline"}',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: isServiceOnline,
                  onChanged: (value) {
                    toggleService();
                    // Implement logic to handle service status update
                  },
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 20),

            // Order Requests Notification
            Text("Incoming Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...orders.map((order) => Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text("Order ID: ${order['orderId']}"),
                subtitle: Text("Customer: ${order['customerName']}"),
                trailing: Text("Status: ${order['status']}"),
                onTap: () {
                  // Handle order acceptance or viewing details
                },
              ),
            )),

            Divider(),
            SizedBox(height: 20),

            // Return Requests
            Text("Return Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...returnRequests.map((request) => Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text("Return Request for Order ID: ${request['orderId']}"),
                subtitle: Text("Customer: ${request['customerName']}"),
                trailing: Text("Status: ${request['status']}"),
                onTap: () {
                  // Handle return request
                },
              ),
            )),

            Divider(),
            SizedBox(height: 20),

            // Analytics Section
            Text("Analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text("Total Orders: ${analytics['totalOrders']}"),
                subtitle: Text("Average Order Value: ₹${analytics['averageOrderValue']}"),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text("Orders Today: ${analytics['ordersToday']}"),
                subtitle: Text("Returns This Week: ${analytics['returnsThisWeek']}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
