import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';

class NewMedicineOrderTrackingCard extends StatefulWidget {
  final TrackOrderViewModel viewModel;

  const NewMedicineOrderTrackingCard({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<NewMedicineOrderTrackingCard> createState() => _NewMedicineOrderTrackingCardState();
}

class _NewMedicineOrderTrackingCardState extends State<NewMedicineOrderTrackingCard> {
  final Map<String, int> _previousStepIndices = {};
  final Map<String, bool> _expandedOrders = {};

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.activeMedicineDeliveryOrders.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no orders
    }

    return Column(
      children: widget.viewModel.activeMedicineDeliveryOrders.map((order) {
        final steps = _getOrderSteps();
        final currentStepIndex = _getCurrentStepIndex(order.status);

        // Store the previous step index if it doesn't exist
        if (!_previousStepIndices.containsKey(order.orderId)) {
          _previousStepIndices[order.orderId] = currentStepIndex;
        }

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
                  _buildOrderDetails(order),
                  if (order.status == "out_for_delivery")
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
                  'Medicine Delivery',
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

  Widget _buildHeader(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Order ID: ${order.orderId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Show vendor name
        if (order.vendor != null) ...[
          Text(
            'Vendor: ${order.vendor!.name}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueAccent),
          ),
          const SizedBox(height: 4),
        ],
        // Show created date
        Text(
          'Ordered on: ${widget.viewModel.formatDeliveryDate(order.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildOrderDetails(Order order) {
    final bool isExpanded = _expandedOrders[order.orderId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible Header
        InkWell(
          onTap: () {
            setState(() {
              _expandedOrders[order.orderId] = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _getStatusDisplayText(order.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),

        // Expanded Content
        if (isExpanded) ...[
          const SizedBox(height: 12),

          // Medicines List
          if (order.medicines != null && order.medicines!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Medicines',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...order.medicines!.map((med) {
                    final double itemTotal = med.quantity * med.price;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              med.medicineName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          Text(
                            'Qty: ${med.quantity} × ₹${med.price.toStringAsFixed(2)} = ₹${itemTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Payment Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Billing Breakdown',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildBillingRow('Subtotal', order.subtotal),
                if (order.discount > 0) ...[
                  const SizedBox(height: 6),
                  _buildBillingRow(
                    'Discount (${order.discount.toStringAsFixed(1)}%)',
                    -_calculateDiscountAmount(order),
                    isDiscount: true,
                  ),
                ],
                if (order.gst > 0) ...[
                  const SizedBox(height: 6),
                  _buildBillingRow(
                    'GST (${order.gst.toStringAsFixed(0)}%)',
                    _calculateGSTAmount(order),
                  ),
                ],
                const SizedBox(height: 6),
                _buildBillingRow('Platform Fee', order.platformFee),
                const SizedBox(height: 6),
                _buildBillingRow('Delivery Charge', order.deliveryCharges),
                const SizedBox(height: 8),
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Go to Cart for pending payment (always visible as primary action)
        if (order.status == "waiting_for_payment") ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToCart(),
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: const Text('Go to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
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

  void _navigateToCart() {
    debugPrint("🛒 Navigating to cart");
    Navigator.pushNamed(context, AppRoutes.newCartScreen);
  }

  int _getCurrentStepIndex(String orderStatus) {
    Map<String, int> statusMapping = {
      "pending": 0,
      "waiting_for_payment": 1,
      "payment_completed": 2,
      "ready_to_pickup": 2, // Treat as payment_completed
      "out_for_delivery": 3,
      "delivered": 4,
    };

    return statusMapping[orderStatus] ?? 0;
  }

  List<String> _getOrderSteps() {
    return [
      "Pending",
      "Waiting for Payment",
      "Payment Completed",
      "Out for Delivery",
      "Delivered",
    ];
  }

  String _getStatusDisplayText(String status) {
    Map<String, String> displayTexts = {
      "pending": "Pending",
      "waiting_for_payment": "Waiting for Payment",
      "payment_completed": "Payment Completed",
      "ready_to_pickup": "Payment Completed", // Show as Payment Completed
      "out_for_delivery": "Out for Delivery",
      "delivered": "Delivered",
    };

    return displayTexts[status] ?? status;
  }

  Color _getStatusColor(String status) {
    Map<String, Color> statusColors = {
      "pending": Colors.orange,
      "waiting_for_payment": Colors.red,
      "payment_completed": Colors.blue,
      "ready_to_pickup": Colors.blue, // Same color as payment_completed
      "out_for_delivery": Colors.purple,
      "delivered": Colors.green,
    };

    return statusColors[status] ?? Colors.grey;
  }

  Widget _buildBillingRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _calculateDiscountAmount(Order order) {
    final double subtotal = order.subtotal;
    if (subtotal <= 0) return 0.0;

    final double discountPercent = order.discount;
    if (discountPercent > 0) {
      return subtotal * (discountPercent / 100);
    }
    return 0.0;
  }

  double _calculateGSTAmount(Order order) {
    final double subtotal = order.subtotal;
    if (subtotal <= 0) return 0.0;

    final double discountAmount = _calculateDiscountAmount(order);
    final double amountAfterDiscount = subtotal - discountAmount;

    final double gstPercent = order.gst > 0 ? order.gst : 18.0;
    return amountAfterDiscount * (gstPercent / 100);
  }
}
