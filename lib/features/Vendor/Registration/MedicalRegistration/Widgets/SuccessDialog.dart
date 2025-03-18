import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final Function onLoginPressed;

  SuccessDialog({required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Set background to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      title: Center( // Title centered
        child: Text(
          'Request Sent Successfully',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60.0, // Slightly bigger icon
          ),
          SizedBox(height: 15),
          Text(
            'Your request is sent successfully and is currently under review.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center, // Center the text
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: [
        Center( // Center the button horizontally
          child: ElevatedButton(
            onPressed: () {
              onLoginPressed(); // Navigate to the vendor login page
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green, // Green button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded button
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: Text(
              'Go to Vendor Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
