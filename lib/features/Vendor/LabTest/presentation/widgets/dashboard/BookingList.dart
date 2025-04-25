import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';

class BookingList extends StatelessWidget {
  final String type;

  const BookingList({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for bookings
    final List<Map<String, dynamic>> bookings = [
      {
        'patientName': 'John Doe',
        'testType': 'Blood Test',
        'time': '09:00 AM',
        'status': 'Confirmed',
      },
      {
        'patientName': 'Jane Smith',
        'testType': 'MRI Scan',
        'time': '10:30 AM',
        'status': 'Pending',
      },
      {
        'patientName': 'Mike Johnson',
        'testType': 'CT Scan',
        'time': '02:00 PM',
        'status': 'Confirmed',
      },
    ];

    return Column(
      children: bookings.map((booking) => _buildBookingItem(booking)).toList(),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: LabTestColorPalette.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: LabTestColorPalette.primaryBlueLightest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_outline,
              color: LabTestColorPalette.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['patientName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking['testType'],
                  style: TextStyle(
                    fontSize: 14,
                    color: LabTestColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                booking['time'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(booking['status']),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return LabTestColorPalette.successGreen;
      case 'pending':
        return LabTestColorPalette.warningYellow;
      case 'cancelled':
        return LabTestColorPalette.errorRed;
      default:
        return LabTestColorPalette.textSecondary;
    }
  }
} 