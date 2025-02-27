import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/AmbulanceOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/AppointmentOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/AmbulanceOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomAmbulanceOrderInfoDialog.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomOrderInfoDialog.dart';


class AmbulanceTab extends StatelessWidget {
  final AmbulanceOrderViewModel viewModel = AmbulanceOrderViewModel();

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

  Widget _buildOrderItem(BuildContext context, AmbulanceOrder order) {
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
                  onPressed: () {
                    _showOrderDetails(context, order);
                  },
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
                  'Service: ${order.serviceType}',
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
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'ongoing':
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

  void _showOrderDetails(BuildContext context, AmbulanceOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAmbulanceOrderInfoDialog(
          orderNumber: order.orderNumber,
          imageUrls: order.imageUrls ?? [], // Assuming AppointmentOrder has an image list
          date: order.date,
          status: order.status,
          total: order.total,
          serviceType: order.serviceType, // Adjust as needed
        );
      },
    );
  }
}
