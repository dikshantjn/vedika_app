import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

// Widget for the UI after verification
class AfterVerificationWidget extends StatelessWidget {
  final List<String> medicines;
  final List<String> medicineImages;
  final VoidCallback onPlaceOrder;

  const AfterVerificationWidget({
    Key? key,
    required this.medicines,
    required this.medicineImages,
    required this.onPlaceOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Verification Done!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Verified by: Medical Store XYZ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Medicines Added:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Column(
          children: List.generate(medicines.length, (index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Medicine Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    medicineImages[index],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                // Medicine Name
                Text(
                  medicines[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 20),
        // Information Text and Action for Placing Order
        Column(
          children: [
            Text(
              'Medicines have been added to your card.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Place Order Button
            ElevatedButton(
              onPressed: onPlaceOrder,
              child: Text(
                'Place Order',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}