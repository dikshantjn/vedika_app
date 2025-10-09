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
        "icon": Icons.emergency_rounded,
        "bgColor": MedicalBoxColors.ambulance,
        "textColor": MedicalBoxColors.ambulanceText,
        "route": "/ambulance-search"
      },
      {
        "title": "Medicine",
        "icon": Icons.medication_rounded,
        "bgColor": MedicalBoxColors.medicine,
        "textColor": MedicalBoxColors.medicineText,
        // "route": "/medicine-order"
        "route": "/newMedicineOrderScreen"
      },
      {
        "title": "Hospital",
        "icon": Icons.local_hospital_rounded,
        "bgColor": MedicalBoxColors.hospital,
        "textColor": MedicalBoxColors.hospitalText,
        "route": "/hospital"
      },
      {
        "title": "Doctor",
        "icon": Icons.medical_services_rounded,
        "bgColor": MedicalBoxColors.clinic,
        "textColor": MedicalBoxColors.clinicText,
        "route": "/clinic/consultationType"
      },
      {
        "title": "Lab Test",
        "icon": Icons.science_rounded,
        "bgColor": MedicalBoxColors.labTest,
        "textColor": MedicalBoxColors.labTestText,
        "route": "/labTest"
      },
      {
        "title": "Blood",
        "icon": Icons.bloodtype_rounded,
        "bgColor": MedicalBoxColors.bloodBank,
        "textColor": MedicalBoxColors.bloodBankText,
        "route": "/bloodbank"
      },
      {
        "title": "Blog",
        "icon": Icons.article_rounded,
        "bgColor": Colors.blue.shade50,
        "textColor": Colors.lightBlueAccent,
        "route": "/blogs"
      },
      {
        "title": "Her Phases",
        "icon": Icons.timelapse,
        "bgColor": Colors.orange.shade50,
        "textColor": Colors.deepOrange,
        "route": "/herPhases"
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
          child: Stack(
            children: [
              // Subtle radial glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment( -0.4, -0.6),
                      radius: 1.2,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        textColor.withOpacity(0.06),
                        textColor.withOpacity(0.10),
                      ],
                      stops: const [0.3, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
              // Top-left organic pill
              Positioned(
                top: -10,
                left: -14,
                child: Transform.rotate(
                  angle: -0.35,
                  child: Container(
                    width: isTablet ? 70 : 52,
                    height: isTablet ? 30 : 22,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              // Top-right soft circle
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: isTablet ? 58 : 44,
                  height: isTablet ? 58 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textColor.withOpacity(0.12),
                  ),
                ),
              ),
              // Bottom-left rounded stripe
              Positioned(
                bottom: -10,
                left: -8,
                child: Transform.rotate(
                  angle: 0.22,
                  child: Container(
                    width: isTablet ? 64 : 48,
                    height: isTablet ? 16 : 12,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Bottom-right small circle
              Positioned(
                bottom: 8,
                right: 10,
                child: Container(
                  width: isTablet ? 12 : 8,
                  height: isTablet ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textColor.withOpacity(0.14),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Icon(
                        icon,
                        size: isTablet ? 28 : 26,
                        color: textColor,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
