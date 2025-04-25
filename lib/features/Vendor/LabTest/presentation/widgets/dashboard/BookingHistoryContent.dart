import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';

class BookingHistoryContent extends StatelessWidget {
  const BookingHistoryContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFilterChips(),
          const SizedBox(height: 24),
          _buildBookingList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: LabTestColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View all your past bookings',
              style: TextStyle(
                fontSize: 16,
                color: LabTestColorPalette.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LabTestColorPalette.primaryBlueLightest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.history,
            color: LabTestColorPalette.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', true),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', false),
          const SizedBox(width: 8),
          _buildFilterChip('Cancelled', false),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? LabTestColorPalette.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? LabTestColorPalette.primaryBlue : LabTestColorPalette.textSecondary,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : LabTestColorPalette.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10, // Replace with actual data
      itemBuilder: (context, index) {
        return _buildBookingCard();
      },
    );
  }

  Widget _buildBookingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Blood Test',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: LabTestColorPalette.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: LabTestColorPalette.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Date: 12 Mar 2024'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, 'Time: 10:00 AM'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person, 'Patient: John Doe'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Address: 123 Main St, City'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // View details
                },
                style: TextButton.styleFrom(
                  foregroundColor: LabTestColorPalette.primaryBlue,
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: LabTestColorPalette.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: LabTestColorPalette.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 