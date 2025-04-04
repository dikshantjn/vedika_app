import 'package:flutter/material.dart';

class AmbulanceNotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("New Booking Request"),
              subtitle: Text("A new booking request has been received."),
              trailing: Icon(Icons.notifications),
            ),
            ListTile(
              title: Text("Payment Received"),
              subtitle: Text("Payment has been successfully processed for Booking #2."),
              trailing: Icon(Icons.notifications),
            ),
            // Add more notifications as needed
          ],
        ),
      ),
    );
  }
}
