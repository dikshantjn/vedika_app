import 'package:flutter/material.dart';

class AmbulanceRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Requests")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("Booking Request #1"),
              subtitle: Text("Customer Name: John Doe\nTime: 10:00 AM"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to booking details or accept/decline actions
              },
            ),
            ListTile(
              title: Text("Booking Request #2"),
              subtitle: Text("Customer Name: Jane Smith\nTime: 11:30 AM"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to booking details or accept/decline actions
              },
            ),
            // Add more booking requests as needed
          ],
        ),
      ),
    );
  }
}
