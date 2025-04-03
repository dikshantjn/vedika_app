import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderPlacedBottomSheet extends StatelessWidget {
  final String paymentId;

  // Constructor
  const OrderPlacedBottomSheet({Key? key, required this.paymentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lottie Animation for Success
          Lottie.asset(
            'assets/animations/verified.json',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Text(
            "Order Placed Successfully!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your order with payment ID $paymentId has been successfully placed.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              // Navigate to the order tracking screen (Replace with your actual tracking screen)
              Navigator.pushNamed(context, '/trackOrder', arguments: paymentId);
            },
            child: Text("Track Order", style: TextStyle(color: Colors.green)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.green),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show the bottom sheet
  static void showOrderPlacedBottomSheet(BuildContext context, String paymentId) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return OrderPlacedBottomSheet(paymentId: paymentId);
      },
    );
  }
}
