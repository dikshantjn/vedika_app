import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/notifications/presentation/viewmodel/NotificationViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<NotificationViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
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
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear All',
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                suffixIcon: Icon(Icons.filter_list_rounded, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => viewModel.setSearchQuery(value),
            ),
          ),
          Expanded(
            child: Consumer<NotificationViewModel>(
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
                          'We\'ll notify you when something arrives',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
          }

          return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: viewModel.notifications.length,
            itemBuilder: (context, index) {
              final notification = viewModel.notifications[index];
                    final formattedDate = DateFormat('dd MMM yyyy').format(notification.timestamp);
              final formattedTime = DateFormat('h:mm a').format(notification.timestamp);

                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                      ),
                      onDismissed: (direction) {
                        viewModel.deleteNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Notification deleted'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: Colors.white,
                              onPressed: () => viewModel.addNotification(notification),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () {
                    viewModel.markAsRead(notification.id);
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
          );
        },
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  size: 32,
                  color: Colors.red[400],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Clear All Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Are you sure you want to clear all notifications? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationViewModel>().clearAllNotifications();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All notifications cleared'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'CLEAR ALL',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case 'AmbulancePage':
        // Navigate to ambulance page with requestId
        Navigator.pushNamed(
          context,
          '/ambulance',
          arguments: {'requestId': notification.data['requestId']},
        );
        break;
      // Add more cases for different notification types
      default:
        // Handle default case or unknown types
        break;
    }
  }
}
