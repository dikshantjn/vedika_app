import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductOrderTrackingCard extends StatefulWidget {
  final List<ProductOrder> orders;

  const ProductOrderTrackingCard({Key? key, required this.orders}) : super(key: key);

  @override
  State<ProductOrderTrackingCard> createState() => _ProductOrderTrackingCardState();
}

class _ProductOrderTrackingCardState extends State<ProductOrderTrackingCard> {
  final Map<String, int> _previousStepIndices = {};

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return const Center(child: Text("No product orders found."));
    }

    return Column(
      children: widget.orders.map((order) {
        final steps = _getSteps();
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
                  'Product Order',
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

  Widget _buildHeader(ProductOrder order) {
    String formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(order.placedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Total Amount: ₹${order.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.redAccent),
            const SizedBox(width: 4),
            Text(
              'Ordered at: $formattedDate',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent),
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

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 80,
                child: TimelineTile(
                  axis: TimelineAxis.horizontal,
                  alignment: TimelineAlign.start,
                  isFirst: index == 0,
                  isLast: index == steps.length - 1,
                  beforeLineStyle: LineStyle(color: isCompleted ? Colors.green : Colors.grey.shade300, thickness: 2),
                  afterLineStyle: LineStyle(color: isCompleted ? Colors.green : Colors.grey.shade300, thickness: 2),
                  indicatorStyle: IndicatorStyle(
                    width: 20,
                    height: 20,
                    indicator: Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : (isCurrent ? Colors.orange : Colors.white),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? Colors.green : (isCurrent ? Colors.orange : Colors.grey),
                      ),
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

  Widget _buildOrderDetails(ProductOrder order) {
    if (order.items == null || order.items!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...order.items!.map((item) {
          final product = item.vendorProduct;
          if (product == null) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                if (product.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.images.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${item.quantity}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.priceAtPurchase.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: ColorPalette.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  List<String> _getSteps() {
    return [
      "Order Placed",
      "Confirmed",
      "Processing",
      "Shipped",
      "Out for Delivery",
      "Delivered",
    ];
  }

  int _getCurrentStepIndex(String status) {
    final Map<String, int> statusMap = {
      "pending": 0,
      "confirmed": 1,
      "processing": 2,
      "shipped": 3,
      "out_for_delivery": 4,
      "delivered": 5,
      "cancelled": -1, // Special case for cancelled orders
    };

    return statusMap[status] ?? 0;
  }
} 