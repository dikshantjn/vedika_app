import 'package:flutter/material.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';

class ProductPartnerNotificationsPage extends StatelessWidget {
  const ProductPartnerNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProductPartnerColorPalette.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.done_all,
                  color: ProductPartnerColorPalette.primary,
                ),
                onPressed: () {
                  // Mark all as read
                },
                tooltip: 'Mark all as read',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: ProductPartnerColorPalette.primary,
                ),
                onPressed: () {
                  // Clear all notifications
                },
                tooltip: 'Clear all',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNotificationSection(
                    title: 'Today',
                    notifications: [
                      _buildNotificationItem(
                        icon: Icons.shopping_cart,
                        title: 'New Order Received',
                        message: 'You have received a new order #12345',
                        time: '2 hours ago',
                        isRead: false,
                        type: 'order',
                      ),
                      _buildNotificationItem(
                        icon: Icons.inventory_2,
                        title: 'Low Stock Alert',
                        message: 'Product "XYZ" is running low on stock',
                        time: '5 hours ago',
                        isRead: true,
                        type: 'inventory',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSection(
                    title: 'Yesterday',
                    notifications: [
                      _buildNotificationItem(
                        icon: Icons.payment,
                        title: 'Payment Received',
                        message: 'Payment of ₹5,000 has been received',
                        time: '1 day ago',
                        isRead: true,
                        type: 'payment',
                      ),
                      _buildNotificationItem(
                        icon: Icons.rate_review,
                        title: 'New Review',
                        message: 'You have received a new 5-star review',
                        time: '1 day ago',
                        isRead: true,
                        type: 'review',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSection(
                    title: 'Earlier',
                    notifications: [
                      _buildNotificationItem(
                        icon: Icons.system_update,
                        title: 'System Update',
                        message: 'New features have been added to the app',
                        time: '3 days ago',
                        isRead: true,
                        type: 'system',
                      ),
                      _buildNotificationItem(
                        icon: Icons.local_offer,
                        title: 'Special Offer',
                        message: 'Get 20% off on your next order',
                        time: '5 days ago',
                        isRead: true,
                        type: 'offer',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required List<Widget> notifications,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: notifications,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isRead,
    required String type,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _getNotificationColor(type),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  color: isRead ? Colors.grey.shade700 : Colors.black,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'inventory':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'review':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      case 'offer':
        return Colors.red;
      default:
        return ProductPartnerColorPalette.primary;
    }
  }
} 