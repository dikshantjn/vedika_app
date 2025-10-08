import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/viewmodel/CoreNotificationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class DoctorClinicNotificationScreen extends StatefulWidget {
  const DoctorClinicNotificationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorClinicNotificationScreen> createState() => _DoctorClinicNotificationScreenState();
}

class _DoctorClinicNotificationScreenState extends State<DoctorClinicNotificationScreen> {
  late CoreNotificationViewModel _notificationViewModel;

  @override
  void initState() {
    super.initState();

    // Initialize notification view model with vendor ID
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vendorId = await VendorLoginService().getVendorId();
      if (vendorId != null) {
        _notificationViewModel = Provider.of<CoreNotificationViewModel>(context, listen: false);
        _notificationViewModel.initializeForVendor(vendorId);
        _notificationViewModel.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Consumer<CoreNotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingView();
          }

          if (viewModel.error != null) {
            return _buildErrorView(viewModel);
          }

          if (viewModel.notifications.isEmpty) {
            return _buildEmptyView();
          }

          return _buildNotificationList(viewModel.notifications);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
      elevation: 0,
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Consumer<CoreNotificationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.unreadCount > 0) {
              return TextButton.icon(
                onPressed: () => _markAllAsRead(viewModel),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Mark All Read',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Consumer<CoreNotificationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.notifications.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${viewModel.totalCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }


  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: DoctorConsultationColorPalette.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(CoreNotificationViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: DoctorConsultationColorPalette.errorRed.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(
              color: DoctorConsultationColorPalette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DoctorConsultationColorPalette.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.refreshNotifications(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DoctorConsultationColorPalette.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: DoctorConsultationColorPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see all your appointment requests and updates here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DoctorConsultationColorPalette.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        await _notificationViewModel.refreshNotifications();
      },
      color: DoctorConsultationColorPalette.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.notificationId),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.errorRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 28,
              ),
            ),
            confirmDismiss: (direction) async {
              return await _showDeleteConfirmation(context);
            },
            onDismissed: (direction) {
              _deleteNotification(notification.notificationId);
            },
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }


  Widget _buildNotificationCard(notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and time
                Row(
                  children: [
                    _buildNotificationTypeBadge(notification.type),
                    const Spacer(),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  notification.title,
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Body
                Text(
                  notification.body,
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                // Action buttons (only for unread notifications)
                if (!notification.isRead) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _markAsRead(notification.notificationId),
                        icon: Icon(
                          Icons.check,
                          size: 16,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                        label: Text(
                          'Mark Read',
                          style: TextStyle(
                            color: DoctorConsultationColorPalette.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _deleteNotification(notification.notificationId),
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: DoctorConsultationColorPalette.errorRed,
                        ),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypeBadge(String? type) {
    Color badgeColor;
    IconData iconData;
    String label;

    switch (type) {
      case 'clinic_appointment':
        badgeColor = DoctorConsultationColorPalette.primaryBlue;
        iconData = Icons.calendar_today;
        label = 'Appointment';
        break;
      case 'order_update':
        badgeColor = DoctorConsultationColorPalette.successGreen;
        iconData = Icons.shopping_bag;
        label = 'Order';
        break;
      case 'payment':
        badgeColor = Colors.orange;
        iconData = Icons.payment;
        label = 'Payment';
        break;
      default:
        badgeColor = DoctorConsultationColorPalette.textSecondary;
        iconData = Icons.notifications;
        label = 'Notification';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markAllAsRead(CoreNotificationViewModel viewModel) async {
    final success = await viewModel.markAllAsRead();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          backgroundColor: DoctorConsultationColorPalette.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final success = await _notificationViewModel.markAsRead(notificationId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification marked as read'),
          backgroundColor: DoctorConsultationColorPalette.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final success = await _notificationViewModel.deleteNotification(notificationId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification deleted'),
          backgroundColor: DoctorConsultationColorPalette.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: DoctorConsultationColorPalette.errorRed,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Delete Notification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(notification) {
    // Handle notification tap based on type and data
    if (notification.type == 'clinic_appointment' && notification.data != null) {
      // Navigate to appointment details or perform action
      final appointmentId = notification.data['appointmentId'];
      if (appointmentId != null) {
        // Navigate to appointment details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to appointment: $appointmentId'),
            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // Mark as read if not already read
    if (!notification.isRead) {
      _markAsRead(notification.notificationId);
    }
  }
}
