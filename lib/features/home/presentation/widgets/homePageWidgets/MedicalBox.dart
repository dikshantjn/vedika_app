import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalBoxColors.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';

class MedicalBoxRow extends StatelessWidget {
  const MedicalBoxRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Hospital",
        "subtitle": "Book",
        "icon": Icons.local_hospital_rounded,
        "bgColor": MedicalBoxColors.hospital,
        "textColor": MedicalBoxColors.hospitalText,
        "route": "/hospital"
      },
      {
        "title": "Doctor",
        "subtitle": "Consult",
        "icon": Icons.medical_services_rounded,
        "bgColor": MedicalBoxColors.clinic,
        "textColor": MedicalBoxColors.clinicText,
        "route": "/clinic/consultationType"
      },
      {
        "title": "Medicine",
        "subtitle": "Order",
        "icon": Icons.medication_rounded,
        "bgColor": MedicalBoxColors.medicine,
        "textColor": MedicalBoxColors.medicineText,
        "route": "/medicineOrder"
      },
      {
        "title": "Lab Test",
        "subtitle": "Book",
        "icon": Icons.science_rounded,
        "bgColor": MedicalBoxColors.labTest,
        "textColor": MedicalBoxColors.labTestText,
        "route": "/labTest"
      },
      {
        "title": "Blood",
        "subtitle": "Order",
        "icon": Icons.bloodtype_rounded,
        "bgColor": MedicalBoxColors.bloodBank,
        "textColor": MedicalBoxColors.bloodBankText,
        "route": "/bloodbank"
      },
      {
        "title": "Ambulance",
        "subtitle": "Emergency",
        "icon": Icons.emergency_rounded,
        "bgColor": MedicalBoxColors.ambulance,
        "textColor": MedicalBoxColors.ambulanceText,
        "route": "/ambulance"
      },
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildMedicalBox(
              context: context,
              title: item["title"],
              subtitle: item["subtitle"],
              icon: item["icon"],
              bgColor: item["bgColor"],
              textColor: item["textColor"],
              route: item["route"],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicalBox({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 85,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: textColor,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
