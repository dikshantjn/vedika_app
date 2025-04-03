import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class OrderDetailsWidget extends StatefulWidget {
  final String orderId;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              // Dropdown Menu Button (Top Right)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  // Handle menu item selection
                  if (value == "Ready to Pickup") {
                    viewModel.updateOrderStatus(widget.orderId, "ReadyForPickup");
                  } else if (value == "Out for Delivery") {
                    viewModel.updateOrderStatus(widget.orderId, "OutForDelivery");
                  } else if (value == "Delivered") {
                    viewModel.updateOrderStatus(widget.orderId, "Delivered");
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: "Ready to Pickup",
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Ready to Pickup",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "Out for Delivery",
                    child: Row(
                      children: [
                        Icon(Icons.delivery_dining, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Out for Delivery",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "Delivered",
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Delivered",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                offset: Offset(0, 8),  // Slightly adjust the dropdown position
                color: Colors.white,   // White background for the dropdown
                elevation: 5,          // Add elevation for a subtle shadow effect
              )
            ],
          ),
          const SizedBox(height: 6),

          // Order Status Section
          const SizedBox(height: 10),

          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show Status or Accept Order button based on order status
              if (viewModel.orderStatus == "PrescriptionVerified")
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
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                    "Confirm Order",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    viewModel.orderStatus == "Accepted" ? "Order Confirmed" : viewModel.orderStatus,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
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
          )
        ],
      ),
    );
  }
}
