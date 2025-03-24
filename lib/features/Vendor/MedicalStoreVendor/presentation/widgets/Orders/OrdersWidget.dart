import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class OrdersWidget extends StatefulWidget {
  final MedicineOrderViewModel viewModel;

  const OrdersWidget({Key? key, required this.viewModel}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when widget is initialized
    widget.viewModel.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Orders",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Expanded(
          child: widget.viewModel.orders.isEmpty
              ? Center(
            child: Text(
              "No Orders Found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: widget.viewModel.orders.length,
            itemBuilder: (context, index) {
              final order = widget.viewModel.orders[index];

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
                            color: order.orderStatus == "Completed"
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.orderStatus,
                            style: TextStyle(
                              color: order.orderStatus == "Completed" ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),

                    // User and Created Date
                    Text(
                      "User: ${order.userId}",
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Created: ${DateFormat.yMMMd().format(order.createdAt)}",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 10),

                    // View Details Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle View Order Details
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          side: BorderSide(color: Colors.blueAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("View Details", style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

