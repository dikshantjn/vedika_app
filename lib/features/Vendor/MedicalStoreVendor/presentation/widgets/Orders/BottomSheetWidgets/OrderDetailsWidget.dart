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
  final Map<String, dynamic>? jsonPrescription;


  const OrderDetailsWidget({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.orderDate,
    required this.prescriptionUrl,
    required this.selfDelivery,
    required this.onOrderConfirmed,
    this.jsonPrescription
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
    print("_viewPrescription called and the ${widget.jsonPrescription}");
    if (widget.prescriptionUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrescriptionPreviewScreen(
            prescriptionUrl: widget.prescriptionUrl,
            jsonPrescription: widget.jsonPrescription,
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
    print('isSelfDeliveryEnabled: ${viewModel.isSelfDeliveryEnabled}');

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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Order ID and Actions
          Row(
            children: [
              // Order ID and Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID and Status Row - Fixed overflow
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            "#${widget.orderId}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_currentStatus ?? "Loading...").withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatusColor(_currentStatus ?? "Loading...").withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _formatStatus(_currentStatus ?? "Loading..."),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(_currentStatus ?? "Loading..."),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.customerName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.orderDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Menu
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[700], size: 20),
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
                      return [
                        PopupMenuItem<String>(
                          value: "Out for Delivery",
                          child: Row(
                            children: [
                              Icon(Icons.delivery_dining, color: Colors.blue[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Out for Delivery",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "Delivered",
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Delivered",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    } else {
                      return [
                        PopupMenuItem<String>(
                          value: "Ready to Pickup",
                          child: Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, color: Colors.green[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Ready to Pickup",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "Out for Delivery",
                          child: Row(
                            children: [
                              Icon(Icons.delivery_dining, color: Colors.blue[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Out for Delivery",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "Delivered",
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Delivered",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[600],
                                  ),
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
                  elevation: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons Section
          Row(
            children: [
              // Confirm Order Button - Only show when not already accepted
              if (_currentStatus == "PrescriptionVerified" || _currentStatus == "Pending")
                Expanded(
                  child: Container(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        await viewModel.acceptOrder(widget.orderId);
                        if (context.mounted) {
                          if (viewModel.isOrderAccepted) {
                            setState(() {
                              _currentStatus = "Accepted";
                            });
                            await viewModel.fetchOrderStatus(widget.orderId);
                            widget.onOrderConfirmed();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    viewModel.isOrderAccepted ? Icons.check_circle : Icons.error_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(viewModel.acceptMessage),
                                  ),
                                ],
                              ),
                              backgroundColor: viewModel.isOrderAccepted ? Colors.green : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: viewModel.isAccepting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Confirm Order"),
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // View Prescription Button
              Expanded(
                child: Container(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => _viewPrescription(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "View Prescription",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Self Delivery Section - Fixed overflow
          if ((_currentStatus == "Accepted" && !viewModel.isSelfDeliveryEnabled) ||
              (viewModel.isSelfDeliveryEnabled))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                height: 44,
                child: viewModel.isSelfDeliveryEnabled
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.purple[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Self Delivery Enabled",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[600],
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: viewModel.isEnablingSelfDelivery
                            ? null
                            : () async {
                                await viewModel.enableSelfDelivery(widget.orderId);
                                if (context.mounted) {
                                  setState(() {});
                                  widget.onOrderConfirmed();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: const Text("Self delivery enabled successfully"),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.purple[600],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  );
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.purple[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: viewModel.isEnablingSelfDelivery
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                viewModel.isEnablingSelfDelivery ? "Enabling..." : "Enable Self Delivery",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[600],
                                ),
                              ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
