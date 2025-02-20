import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalBoxColors.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';

class MedicalBoxRow extends StatelessWidget {
  const MedicalBoxRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"title": "Medicine", "icon": Icons.medical_services, "colors": MedicalBoxColors.medicine, "route": "/medicine"},
      {"title": "Lab Test", "icon": Icons.science, "colors": MedicalBoxColors.labTest, "route": "/labtest"},
      {"title": "Blood Bank", "icon": Icons.bloodtype, "colors": MedicalBoxColors.bloodBank, "route": "/bloodbank"},
      {"title": "Clinic", "icon": Icons.local_hospital, "colors": MedicalBoxColors.clinic, "route": "/clinic"},
      {"title": "Hospital", "icon": Icons.apartment, "colors": MedicalBoxColors.hospital, "route": "/hospital"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return _buildMedicalBox(
            context: context,
            title: item["title"],
            icon: item["icon"],
            colors: item["colors"],
            route: item["route"],
          );
        }).toList(),
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
            MaterialPageRoute(builder: (context) => BloodBankMapScreen()), // Navigates to Blood Bank Page
          );
        } else {
          print("$title clicked");
        }
      },
      child: Container(
        width: 60,
        height: 60,
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
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
