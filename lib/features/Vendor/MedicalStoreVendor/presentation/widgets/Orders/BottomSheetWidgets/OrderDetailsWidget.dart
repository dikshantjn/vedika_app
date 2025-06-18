import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/PrescriptionPreviewScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

class OrderDetailsWidget extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String orderDate;
  final String prescriptionUrl;
  final bool selfDelivery;
  final VoidCallback onOrderConfirmed;

  const OrderDetailsWidget({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.orderDate,
    required this.prescriptionUrl,
    required this.selfDelivery,
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
      // Fetch self delivery status
      _viewModel?.getAndSetSelfDeliveryStatus(widget.orderId);
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
          _viewModel?.getAndSetSelfDeliveryStatus(widget.orderId);
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

  // Helper method to get color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "PrescriptionVerified":
        return Colors.blue;
      case "Accepted":
        return Colors.green;
      case "PaymentConfirmed":
        return Colors.teal;
      case "AddedItemsInCart":
        return Colors.indigo;
      case "ReadyForPickup":
        return Colors.purple;
      case "OutForDelivery":
        return Colors.cyan;
      case "Delivered":
        return Colors.green.shade600;
      case "ReturnRequested":
        return Colors.orange.shade600;
      case "ReturnAccepted":
        return Colors.blue.shade600;
      case "ReturnPickupPending":
        return Colors.amber;
      case "ReturnInTransit":
        return Colors.cyan.shade600;
      case "Returned":
        return Colors.red.shade600;
      case "RefundProcessed":
        return Colors.grey.shade600;
      case "Cancelled":
        return Colors.red;
      case "Failed":
        return Colors.red.shade800;
      case "Expired":
        return Colors.grey;
      case "Processing":
        return Colors.blue.shade800;
      default:
        return Colors.grey;
    }
  }

  // Helper method to format status text
  String _formatStatus(String status) {
    switch (status) {
      case "Accepted":
        return "Order Confirmed";
      case "PrescriptionVerified":
        return "Prescription Verified";
      case "PaymentConfirmed":
        return "Payment Confirmed";
      case "AddedItemsInCart":
        return "Items Added to Cart";
      case "ReadyForPickup":
        return "Ready for Pickup";
      case "OutForDelivery":
        return "Out for Delivery";
      case "ReturnRequested":
        return "Return Requested";
      case "ReturnAccepted":
        return "Return Accepted";
      case "ReturnPickupPending":
        return "Return Pickup Pending";
      case "ReturnInTransit":
        return "Return in Transit";
      case "RefundProcessed":
        return "Refund Processed";
      default:
        return status.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
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

    // Debug print to verify the value
    print('isSelfDeliveryEnabled: [32m${viewModel.isSelfDeliveryEnabled}[0m');

    // Check if this specific order has self-delivery enabled
    final currentOrder = viewModel.orders.firstWhere(
      (order) => order.orderId == widget.orderId,
      orElse: () => MedicineOrderModel(
        orderId: widget.orderId,
        prescriptionId: '',
        userId: '',
        vendorId: '',
        discountAmount: 0.0,
        subtotal: 0.0,
        totalAmount: 0.0,
        orderStatus: _currentStatus ?? 'Loading...',
        paymentStatus: 'Unpaid',
        deliveryStatus: 'Pending',
        selfDelivery: widget.selfDelivery,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        user: UserModel.empty(),
        orderItems: [],
        deliveryCharge: 0,
        platformFee: 0
      ),
    );

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
              // Dropdown Menu Button (Top Right) - Only show when self delivery is enabled
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
                itemBuilder: (BuildContext context) {
                  if (viewModel.isSelfDeliveryEnabled) {
                    // If self delivery is enabled, do not show 'Ready to Pickup'
                    return [
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
                    ];
                  } else {
                    // If self delivery is not enabled, show all three options
                    return [
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
                    ];
                  }
                },
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
                // Show current status when order is in other states
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentStatus ?? "Loading...").withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(_currentStatus ?? "Loading...").withOpacity(0.3)),
                    ),
                    child: Text(
                      _formatStatus(_currentStatus ?? "Loading..."),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(_currentStatus ?? "Loading..."),
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
          ),

          // Self Delivery Button Row
          if ((_currentStatus == "Accepted" && !viewModel.isSelfDeliveryEnabled) ||
              (viewModel.isSelfDeliveryEnabled))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: viewModel.isSelfDeliveryEnabled
                        ? OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              side: const BorderSide(color: Colors.purple, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Self Delivery Enabled",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: viewModel.isEnablingSelfDelivery
                                ? null
                                : () async {
                                    await viewModel.enableSelfDelivery(widget.orderId);
                                    if (context.mounted) {
                                      setState(() {
                                        // No status change here
                                      });
                                      widget.onOrderConfirmed();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Self delivery enabled successfully"),
                                          backgroundColor: Colors.purple,
                                        ),
                                      );
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              side: const BorderSide(color: Colors.purple, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: viewModel.isEnablingSelfDelivery
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.purple,
                                    ),
                                  )
                                : const Text(
                                    "Enable Self Delivery",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
