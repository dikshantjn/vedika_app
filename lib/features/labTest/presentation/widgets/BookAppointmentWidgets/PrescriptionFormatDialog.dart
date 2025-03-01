import 'package:flutter/material.dart';

class PrescriptionFormatDialog extends StatelessWidget {
  const PrescriptionFormatDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              "Prescription Format",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Prescription Sample Image with Border
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/category/category.png', // Make sure the image exists in assets
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.75,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Information Text
            Text(
              "Your prescription should include:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 12),

            // List of Required Details with Icons
            _buildInfoRow(Icons.person, "Doctor's Name & Signature", Colors.deepPurple),
            _buildInfoRow(Icons.person_outline, "Patient's Name & Age", Colors.teal),
            _buildInfoRow(Icons.calendar_today, "Date of Issue", Colors.orange),
            _buildInfoRow(Icons.medical_services, "Medicines with Dosage", Colors.redAccent),
            _buildInfoRow(Icons.local_hospital, "Clinic/Hospital Stamp", Colors.blue),

            const SizedBox(height: 20),

            // OK Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Vibrant button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create info rows with icons
  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.blueGrey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
