import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:url_launcher/url_launcher.dart'; // For making a call

class ChooseFileWidget extends StatelessWidget {
  final Function pickPrescription;

  ChooseFileWidget({required this.pickPrescription});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorPalette.whiteColor.withOpacity(0.2), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width * 0.9, // Slightly wider for better aesthetics
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/uploadPrescription.json',
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 5), // Reduced space between animation and text
            Text(
              "Upload Your Prescription",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPalette.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You can upload up to 3 files, each less than 5MB.",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                await pickPrescription(context); // Ensure the method is awaited
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                backgroundColor: ColorPalette.primaryColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Choose File",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Divider(color: Colors.grey), // Horizontal divider
            // SizedBox(height: 12),
            // Text(
            //   "Don't have a prescription? No worries!",
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w600,
            //     color: Colors.black54,
            //   ),
            // ),
            // SizedBox(height: 12),
            // ElevatedButton(
            //   onPressed: _makeCall, // Make the call
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     elevation: 5,
            //     backgroundColor: ColorPalette.medicineColor, // Change color for the call button
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.call, color: Colors.white, size: 22),
            //       SizedBox(width: 8),
            //       Text(
            //         "Call for Help",
            //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
