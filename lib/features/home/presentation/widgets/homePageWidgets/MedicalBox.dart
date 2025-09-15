import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalBoxColors.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class MedicalBoxRow extends StatelessWidget {
  const MedicalBoxRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine if it's a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Common breakpoint for tablets
    
    // Calculate responsive dimensions
    final boxWidth = isTablet ? screenWidth * 0.12 : 85.0; // 12% of screen width for tablets
    final containerHeight = isTablet ? 120.0 : 100.0;
    final boxPadding = isTablet ? 8.0 : 4.0;

    final List<Map<String, dynamic>> items = [
      {
        "title": "Ambulance",
        "subtitle": "Emergency",
        "icon": Icons.emergency_rounded,
        "bgColor": MedicalBoxColors.ambulance,
        "textColor": MedicalBoxColors.ambulanceText,
        "route": "/ambulance-search"
      },
      {
        "title": "Medicine",
        "subtitle": "Order",
        "icon": Icons.medication_rounded,
        "bgColor": MedicalBoxColors.medicine,
        "textColor": MedicalBoxColors.medicineText,
        // "route": "/medicine-order"
        "route": "/newMedicineOrderScreen"
      },
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
        "title": "Blog",
        "subtitle": "Health",
        "icon": Icons.article_rounded,
        "bgColor": Colors.orange.shade50,
        "textColor": Colors.deepOrange,
        "route": "/blogs"
      },
    ];

    return Container(
      width: double.infinity,
      height: containerHeight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: boxPadding),
            child: _buildMedicalBox(
              context: context,
              title: item["title"],
              subtitle: item["subtitle"],
              icon: item["icon"],
              bgColor: item["bgColor"],
              textColor: item["textColor"],
              route: item["route"],
              boxWidth: boxWidth,
              isTablet: isTablet,
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
    required double boxWidth,
    required bool isTablet,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (route == "/bloodbank") {
            Navigator.pushNamed(context, AppRoutes.bloodBank);
          } else if (route == "/blogs") {
            Navigator.pushNamed(context, AppRoutes.blogCategories);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: boxWidth,
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
            padding: EdgeInsets.all(isTablet ? 12 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 3,
                  child: Icon(
                    icon,
                    size: isTablet ? 28 : 20,
                    color: textColor,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 9,
                      color: textColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
