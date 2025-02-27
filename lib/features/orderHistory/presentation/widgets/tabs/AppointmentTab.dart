import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/AppointmentOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/AppointmentOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomAppointmentInfoDialog.dart';

class AppointmentTab extends StatelessWidget {
  final AppointmentOrderViewModel viewModel = AppointmentOrderViewModel();

  @override
  Widget build(BuildContext context) {
    final orders = viewModel.orders;

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(context, order);
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, AppointmentOrder order) {
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
                  icon: Icon(Icons.info_outline, color: Colors.blueGrey, size: 24.0),
                  onPressed: () => _showOrderDetails(context, order),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${order.date}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
                Text(
                  'Total: ${order.total}',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Doctor: ${order.doctor}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'confirmed':
        chipColor = Colors.green;
        break;
      case 'upcoming':
        chipColor = Colors.orange;
        break;
      case 'pending':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12.0)),
      backgroundColor: chipColor,
      shape: StadiumBorder(),
    );
  }

  void _showOrderDetails(BuildContext context, AppointmentOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAppointmentInfoDialog(order: order);
      },
    );
  }
}
