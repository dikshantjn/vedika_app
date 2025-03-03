import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/notifications/presentation/viewmodel/NotificationViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:intl/intl.dart'; // Import intl package

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch notifications when the page is first built
    final viewModel = context.read<NotificationViewModel>();

    // If notifications are empty, fetch them
    if (viewModel.notifications.isEmpty) {
      viewModel.fetchNotifications();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor, // AppBar color
        centerTitle: true,
      ),
      drawer: DrawerMenu(),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          // Check if notifications are still loading
          if (viewModel.notifications.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: viewModel.notifications.length,
            itemBuilder: (context, index) {
              final notification = viewModel.notifications[index];

              // Format the date and time using intl package (no need for type check)
              final formattedDate = DateFormat('dd/MM/yyyy').format(notification.timestamp);
              final formattedTime = DateFormat('h:mm a').format(notification.timestamp);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    // Mark as read on tap
                    viewModel.markAsRead(notification.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      leading: CircleAvatar(
                        backgroundColor: notification.isRead ? Colors.teal : Colors.amber,
                        child: Icon(
                          notification.isRead ? Icons.check : Icons.notifications,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,  // Smaller font size
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 12,  // Smaller font size for message
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$formattedDate at $formattedTime', // Date and Time
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic, // Italic style
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.teal,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
