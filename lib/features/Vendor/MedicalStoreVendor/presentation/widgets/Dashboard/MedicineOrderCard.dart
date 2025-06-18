import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Orders/ProcessOrderScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class OrderCard extends StatelessWidget {
  final List<MedicineOrderModel> orders;
  final VoidCallback onViewAll;
  final MedicineOrderViewModel viewModel; // ✅ Pass viewModel to fetch prescription

  const OrderCard({
    Key? key,
    required this.orders,
    required this.onViewAll,
    required this.viewModel, // ✅ Required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "Incoming Orders" + "View All"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Incoming Orders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MedicalStoreVendorColorPalette.secondaryColor,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Orders List
        orders.isNotEmpty
            ? Column(
          children: orders
              .take(5)
              .map((order) => _buildOrderItem(context, order)) // ✅ Pass context
              .toList(),
        )
            : _buildEmptyState("No Incoming Orders"),
      ],
    );
  }

  // Widget to build a single order item
  Widget _buildOrderItem(BuildContext context, MedicineOrderModel order) {
    bool showProcessButton =
        order.orderStatus != "Delivered" && order.orderStatus != "Cancelled";

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID (Takes full width)
            Text(
              "Order ID: ${order.orderId}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            // Customer Name
            Text(
              "Customer: ${order.user.name}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 6),

            // Row for Status and Process Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(order.orderStatus),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _formatStatus(order.orderStatus),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Process Order Button (Only if order is not Delivered or Cancelled)
                if (showProcessButton)
                  OutlinedButton(
                    onPressed: () {
                      _showProcessOrderScreen(
                        context,
                        viewModel, // ✅ Pass viewModel
                        order.prescriptionId,
                        order.orderId,
                        order.user.name!,
                        DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt), // ✅ Use createdAt instead of orderDate
                        order.selfDelivery, // NEW: pass self delivery
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(10, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Process Order",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  // Function to get background color for status badges
  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange.shade100;
      case "Accepted":
        return Colors.lightBlue.shade100;
      case "PaymentConfirmed":
        return Colors.teal.shade100;
      case "OutForDelivery":
        return Colors.blue.shade100;
      case "Delivered":
        return Colors.green.shade100;
      case "Cancelled":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  // Function to format status text
  String _formatStatus(String status) {
    if (status == "Accepted") return "Order Confirmed";
    return status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  // Function to navigate to ProcessOrderScreen
  void _showProcessOrderScreen(
      BuildContext context,
      MedicineOrderViewModel viewModel,
      String prescriptionId,
      String orderId,
      String customerName,
      String orderDate,
      bool selfDelivery, // NEW: self delivery parameter
      ) async {
    String? prescriptionUrl = await viewModel.fetchPrescriptionUrl(prescriptionId);

    if (prescriptionUrl != null && prescriptionUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessOrderScreen(
            prescriptionUrl: prescriptionUrl,
            customerName: customerName,
            orderDate: orderDate,
            orderId: orderId,
            selfDelivery: selfDelivery, // NEW: pass self delivery
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
