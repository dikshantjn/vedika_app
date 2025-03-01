import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalBoxColors.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';

class MedicalBoxRow extends StatelessWidget {
  const MedicalBoxRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"title": "Hospital", "icon": Icons.local_hospital, "colors": MedicalBoxColors.hospital, "route": "/hospital"},
      {"title": "Clinic", "icon": Icons.apartment, "colors": MedicalBoxColors.clinic, "route": "/clinic"},
      {"title": "Medicine", "icon": Icons.medical_services, "colors": MedicalBoxColors.medicine, "route": "/medicineOrder"},
      {"title": "Lab Test", "icon": Icons.science, "colors": MedicalBoxColors.labTest, "route": "/labTest"},
      {"title": "Blood Bank", "icon": Icons.bloodtype, "colors": MedicalBoxColors.bloodBank, "route": "/bloodbank"},
      {"title": "Ambulance", "icon": Icons.local_taxi, "colors": MedicalBoxColors.ambulance, "route": "/ambulance"},
    ];

    return SizedBox(
      height: 80, // Adjust height to fit icons & text properly
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: _buildMedicalBox(
                context: context,
                title: item["title"],
                icon: item["icon"],
                colors: item["colors"],
                route: item["route"],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMedicalBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> colors,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route == "/bloodbank") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BloodBankMapScreen()),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        width: 70, // Slightly wider for better spacing
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white), // Increased size
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
