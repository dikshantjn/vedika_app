import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class PatientStatsCard extends StatelessWidget {
  const PatientStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Statistics',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DoctorConsultationColorPalette.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.people_alt_outlined,
                      title: 'Total Consultations',
                      value: '183',
                      iconColor: DoctorConsultationColorPalette.primaryBlue,
                      iconBgColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.question_answer_outlined,
                      title: 'Total Enquiries',
                      value: '27',
                      iconColor: DoctorConsultationColorPalette.secondaryTeal,
                      iconBgColor: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _buildSatisfactionMeter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfactionMeter() {
    const double satisfactionPercentage = 0.85; // 85%
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Patient Satisfaction',
              style: TextStyle(
                color: DoctorConsultationColorPalette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: DoctorConsultationColorPalette.successGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(satisfactionPercentage * 100).toInt()}%',
                    style: TextStyle(
                      color: DoctorConsultationColorPalette.successGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: satisfactionPercentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DoctorConsultationColorPalette.successGreen,
                      DoctorConsultationColorPalette.secondaryTeal,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: DoctorConsultationColorPalette.warningYellow,
                ),
                const SizedBox(width: 4),
                Text(
                  '4.7',
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(27 reviews)',
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              'View All',
              style: TextStyle(
                color: DoctorConsultationColorPalette.primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 