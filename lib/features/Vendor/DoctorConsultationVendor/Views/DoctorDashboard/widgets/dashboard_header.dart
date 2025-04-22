import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicProfileViewModel.dart';

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

    // Get the view models
    final dashboardViewModel = Provider.of<DashboardViewModel>(context);
    final profileViewModel = Provider.of<DoctorClinicProfileViewModel>(context);
    final profile = profileViewModel.profile;

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
                  // Profile image with status indicator
                  Stack(
                    children: [
                      Container(
                        width: 60 - (progress * 20),
                        height: 60 - (progress * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: profile != null && profile.profilePicture.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(profile.profilePicture),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profile == null || profile.profilePicture.isEmpty
                            ? Center(
                                child: Text(
                                  doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
                                  style: TextStyle(
                                    fontSize: 22 - (progress * 7),
                                    fontWeight: FontWeight.bold,
                                    color: DoctorConsultationColorPalette.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      // Online/Offline status indicator
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: dashboardViewModel.isOnline
                                ? DoctorConsultationColorPalette.successGreen
                                : DoctorConsultationColorPalette.errorRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          // Use actual doctor name if available
                          profile != null && profile.doctorName.isNotEmpty
                              ? '${profile.doctorName}'
                              : doctorName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                // Use first specialization from profile if available
                                profile != null && profile.specializations.isNotEmpty
                                    ? '${profile.specializations.first} | $clinicName'
                                    : '$specialization | $clinicName',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: subtitleFontSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: dashboardViewModel.isOnline
                                    ? DoctorConsultationColorPalette.successGreen.withOpacity(0.3)
                                    : DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dashboardViewModel.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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