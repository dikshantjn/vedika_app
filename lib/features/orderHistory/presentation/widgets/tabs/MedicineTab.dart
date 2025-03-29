import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/MedicineOrderHistoryViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomOrderInfoDialog.dart';

class MedicineTab extends StatefulWidget {
  const MedicineTab({Key? key}) : super(key: key);

  @override
  _MedicineTabState createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  final MedicineOrderHistoryViewModel viewModel = MedicineOrderHistoryViewModel();

  @override
  void initState() {
    super.initState();
    // Fetch orders when the widget is initialized
    _fetchOrders();
  }

  // Use Future directly for the builder
  Future<void> _fetchOrders() async {
    await viewModel.fetchOrdersByUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchOrders(), // Future to fetch the orders
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading spinner while fetching data
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Show error message if there's an issue
        } else {
          // When data is fetched, show the order list
          final orders = viewModel.orders;

          if (orders.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderItem(
                context,
                order: order, // Pass the full order object
              );
            },
          );
        }
      },
    );
  }

  Widget _buildOrderItem(
      BuildContext context, {
        required MedicineOrderModel order, // Pass the full order object
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
                  order.orderId,
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
                  'Date: ${order.createdAt}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Total: \₹${order.totalAmount}',
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
                  'Items: ${order.orderItems.length}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                _buildStatusChip(order.orderStatus), // Status Chip added to the same row
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to display status with a color chip
  Widget _buildStatusChip(String status) {
    // Format status (e.g., OutForDelivery -> Out For Delivery)
    String formattedStatus = status.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'), (Match match) => '${match.group(1)} ${match.group(2)}');

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
      case 'outfordelivery':
        chipColor = Colors.yellow;
        break;
      case 'pending':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        formattedStatus,
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
  void _showOrderDetails(BuildContext context, MedicineOrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomOrderInfoDialog(
          orderNumber: order.orderId,
          imageUrls: order.orderItems.map((item) => item.productId).toList(), // Assuming you have an imageUrl property
          date: order.createdAt.toString(),
          status: order.orderStatus,
          total: order.totalAmount.toString(),
          items: order.orderItems.map((item) => item.name).toList().join(', '), // Assuming 'name' is the property of items
        );
      },
    );
  }
}
