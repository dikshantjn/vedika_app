import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class DoctorStatsCard extends StatelessWidget {
  final int totalPatients;
  final int totalAppointments;
  final double rating;
  final int completionRate;
  final int reviewCount;

  const DoctorStatsCard({
    Key? key,
    required this.totalPatients,
    required this.totalAppointments,
    required this.rating,
    required this.completionRate,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: DoctorConsultationColorPalette.primaryBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'This Month',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.groups_outlined,
                    color: DoctorConsultationColorPalette.primaryBlue,
                    value: totalPatients.toString(),
                    label: 'Total Patients',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.event_note,
                    color: DoctorConsultationColorPalette.secondaryTeal,
                    value: totalAppointments.toString(),
                    label: 'Appointments',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    color: DoctorConsultationColorPalette.warningYellow,
                    value: rating.toString(),
                    label: 'Rating ($reviewCount reviews)',
                    showDecimal: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRateProgressItem(
                    title: 'Completion Rate',
                    percentage: completionRate,
                    color: DoctorConsultationColorPalette.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    bool showDecimal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            showDecimal ? "${value.substring(0, 1)}.${value.length > 1 ? value.substring(1, 2) : '0'}" : value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateProgressItem({
    required String title,
    required int percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
