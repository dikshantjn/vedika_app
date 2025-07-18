import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Orders/ProcessOrderScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/invoice_pdf.dart';

class OrdersWidget extends StatefulWidget {
  final MedicineOrderViewModel viewModel;

  const OrdersWidget({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<OrdersWidget> createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  @override
  void initState() {
    super.initState();
    // Set up the callback for orders list updates
    widget.viewModel.onOrdersListUpdate = () {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild with the updated orders list
        });
      }
    };
  }

  @override
  void dispose() {
    // Clear the callback when disposing
    widget.viewModel.onOrdersListUpdate = null;
    super.dispose();
  }

  // Function to get formatted status text
  String _formatStatus(String status) {
    if (status == "Accepted") return "Order Confirmed"; // Special case

    return status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'), // Match camel case transitions
          (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  // Function to get color based on order status
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
        widget.viewModel.orders.isEmpty
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
          itemCount: widget.viewModel.orders.length,
          itemBuilder: (context, index) {
            final order = widget.viewModel.orders[index];
            return _buildOrderCard(order, context);
          },
        ),
      ],
    );
  }

  Widget _buildOrderCard(MedicineOrderModel order, BuildContext context) {
    bool showProcessButton = order.orderStatus != "Delivered" && order.orderStatus != "Cancelled";

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
          // Order ID and Created Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ID: ${order.orderId}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 6),
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

          // Order Status & Process/Download Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatStatus(order.orderStatus),
                  style: TextStyle(
                    color: _getStatusColor(order.orderStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              // Show either Process Order or Download Invoice button
              if (order.orderStatus == "Delivered")
                OutlinedButton(
                  onPressed: widget.viewModel.isGeneratingInvoiceForOrder(order.orderId)
                    ? null 
                    : () => _generateInvoice(context, order.orderId),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: widget.viewModel.isGeneratingInvoiceForOrder(order.orderId)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Generating...",
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ],
                      )
                    : Text(
                        "Download Invoice",
                        style: TextStyle(fontSize: 14, color: Colors.green),
                      ),
                )
              else if (showProcessButton)
                OutlinedButton(
                  onPressed: () => _showProcessOrderScreen(
                    context,
                    widget.viewModel,
                    order.prescriptionId,
                    order.orderId,
                    order.user.name!,
                    DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
                    order.selfDelivery,
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
            ],
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
      bool selfDelivery,
      ) async {
    String? prescriptionUrl = await viewModel.fetchPrescriptionUrl(prescriptionId);
    final prescriptionData = await viewModel.fetchPrescriptionData(orderId);

    // Find the order to get jsonPrescription
    final order = viewModel.orders.firstWhere(
      (order) => order.orderId == orderId,
      orElse: () => MedicineOrderModel.empty(),
    );
    

    final bool? orderConfirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessOrderScreen(
          prescriptionUrl: prescriptionUrl ?? '', // Pass empty string if not found
          customerName: customerName,
          orderDate: orderDate,
          orderId: orderId,
          selfDelivery: selfDelivery,
          jsonPrescription:prescriptionData ,
        ),
      ),
    );

    // If order was confirmed, refresh the orders list
    if (orderConfirmed == true) {
      await viewModel.fetchOrders();
    }

    // Show a warning after navigation if prescription was missing
    if (prescriptionUrl == null || prescriptionUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prescription not found!")),
      );
    }
  }

  // Function to handle invoice generation
  void _generateInvoice(BuildContext context, String orderId) async {
    try {
      await widget.viewModel.generateInvoice(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice downloaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate invoice: ${e.toString()}")),
      );
    }
  }
}
