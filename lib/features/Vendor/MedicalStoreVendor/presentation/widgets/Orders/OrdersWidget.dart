import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Orders/ProcessOrderScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class OrdersWidget extends StatelessWidget {
  final MedicineOrderViewModel viewModel;

  const OrdersWidget({Key? key, required this.viewModel}) : super(key: key);

  // Define colors for each status
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.green;
      case "AwaitingPayment":
        return Colors.blueAccent;
      case "PaymentConfirmed":
        return Colors.blue;
      case "PreparingOrder":
        return Colors.amber;
      case "ReadyForPickup":
        return Colors.purple;
      case "OutForDelivery":
        return Colors.cyan;
      case "Delivered":
        return Colors.green.shade600;
      case "Cancelled":
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Orders",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        viewModel.orders.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              "No Orders Found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: viewModel.orders.length,
          itemBuilder: (context, index) {
            final order = viewModel.orders[index];
            return _buildOrderCard(order, context);
          },
        ),
      ],
    );
  }

  Widget _buildOrderCard(MedicineOrderModel order, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ID: ${order.orderId}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.orderStatus,
                  style: TextStyle(
                    color: _getStatusColor(order.orderStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          // User Name and Created Date
          Text(
            "Customer Name: ${order.user.name ?? 'N/A'}",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),
          Text(
            "Date: ${DateFormat.yMMMd().format(order.createdAt)}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 10),
          // View Details Button
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => _showProcessOrderScreen(
                context,
                viewModel,
                order.prescriptionId,
                order.orderId,
                order.user.name!,
                DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                side: BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Process Order",
                style: TextStyle(fontSize: 14, color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProcessOrderScreen(
      BuildContext context,
      MedicineOrderViewModel viewModel,
      String prescriptionId,
      String orderId,
      String customerName,
      String orderDate,
      ) async {
    String? prescriptionUrl =
    await viewModel.fetchPrescriptionUrl(prescriptionId);

    if (prescriptionUrl != null && prescriptionUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessOrderScreen(
            prescriptionUrl: prescriptionUrl,
            customerName: customerName,
            orderDate: orderDate,
            orderId: orderId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prescription not found!")),
      );
    }
  }
}
