import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class OrderDetailsWidget extends StatefulWidget {
  final int orderId;
  final String customerName;
  final String orderDate;
  final String prescriptionUrl;

  const OrderDetailsWidget({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.orderDate,
    required this.prescriptionUrl,
  }) : super(key: key);

  @override
  _OrderDetailsWidgetState createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch order status when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
      viewModel.fetchOrderStatus(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MedicineOrderViewModel>(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Order Details
          Text(
            "Order ID: #${widget.orderId}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Customer: ${widget.customerName}",
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          Text(
            "Date: ${widget.orderDate}",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          // _buildOrderStatus(viewModel),
          const SizedBox(height: 10),

          // 🔹 Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show Status or Accept Order button based on order status
              if (viewModel.orderStatus == "Accepted" || viewModel.orderStatus == "Completed")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    viewModel.orderStatus, // Show "Accepted" or "Completed" status
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () async {
                    await viewModel.acceptOrder(widget.orderId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(viewModel.acceptMessage)),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: viewModel.isAccepting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  )
                      : const Text(
                    "Accept Order",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w500),
                  ),
                ),

              // 🔍 View Prescription Button (always at the right side)
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.prescriptionUrl, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "View Prescription",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildOrderStatus(MedicineOrderViewModel viewModel) {
  //   // Show loading indicator while fetching status
  //   if (viewModel.orderStatus == "Loading...") {
  //     return Row(
  //       children: [
  //         const SizedBox(
  //           width: 16,
  //           height: 16,
  //           child: CircularProgressIndicator(strokeWidth: 2),
  //         ),
  //         const SizedBox(width: 8),
  //         Text(
  //           "Checking status...",
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //
  //   // Determine status color based on order state
  //   Color statusColor;
  //   switch (viewModel.orderStatus) {
  //     case "Pending":
  //       statusColor = Colors.orange;
  //       break;
  //     case "Accepted":
  //       statusColor = Colors.green;
  //       break;
  //     case "Completed":
  //       statusColor = Colors.blue;
  //       break;
  //     case "Cancelled":
  //       statusColor = Colors.red;
  //       break;
  //     default:
  //       statusColor = Colors.grey;
  //   }
  //
  //   return Row(
  //     children: [
  //       Text(
  //         "Status: ",
  //         style: TextStyle(
  //           fontSize: 14,
  //           color: Colors.grey[700],
  //         ),
  //       ),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //         decoration: BoxDecoration(
  //           color: statusColor.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: statusColor.withOpacity(0.3)),
  //         ),
  //         child: Text(
  //           viewModel.orderStatus,
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: statusColor,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
