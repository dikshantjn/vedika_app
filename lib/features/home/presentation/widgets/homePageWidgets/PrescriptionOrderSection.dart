import 'package:flutter/material.dart';

class PrescriptionOrderSection extends StatelessWidget {
  final VoidCallback onOrderNow;

  const PrescriptionOrderSection({Key? key, required this.onOrderNow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Takes full width
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Grey background color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prescription Icon
          Icon(Icons.receipt_long, color: Colors.black, size: 30),
          SizedBox(width: 10),

          // "Order with Prescription" Text
          Expanded(
            child: Text(
              "Order with Prescription",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // "Order Now" Button
          ElevatedButton(
            onPressed: onOrderNow, // Call back for button press
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
            ),
            child: Text(
              "Order Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
