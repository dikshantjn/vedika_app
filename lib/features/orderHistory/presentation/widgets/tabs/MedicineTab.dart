import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/MedicineOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomOrderInfoDialog.dart';

class MedicineTab extends StatelessWidget {
  final MedicineOrderViewModel viewModel = MedicineOrderViewModel();

  @override
  Widget build(BuildContext context) {
    // Use the ViewModel to get the orders
    final orders = viewModel.orders;

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(
          context,
          order: order, // Pass the whole order object
        );
      },
    );
  }

  Widget _buildOrderItem(
      BuildContext context, {
        required MedicineOrder order, // Pass the full order object
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number and Info Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.blueGrey,
                    size: 24.0,
                  ),
                  onPressed: () {
                    // Pass the full order object to _showOrderDetails
                    _showOrderDetails(context, order);
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            // Date and Total in the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${order.date}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Total: ${order.total}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            // Items and Status in the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items: ${order.items}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                _buildStatusChip(order.status), // Status Chip added to the same row
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to display status with a color chip
  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        chipColor = Colors.green;
        break;
      case 'shipped':
        chipColor = Colors.orange;
        break;
      case 'processing':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
      backgroundColor: chipColor,
      shape: StadiumBorder(),
    );
  }

  // Function to handle the info icon press
  void _showOrderDetails(BuildContext context, MedicineOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomOrderInfoDialog(
          orderNumber: order.orderNumber,
          imageUrls: order.imageUrls,
          date: order.date,
          status: order.status,
          total: order.total,
          items: order.items,
        );
      },
    );
  }
}
