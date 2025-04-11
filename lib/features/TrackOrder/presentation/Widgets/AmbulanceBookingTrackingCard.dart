import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBookingRazorPayService.dart';

class AmbulanceBookingTrackingCard extends StatelessWidget {
  final List<AmbulanceBooking> bookings;

  const AmbulanceBookingTrackingCard({Key? key, required this.bookings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text("No ambulance bookings found."));
    }

    return Column(
      children: bookings.map((booking) {
        final steps = _getSteps(booking.status);
        final currentStepIndex = _getCurrentStepIndex(booking.status);

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
                  _buildHeader(booking),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  _buildTimeline(steps, currentStepIndex),
                  const SizedBox(height: 16),
                  _buildBookingDetails(booking),
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
                  'Ambulance Booking',
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

  Widget _buildHeader(AmbulanceBooking booking) {
    // Directly use the timestamp as it is already a DateTime object
    DateTime timestamp = booking.timestamp;

    // Format the timestamp
    String formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Agency: ${booking.agency?.agencyName ?? "No Agency"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.redAccent),
            const SizedBox(width: 4),
            Text(
              'Requested at: $formattedDate',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent),
            ),
          ],
        ),
      ],
    );
  }

  // Adjust the timeline builder to ensure "Payment Completed" stays visible
  Widget _buildTimeline(List<String> steps, int currentStepIndex) {
    final scrollController = ScrollController();
    final animatedStepIndex = ValueNotifier<int>(-1);

    Future<void> animateSteps() async {
      for (int step = 0; step <= currentStepIndex; step++) {
        await Future.delayed(const Duration(milliseconds: 400));
        animatedStepIndex.value = step;
        if (scrollController.hasClients) {
          scrollController.animateTo(step * 80.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                          color: isCompleted ? Colors.green : (isCurrent ? Colors.orange : Colors.grey)
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

  Widget _buildBookingDetails(AmbulanceBooking booking) {
    // Create an instance of AmbulanceBookingRazorPayService
    final razorpayService = AmbulanceBookingRazorPayService();

    // Check for empty or null values
    if (booking.pickupLocation == null ||
        booking.pickupLocation.trim().isEmpty ||
        booking.dropLocation == null ||
        booking.dropLocation.trim().isEmpty ||
        booking.totalAmount == null ||
        booking.totalAmount == 0.0) {
      return SizedBox.shrink(); // Don't show anything
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vertical Timeline for Pickup and Drop Location
        Row(
          children: [
            // Left Column for timeline
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.location_on, size: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Container(
                  width: 4,
                  height: 40,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.location_on, size: 18, color: Colors.white),
                ),
              ],
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.pickupLocation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  booking.dropLocation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),

        // Estimated Cost and Make Payment Button
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹${booking.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (booking.status == 'WaitingForPayment')
                ElevatedButton(
                  onPressed: () {
                    razorpayService.openPaymentGateway(
                      requestId: booking.requestId,
                      amount: booking.totalAmount,
                      description: "Ambulance Booking #${booking.requestId}",
                      email: "USER_EMAIL",
                      name: "Ambulance Booking",
                      phoneNumber: "USER_PHONE_NUMBER",
                      key: ApiConstants.razorpayApiKey,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  List<String> _getSteps(String status) {
    List<String> steps = [
      "Booking Requested",
      "Agency Accepted",
      "Waiting For Payment",  // This step will dynamically change
      "On the Way",
      "Patient Picked Up",
      "Reached Hospital",
    ];
// If status is paymentCompleted, update the step in the timeline
    if (status == "paymentCompleted") {
      steps[2] = "Payment Completed";  // Modify step 2 if status is "PaymentCompleted"
    }

    return steps;
  }

  int _getCurrentStepIndex(String status) {
    final Map<String, int> statusMap = {
      "pending": 0,
      "accepted": 1,
      "WaitingForPayment": 2, // Both 'WaitingForPayment' and 'paymentCompleted' will point to the same step
      "paymentCompleted": 2,   // Both statuses will point to index 2
      "OnTheWay": 3,
      "PickedUp": 4,
      "Completed": 5,
    };

    return statusMap[status] ?? 0;  // Default to index 0 if the status is unrecognized
  }
}
