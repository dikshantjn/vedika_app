import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class BookingOverviewCard extends StatelessWidget {
  const BookingOverviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bookings Overview',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBookingCard(
                context,
                icon: Icons.today,
                title: 'Today',
                count: 12,
                color: DoctorConsultationColorPalette.primaryBlue,
                bgColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBookingCard(
                context,
                icon: Icons.calendar_today,
                title: 'Upcoming',
                count: 28,
                color: DoctorConsultationColorPalette.secondaryTeal,
                bgColor: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBookingCard(
                context,
                icon: Icons.history,
                title: 'Past',
                count: 145,
                color: DoctorConsultationColorPalette.textSecondary,
                bgColor: DoctorConsultationColorPalette.textSecondary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              color: DoctorConsultationColorPalette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: DoctorConsultationColorPalette.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
} 