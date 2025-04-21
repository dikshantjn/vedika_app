import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class DashboardHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String doctorName;
  final String specialization;
  final String clinicName;

  DashboardHeaderDelegate({
    required this.doctorName,
    required this.specialization,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    final titleFontSize = 20 - (progress * 4);
    final subtitleFontSize = 16 - (progress * 4);
    final opacity = 1.0 - progress * 0.7;

    return Container(
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DoctorConsultationColorPalette.primaryBlue,
                  DoctorConsultationColorPalette.primaryBlueDark,
                ],
              ),
            ),
          ),
          
          // Content
          Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile image
                  Container(
                    width: 60 - (progress * 20),
                    height: 60 - (progress * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/doctor_profile.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          doctorName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$specialization | $clinicName',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: subtitleFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Notification icon
                  IconButton(
                    onPressed: () {
                      // Navigate to notifications
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
} 