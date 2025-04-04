import 'package:flutter/material.dart';

class AmbulanceAgencyRegistrationDialog extends StatelessWidget {
  final String message;
  final bool isSuccess;

  AmbulanceAgencyRegistrationDialog({
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 50,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              isSuccess ? 'Success' : 'Error',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text(
              isSuccess
                  ? 'Your request has been submitted. Wait for approval. You will receive an email after verification.'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // This will close the dialog
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                backgroundColor: isSuccess ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
