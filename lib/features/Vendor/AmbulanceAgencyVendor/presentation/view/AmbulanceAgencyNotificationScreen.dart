import 'package:flutter/material.dart';

class AmbulanceAgencyNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color for the entire screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNotificationCard(
              title: "New Booking Request",
              subtitle: "A new booking request has been received.",
              icon: Icons.notifications,
            ),
            _buildNotificationCard(
              title: "Payment Received",
              subtitle: "Payment has been successfully processed for Booking #2.",
              icon: Icons.notifications,
            ),
            // Add more notifications as needed
          ],
        ),
      ),
    );
  }

  // Helper method to create a notification card with rounded corners and no shadow
  Widget _buildNotificationCard({required String title, required String subtitle, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Lighter background color for the card
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Vertical spacing between cards
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Notification Icon and Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: Notification Icon
          Icon(
            icon,
            color: Colors.cyan,
            size: 28, // Icon size adjusted
          ),
        ],
      ),
    );
  }
}
