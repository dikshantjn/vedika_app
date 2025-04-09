import 'package:flutter/material.dart';

class ServiceDetailsCard extends StatelessWidget {
  final booking;
  final bool isFilled;

  const ServiceDetailsCard({super.key, required this.booking, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    if (!isFilled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "Service details have not been added yet.",
          style: TextStyle(fontSize: 16, color: Colors.orange),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow("Pickup Location", booking.pickupLocation),
            _buildDetailRow("Drop Location", booking.dropLocation),
            _buildDetailRow("Vehicle Type", booking.vehicleType),
            _buildDetailRow("Estimated Cost", "₹ ${booking.totalAmount.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "$title:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ),
      ],
    ),
  );
}
