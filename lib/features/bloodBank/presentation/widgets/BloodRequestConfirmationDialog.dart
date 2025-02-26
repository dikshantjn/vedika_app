import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bloodBank/data/models/BloodBank.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankPaymentService.dart';

class BloodRequestConfirmationDialog extends StatelessWidget {
  final BloodBank bloodBank;

  const BloodRequestConfirmationDialog({Key? key, required this.bloodBank}) : super(key: key);

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                "Blood Request Accepted!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
            SizedBox(height: 15),

            // Blood Bank Details
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  bloodBank.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blueAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bloodBank.address,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // Available Blood Units
            Text(
              "Available Blood Units:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bloodBank.availableBlood.map((bloodUnit) {
                return Row(
                  children: [
                    Icon(Icons.bloodtype, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "${bloodUnit.group}: ${bloodUnit.units} units",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Action Buttons (Call & Make Payment in One Row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Call Button
                ElevatedButton(
                  onPressed: () => _makePhoneCall(bloodBank.contact),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8, // Adds a shadow for depth
                    shadowColor: Colors.greenAccent.withOpacity(0.6), // Subtle shadow color
                    visualDensity: VisualDensity.comfortable, // Ensures consistent button size
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 20, color: Colors.white,), // Slightly larger icon
                      SizedBox(width: 8),
                      Text(
                        "Call",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Make Payment Button
                ElevatedButton(
                  onPressed: () {
                    // Initialize the blood bank payment service
                    BloodBankPaymentService paymentService = BloodBankPaymentService();

                    // Set up your payment success, error, and cancellation handlers
                    paymentService.onPaymentSuccess = (response) {
                      // Handle payment success
                      print("Payment Success: ${response.paymentId}");
                      // Proceed with other tasks (e.g., redirect user, update UI, etc.)
                    };

                    paymentService.onPaymentError = (response) {
                      // Handle payment failure
                      print("Payment Error: ${response.message}");
                      // Show error message to the user
                    };

                    paymentService.onPaymentCancelled = (response) {
                      // Handle payment cancellation
                      print("Payment Cancelled: ${response.message}");
                      // Show cancellation message to the user
                    };

                    // Open Razorpay payment gateway
                    paymentService.openPaymentGateway(500, "Blood Donation Payment", "Payment for blood donation");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8, // Adds a shadow for depth
                    shadowColor: Colors.orangeAccent.withOpacity(0.6), // Subtle shadow color
                    visualDensity: VisualDensity.comfortable, // Ensures consistent button size
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, size: 20, color: Colors.white), // Slightly larger icon
                      SizedBox(width: 8),
                      Text(
                        "Pay",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Order History Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.orderHistory);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text("Go to Order History", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
