import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class QuickActionsCard extends StatelessWidget {
  final Function()? onCreateAppointment;
  final Function()? onManageSchedule;
  final Function()? onUploadPrescription;
  final Function()? onViewReports;

  const QuickActionsCard({
    Key? key,
    this.onCreateAppointment,
    this.onManageSchedule,
    this.onUploadPrescription,
    this.onViewReports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionItem(
                  context,
                  icon: Icons.event_note,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  title: 'Create Appointment',
                  onTap: onCreateAppointment,
                ),
                _buildQuickActionItem(
                  context,
                  icon: Icons.calendar_month,
                  color: DoctorConsultationColorPalette.warningYellow,
                  title: 'Manage Schedule',
                  onTap: onManageSchedule,
                ),
                _buildQuickActionItem(
                  context,
                  icon: Icons.description,
                  color: DoctorConsultationColorPalette.successGreen,
                  title: 'Upload Prescription',
                  onTap: onUploadPrescription,
                ),
                _buildQuickActionItem(
                  context,
                  icon: Icons.analytics_outlined,
                  color: DoctorConsultationColorPalette.secondaryTeal,
                  title: 'View Reports',
                  onTap: onViewReports,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required Function()? onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final itemWidth = (size.width - 80) / 2;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
 
 
 