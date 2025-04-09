import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
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
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(booking),
                  const Divider(),
                  _buildTimeline(steps, currentStepIndex),
                  const SizedBox(height: 16),
                  _buildBookingDetails(booking),
                  if (booking.status == "OnTheWay" || booking.status == "PickedUp")
                    _buildDriverInfo(booking),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: const Text(
                  'Ambulance Booking',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
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
        Text('Booking ID: ${booking.requestId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agency Name section
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text(
                booking.agency?.agencyName ?? 'No Agency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Vertical Timeline for Pickup and Drop Location
        Row(
          children: [
            // Left Column for timeline
            Column(
              children: [
                // Start point (Pickup Location)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.location_on, size: 18, color: Colors.white),
                ),
                SizedBox(height: 10), // Spacer between the circles
                // Line connecting points
                Container(
                  width: 4,
                  height: 40, // Length of the line
                  color: Colors.grey[300],
                ),
                SizedBox(height: 10),
                // End point (Drop Location)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.location_on, size: 18, color: Colors.white),
                ),
              ],
            ),

            // Right Column for text descriptions
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
                SizedBox(height: 20), // Spacer between Pickup and Drop location text
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

        // Estimated Cost and Make Payment Button in a Row
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute items evenly
            children: [
              Text(
                'Total: ₹${booking.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18, // Reduced font size for Total Amount
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              // Make Payment Button if status is WaitingForPayment
              if (booking.status == 'WaitingForPayment')
                ElevatedButton(
                  onPressed: () {
                    razorpayService.openPaymentGateway(// Replace with the user's email
                      requestId: booking.requestId,
                      amount: booking.totalAmount,
                      description:"Ambulance Booking #${booking.requestId}",
                      email: "USER_EMAIL",
                      name: "Ambulance Booking",
                      phoneNumber: "USER_PHONE_NUMBER",
                      key: ApiConstants.razorpayApiKey
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14), // Reduced button padding
                  ),
                  child: Text(
                    'Pay Now', // Updated button text for better clarity
                    style: TextStyle(
                      fontSize: 14, // Reduced font size for the button text
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


  Widget _buildDriverInfo(AmbulanceBooking booking) {
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
            child: Icon(Icons.local_hospital, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Ambulance Driver', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Driver Name', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement call
            },
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
