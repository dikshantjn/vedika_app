import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class ChooseFileWidget extends StatelessWidget {
  final Function pickPrescription;

  ChooseFileWidget({required this.pickPrescription});

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
        width: MediaQuery.of(context).size.width * 0.85,  // Adjust width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/uploadPrescription.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              "Upload Prescription",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await pickPrescription(context);  // Ensure the method is awaited
              },
              icon: Icon(Icons.upload_file, color: Colors.white),
              label: Text("Choose File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
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
