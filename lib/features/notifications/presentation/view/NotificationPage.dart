import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/viewmodel/CoreNotificationViewModel.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late CoreNotificationViewModel _notificationViewModel;    
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();

    // Initialize notification view model with user or vendor ID
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await StorageService.getUserId();
      final vendorId = await VendorLoginService().getVendorId();

      _notificationViewModel = Provider.of<CoreNotificationViewModel>(context, listen: false);

      if (userId != null) {
        _notificationViewModel.initializeForUser(userId);
      } else if (vendorId != null) {
        _notificationViewModel.initializeForVendor(vendorId);
      }

      if (userId != null || vendorId != null) {
        _notificationViewModel.loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            final scope = MainScreenScope.maybeOf(context);
            if (scope != null) {
              scope.setIndex(0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor,
        centerTitle: true,
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
      ),
      body: Consumer<CoreNotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading notifications...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load notifications',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    viewModel.error ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.refreshNotifications(),
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_off_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll see your notifications here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildNotificationList(viewModel.notifications);
        },
      ),
    );
  }

  Widget _buildNotificationList(List notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        await _notificationViewModel.refreshNotifications();
      },
      color: ColorPalette.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final formattedDate = DateFormat('dd MMM yyyy').format(notification.createdAt);
          final formattedTime = DateFormat('h:mm a').format(notification.createdAt);

          return Dismissible(
            key: Key(notification.notificationId),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red[400],
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  _notificationViewModel.markAsRead(notification.notificationId);
                  _handleNotificationTap(context, notification);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: notification.isRead ? Colors.white : Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notification.isRead
                          ? Colors.teal.withOpacity(0.1)
                          : Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification.isRead
                          ? Icons.check_circle_rounded
                          : Icons.notifications_active_rounded,
                        color: notification.isRead ? Colors.teal : Colors.amber,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$formattedDate at $formattedTime',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAllAsRead(CoreNotificationViewModel viewModel) async {
    final success = await viewModel.markAllAsRead();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.green,
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
                color: Colors.red[400],
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
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

  void _handleNotificationTap(BuildContext context, notification) {
    // Handle navigation based on notification type
    if (notification.type == 'clinic_appointment' && notification.data != null) {
      // Navigate to appointment details or perform action
      final appointmentId = notification.data['appointmentId'];
      if (appointmentId != null) {
        // Navigate to appointment details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to appointment: $appointmentId'),
            backgroundColor: ColorPalette.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (notification.type == 'order_update' && notification.data != null) {
      // Navigate to order details
      final orderId = notification.data['orderId'];
      if (orderId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to order: $orderId'),
            backgroundColor: ColorPalette.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Handle other notification types or show generic message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification: ${notification.title}'),
          backgroundColor: ColorPalette.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
