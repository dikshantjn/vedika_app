import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulancePaymentService.dart';

class AmbulancePaymentDialog extends StatelessWidget {
  final String providerName;
  final double baseFare;
  final double distanceCharge;
  final double totalAmount;
  final double totalDistance;
  final VoidCallback onPaymentSuccess; // Callback when payment is successful

  const AmbulancePaymentDialog({
    Key? key,
    required this.providerName,
    required this.baseFare,
    required this.distanceCharge,
    required this.totalAmount,
    required this.totalDistance,
    required this.onPaymentSuccess,
  }) : super(key: key);

  void _startPayment(BuildContext context) {
    final paymentService = AmbulancePaymentService();

    paymentService.onPaymentSuccess = (response) {
      print("Payment Successful! ID: ${response.paymentId}");
      Navigator.pop(context); // Close dialog after success
      // TODO: Proceed with ambulance booking
    };

    paymentService.onPaymentError = (response) {
      print("Payment Failed: ${response.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: ${response.message}")),
      );
    };

    paymentService.openPaymentGateway(
      amount: totalAmount, // Example amount in INR
      key: 'rzp_test_uMMypIJ2X2bn1N', // Replace with your Razorpay API key
      userPhone: 'USER_PHONE_NUMBER', // Replace with actual user phone number
      userEmail: 'USER_EMAIL', // Replace with actual user email
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital_rounded, color: Colors.red, size: 25),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Ambulance Request Accepted",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.business_rounded, color: Colors.blueGrey, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(providerName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: 15),
            Divider(thickness: 1),
            Text("Cost Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            _buildCostItem(Icons.map_rounded, "Total Distance", _formatDistance(totalDistance)),
            _buildCostItem(Icons.attach_money, "Base Fare", "₹${baseFare.toStringAsFixed(2)}"),
            _buildCostItem(Icons.route, "Distance Charge", "₹${distanceCharge.toStringAsFixed(2)}"),
            SizedBox(height: 15),
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text("Cancel"),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _startPayment(context),
                  icon: Icon(Icons.payment_rounded, size: 18, color: Colors.white),
                  label: Text("Make Payment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 16, color: Colors.black54))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDistance(double distanceInKm) {
    return distanceInKm < 1
        ? "${(distanceInKm * 1000).toStringAsFixed(0)} m"
        : "${distanceInKm.toStringAsFixed(2)} km";
  }
}
