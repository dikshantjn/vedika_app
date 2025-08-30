import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onProcessRequest;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onProcessRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildCustomerInfo(),
            SizedBox(height: 20),
            _buildStatusSection(),
            SizedBox(height: 20),
            _buildProcessButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green[100]!,
                Colors.green[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: Colors.green[600],
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.orderId}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  order.user?.name ?? 'Unknown Customer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  order.user?.phoneNumber ?? 'No phone number',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildStatusSection() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        SizedBox(width: 8),
        Text(
          _formatDateTime(order.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
        break;
      case 'verified':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        statusText = 'Verified';
        statusIcon = Icons.check_circle;
        break;
      case 'waiting_for_payment':
        chipColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        statusText = 'Waiting for Payment';
        statusIcon = Icons.payment;
        break;
      case 'payment_completed':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Payment Completed';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'ready_to_pickup':
        chipColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        statusText = 'Ready for Pickup';
        statusIcon = Icons.local_pharmacy;
        break;
      case 'out_for_delivery':
        chipColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        statusText = 'Out for Delivery';
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Delivered';
        statusIcon = Icons.done_all;
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: textColor,
          ),
          SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    // Don't show process button for delivered orders
    if (order.status.toLowerCase() == 'delivered') {
      return SizedBox.shrink();
    }
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onProcessRequest,
        icon: Icon(Icons.history, size: 18),
        label: Text('Process Order'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: ColorPalette.primaryColor, width: 2),
          foregroundColor: ColorPalette.primaryColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
