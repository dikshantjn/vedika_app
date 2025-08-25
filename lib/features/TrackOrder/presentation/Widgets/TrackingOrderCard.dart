import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';

class TrackingOrderCard extends StatefulWidget {
  final TrackOrderViewModel viewModel;

  const TrackingOrderCard({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<TrackingOrderCard> createState() => _TrackingOrderCardState();
}

class _TrackingOrderCardState extends State<TrackingOrderCard> {
  final Map<String, int> _previousStepIndices = {};

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.orders.isEmpty) {
      return const Center(child: Text("No orders found."));
    }

    return Column(
      children: widget.viewModel.orders.map((order) {
        final steps = _getOrderSteps();
        final currentStepIndex = _getCurrentStepIndex(order.orderStatus);

        // Store the previous step index if it doesn't exist
        if (!_previousStepIndices.containsKey(order.orderId)) {
          _previousStepIndices[order.orderId] = currentStepIndex;
        }

        List<CartModel> cartItems = widget.viewModel.orderItems[order.orderId] ?? [];

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ColorPalette.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(order),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  _buildTimeline(steps, currentStepIndex, order.orderId),
                  const SizedBox(height: 16),
                  _buildOrderDetails(cartItems, order.totalAmount),
                  if (order.orderStatus == "OutForDelivery") 
                    Column(
                      children: [
                        Divider(color: Colors.grey.shade200),
                        _buildRiderInfo(),
                      ],
                    ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Text(
                  'Medicine Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
              'Arriving by ${widget.viewModel.formatDeliveryDate(order.estimatedDeliveryDate)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueAccent),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(List<String> steps, int currentStepIndex, String orderId) {
    final scrollController = ScrollController();
    final animatedStepIndex = ValueNotifier<int>(_previousStepIndices[orderId] ?? currentStepIndex);

    Future<void> animateSteps() async {
      final previousIndex = _previousStepIndices[orderId] ?? currentStepIndex;
      if (previousIndex != currentStepIndex) {
        // Only animate if the status has changed
        for (int step = previousIndex; step <= currentStepIndex; step++) {
          await Future.delayed(const Duration(milliseconds: 400));
          animatedStepIndex.value = step;
          
          // Calculate scroll position to ensure the current step is visible
          if (scrollController.hasClients) {
            // Calculate the position to scroll to
            double scrollPosition = step * 80.0; // 80 is the width of each step
            
            // Get the screen width
            double screenWidth = MediaQuery.of(context).size.width;
            
            // Calculate how many steps can fit on the screen
            int visibleSteps = (screenWidth / 80).floor();
            
            // Adjust scroll position to center the current step if possible
            if (step >= visibleSteps) {
              scrollPosition = scrollPosition - (screenWidth / 2) + 40; // 40 is half of step width
            }
            
            // Ensure we don't scroll past the end
            double maxScrollPosition = (steps.length * 80.0) - screenWidth;
            if (maxScrollPosition >= 0.0) {
              scrollPosition = scrollPosition.clamp(0.0, maxScrollPosition);
            } else {
              scrollPosition = 0.0; // If max is negative, just scroll to beginning
            }
            
            // Animate to the calculated position
            scrollController.animateTo(
              scrollPosition,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
        // Update the previous index for next time
        _previousStepIndices[orderId] = currentStepIndex;
      } else {
        // If no change, just set to current index and ensure it's visible
        animatedStepIndex.value = currentStepIndex;
        if (scrollController.hasClients) {
          double scrollPosition = currentStepIndex * 80.0;
          double screenWidth = MediaQuery.of(context).size.width;
          int visibleSteps = (screenWidth / 80).floor();
          
          if (currentStepIndex >= visibleSteps) {
            scrollPosition = scrollPosition - (screenWidth / 2) + 40;
          }
          
          // Ensure the max scroll position is valid (greater than or equal to min)
          double maxScrollPosition = (steps.length * 80.0) - screenWidth;
          if (maxScrollPosition >= 0.0) {
            scrollPosition = scrollPosition.clamp(0.0, maxScrollPosition);
          } else {
            scrollPosition = 0.0; // If max is negative, just scroll to beginning
          }
          
          scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => animateSteps());

    return SizedBox(
      height: 80,
      child: ValueListenableBuilder<int>(
        valueListenable: animatedStepIndex,
        builder: (context, animatedIndex, _) {
          return ListView.builder(
            controller: scrollController,
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
        if (widget.viewModel.orders.first.paymentStatus == 'PAID') ...[
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
