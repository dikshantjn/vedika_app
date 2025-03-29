import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';

class TrackingOrderCard extends StatelessWidget {
  final MedicineOrderModel order;

  const TrackingOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = _getOrderSteps();
    final currentStepIndex = 2; // Simulated current step for demo

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color:Colors.grey,
          width: 2, // Border thickness for the circle
        ),
        borderRadius: BorderRadius.circular(12), // Rounded corners for the container
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ], // Add a slight shadow for a "card-like" effect
      ),
      child: SingleChildScrollView( // Scrollable area for the entire content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Divider(), // Horizontal line to divide sections

            const SizedBox(height: 16),
            _buildTimeline(steps, currentStepIndex),
            const SizedBox(height: 16),
            _buildOrderDetails(),
            Divider(), // Horizontal line to divide sections
            if (true) _buildRiderInfo(), // Example condition to show rider info
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${order.orderId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Arriving by 12:30 PM',
            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(List<String> steps, int currentStepIndex) {
    return SizedBox(
      height: 60, // Adjust the height as per your design
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final isCompleted = index < currentStepIndex;
          final isCurrent = index == currentStepIndex;
          final isFuture = index > currentStepIndex;

          Color lineColor = isCompleted ? Colors.green : (isFuture ? Colors.grey.shade300 : Colors.grey.shade300);
          Color indicatorColor = isCompleted
              ? Colors.green
              : (isCurrent ? Colors.blue : Colors.white);
          Color textColor = isCompleted
              ? Colors.green
              : (isCurrent ? Colors.blue : Colors.grey);

          return SizedBox(
            width: 80, // Adjust width to fit your design
            child: TimelineTile(
              axis: TimelineAxis.horizontal,
              alignment: TimelineAlign.start, // Align the timeline to start from the left
              isFirst: index == 0,
              isLast: index == steps.length - 1,
              beforeLineStyle: LineStyle(
                color: lineColor,
                thickness: 2, // Smaller line thickness
              ),
              indicatorStyle: IndicatorStyle(
                width: 20, // Smaller circle
                height: 20, // Smaller circle
                indicator: Container(
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                      width: 2, // Border thickness for the circle
                    ),
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, size: 14, color: Colors.white) // Add checkmark
                      : null,
                ),
              ),
              afterLineStyle: LineStyle(
                color: lineColor,
                thickness: 2, // Smaller line thickness
              ),
              endChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Text(
                      step,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items Ordered',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Displaying the items in a list format
        ListView(
          shrinkWrap: true, // Ensures the list takes only the required space
          physics: const NeverScrollableScrollPhysics(), // Prevents scrolling within the list view
          children: [
            _buildOrderItem('Item 1', 2),
            _buildOrderItem('Item 2', 1),
            _buildOrderItem('Item 3', 3), // Add more items here as necessary
          ],
        ),
        const SizedBox(height: 16),
        // Total amount row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              '₹500.00',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItem(String itemName, int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            itemName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'x$itemCount',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
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
            icon: const Icon(Icons.call, size: 18, color: Colors.green,),
            label: const Text('Call'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green, width: 2), // Border color and thickness
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners for the button
              ),
            ),
          ),
        ],
      ),
    );
  }



  List<String> _getOrderSteps() {
    return [
      'Prescription Sent',
      'Accepted',
      'Items Added',
      'Order Placed',
      'Out for Delivery',
      'Delivered',
    ];
  }
}
