import 'package:flutter/material.dart';

class EnableLocationWidget extends StatelessWidget {
  final Future<bool> Function(BuildContext context) enableLocation; // Adjusted type to match the method
  final VoidCallback onLocationEnabled; // Callback to be triggered after enabling location successfully

  EnableLocationWidget({
    required this.enableLocation,
    required this.onLocationEnabled, // Initialize callback
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 10,
              offset: Offset(0, 5), // Shadow position
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width * 0.85, // Adjust width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 40,
              color: Colors.red,
            ),
            SizedBox(height: 10),
            Text(
              "Location is required to proceed with the order. We need your location to send the order request to nearby medical stores, where they will verify your prescription and add the medicines to your cart.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool locationEnabled = await enableLocation(context); // Trigger location enabling
                if (locationEnabled) {
                  // If location enabled successfully, call the callback
                  onLocationEnabled();
                } else {
                  // Location enabling failed or was denied
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Location enabling failed. Please try again.")),
                  );
                }
              },
              child: Text("Enable Location"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
