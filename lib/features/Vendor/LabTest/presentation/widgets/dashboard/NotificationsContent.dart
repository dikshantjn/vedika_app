import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';

class NotificationsContent extends StatelessWidget {
  const NotificationsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuarterlyUpdateReminder(),
          const SizedBox(height: 24),
          _buildNotificationList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: LabTestColorPalette.primaryBlueLightest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_outlined,
                size: 16,
                color: LabTestColorPalette.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'All Notifications',
                style: TextStyle(
                  fontSize: 12,
                  color: LabTestColorPalette.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuarterlyUpdateReminder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.primaryBlueLightest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LabTestColorPalette.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LabTestColorPalette.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.update,
              color: LabTestColorPalette.textWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quarterly Update Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please update your diagnostic center information for Q2 2024',
                  style: TextStyle(
                    fontSize: 14,
                    color: LabTestColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: LabTestColorPalette.textSecondary,
            ),
            onPressed: () {
              // Handle dismiss
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    // Mock data for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Booking',
        'message': 'John Doe booked a Blood Test for tomorrow',
        'time': '2 hours ago',
        'type': 'booking',
      },
      {
        'title': 'Report Ready',
        'message': 'MRI Scan report for Jane Smith is ready',
        'time': '5 hours ago',
        'type': 'report',
      },
      {
        'title': 'System Update',
        'message': 'New features have been added to the dashboard',
        'time': '1 day ago',
        'type': 'system',
      },
    ];

    return Column(
      children: notifications.map((notification) => _buildNotificationItem(notification)).toList(),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    IconData icon;
    Color iconColor;

    switch (notification['type']) {
      case 'booking':
        icon = Icons.calendar_today;
        iconColor = LabTestColorPalette.primaryBlue;
        break;
      case 'report':
        icon = Icons.description;
        iconColor = LabTestColorPalette.secondaryTeal;
        break;
      case 'system':
        icon = Icons.system_update;
        iconColor = LabTestColorPalette.warningYellow;
        break;
      default:
        icon = Icons.notifications;
        iconColor = LabTestColorPalette.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 14,
                    color: LabTestColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: LabTestColorPalette.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 