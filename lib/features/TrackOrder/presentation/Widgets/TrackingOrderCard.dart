import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';

class TrackingOrderCard extends StatelessWidget {
  final TrackOrderViewModel viewModel;

  const TrackingOrderCard({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (viewModel.orders.isEmpty) {
      return const Center(child: Text("No orders found."));
    }

    return Column(
      children: viewModel.orders.map((order) {
        final steps = _getOrderSteps();
        final currentStepIndex = _getCurrentStepIndex(order.orderStatus);

        List<CartModel> cartItems = viewModel.orderItems[order.orderId] ?? [];

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(order),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildTimeline(steps, currentStepIndex),
                    const SizedBox(height: 16),
                    _buildOrderDetails(cartItems, order.totalAmount),
                    const Divider(),
                    if (order.orderStatus == "OutForDelivery") _buildRiderInfo(),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: const Text(
                  'Medicine Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }


  Widget _buildHeader(MedicineOrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Order ID: ${order.orderId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4), // Small spacing

        // Estimated arrival time
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.blueAccent), // Clock icon
            const SizedBox(width: 4),
            Text(
              'Arriving by ${viewModel.formatDeliveryDate(order.estimatedDeliveryDate)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueAccent),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(List<String> steps, int currentStepIndex) {
    ScrollController _scrollController = ScrollController();
    ValueNotifier<int> animatedStepIndex = ValueNotifier<int>(-1); // Start from -1 to show animation

    // Function to animate steps one by one
    Future<void> animateSteps() async {
      for (int step = 0; step <= currentStepIndex; step++) {
        await Future.delayed(const Duration(milliseconds: 400)); // Delay between each step
        animatedStepIndex.value = step;

        // Smooth scrolling
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            (step * 80.0).clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }

    // Start animation when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => animateSteps());

    return SizedBox(
      height: 80,
      child: ValueListenableBuilder<int>(
        valueListenable: animatedStepIndex,
        builder: (context, animatedIndex, _) {
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final isCompleted = index <= animatedIndex;
              final isCurrent = index == animatedIndex;

              Color lineColor = isCompleted ? Colors.green : Colors.grey.shade300;
              Color indicatorColor = isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.white);
              Color textColor = isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.grey);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: 80,
                child: TimelineTile(
                  axis: TimelineAxis.horizontal,
                  alignment: TimelineAlign.start,
                  isFirst: index == 0,
                  isLast: index == steps.length - 1,
                  beforeLineStyle: LineStyle(color: lineColor, thickness: 2),
                  indicatorStyle: IndicatorStyle(
                    width: 20,
                    height: 20,
                    indicator: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
                  afterLineStyle: LineStyle(color: lineColor, thickness: 2),
                  endChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textColor),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }



  Widget _buildOrderDetails(List<CartModel> cartItems, double totalAmount) {
    if (cartItems.isEmpty) return const SizedBox.shrink(); // Don't render anything if no items exist

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items Ordered',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cartItems.map((item) => _buildOrderItem(item)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildOrderItem(CartModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          Text(
            'x${item.quantity}',
            style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Your Rider', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Rahul Sharma', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call, size: 18, color: Colors.green),
            label: const Text('Call'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentStepIndex(String orderStatus) {
    Map<String, String> statusMapping = {
      "Pending": "Prescription Sent",
      "PrescriptionVerified": "Prescription Verified",
      "Accepted":"Order Confirmed",
      "AddedItemsInCart": "Items Added",
      "PaymentConfirmed": "Order Placed",
      "ReadyForPickup": "Order Placed",  // ✅ Treat "ReadyForPickup" as "Order Placed"
      "OutForDelivery": "Out for Delivery",
      "Delivered": "Delivered",
    };

    String? mappedStep = statusMapping[orderStatus]; // Get the mapped step name
    List<String> steps = _getOrderSteps(); // Get steps list

    return mappedStep != null ? steps.indexOf(mappedStep) : -1; // Return index or -1 if not found
  }


// 🔹 List of Order Steps (Formatted with Spaces)
  List<String> _getOrderSteps() {
    return [
      "Prescription Sent",
      "Prescription Verified",
      "Order Confirmed",
      "Items Added",
      "Order Placed",
      "Out for Delivery",
      "Delivered",
    ];
  }
}
