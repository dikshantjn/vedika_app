import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/PrescriptionPreviewScreen.dart';

class OrderDetailsWidget extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String orderDate;
  final String prescriptionUrl;
  final VoidCallback onOrderConfirmed;

  const OrderDetailsWidget({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.orderDate,
    required this.prescriptionUrl,
    required this.onOrderConfirmed,
  }) : super(key: key);

  @override
  _OrderDetailsWidgetState createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  String? _currentStatus;
  MedicineOrderViewModel? _viewModel;  // Store viewModel reference

  @override
  void initState() {
    super.initState();
    // Fetch order status when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
      _viewModel?.fetchOrderStatus(widget.orderId).then((_) {
        if (mounted) {
          setState(() {
            _currentStatus = _viewModel?.orderStatus;
          });
        }
      });

      // Set up the callback for order status updates
      _viewModel?.onOrderStatusUpdate = (prescriptionId) {
        if (mounted) {
          _viewModel?.fetchOrderStatus(widget.orderId).then((_) {
            if (mounted) {
              setState(() {
                _currentStatus = _viewModel?.orderStatus;
              });
            }
          });
        }
      };
    });
  }

  @override
  void dispose() {
    // Clear the callback when disposing using stored reference
    _viewModel?.onOrderStatusUpdate = null;
    super.dispose();
  }

  void _viewPrescription(BuildContext context) {
    if (widget.prescriptionUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrescriptionPreviewScreen(
            prescriptionUrl: widget.prescriptionUrl,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No prescription file available"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MedicineOrderViewModel>(context);

    // Update local status if viewModel status changes
    if (_currentStatus != viewModel.orderStatus) {
      _currentStatus = viewModel.orderStatus;
    }

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
                onSelected: (value) async {
                  String newStatus = "";
                  switch (value) {
                    case "Ready to Pickup":
                      newStatus = "ReadyForPickup";
                      break;
                    case "Out for Delivery":
                      newStatus = "OutForDelivery";
                      break;
                    case "Delivered":
                      newStatus = "Delivered";
                      break;
                  }
                  
                  if (newStatus.isNotEmpty) {
                    await viewModel.updateOrderStatus(widget.orderId, newStatus);
                    if (mounted) {
                      setState(() {
                        _currentStatus = newStatus;
                      });
                    }
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
                offset: const Offset(0, 8),
                color: Colors.white,
                elevation: 5,
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
              if (_currentStatus == "PrescriptionVerified" || _currentStatus == "Pending")
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () async {
                      await viewModel.acceptOrder(widget.orderId);
                      if (context.mounted) {
                        if (viewModel.isOrderAccepted) {
                          setState(() {
                            _currentStatus = "Accepted";
                          });
                          // Refresh the order status to ensure consistency
                          await viewModel.fetchOrderStatus(widget.orderId);
                          // Call the callback to refresh orders list without navigating back
                          widget.onOrderConfirmed();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.acceptMessage),
                            backgroundColor: viewModel.isOrderAccepted 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                )
              else
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      _currentStatus == "Accepted" ? "Order Confirmed" : _currentStatus ?? "Loading...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // 🔍 View Prescription Button (always at the right side)
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () => _viewPrescription(context),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text(
                    "View Prescription",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
