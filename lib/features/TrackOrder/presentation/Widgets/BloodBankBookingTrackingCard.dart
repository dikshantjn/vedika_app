import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankBookingService.dart';

class BloodBankBookingTrackingCard extends StatelessWidget {
  final List<BloodBankBooking> bookings;

  const BloodBankBookingTrackingCard({Key? key, required this.bookings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text("No blood bank bookings found."));
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
                  color: Colors.red,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Text(
                  'Blood Bank Booking',
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

  Widget _buildHeader(BloodBankBooking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Agency: ${booking.agency?.agencyName ?? "No Agency"}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Address: ${booking.agency?.completeAddress ?? "No Address"}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        if (booking.agency?.phoneNumber != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                booking.agency!.phoneNumber,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.bloodtype, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Blood Type: ${booking.bloodType.join(", ")}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

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

  Widget _buildBookingDetails(BloodBankBooking booking) {
    final currentStepIndex = _getCurrentStepIndex(booking.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentStepIndex >= 2) ...[
          // Payment Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Unit Price:', style: TextStyle(color: Colors.grey[600])),
                    Text('₹${booking.pricePerUnit.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Units:', style: TextStyle(color: Colors.grey[600])),
                    Text('${booking.units}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Fees:', style: TextStyle(color: Colors.grey[600])),
                    Text('₹${booking.deliveryFees.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GST:', style: TextStyle(color: Colors.grey[600])),
                    Text('₹${(booking.totalAmount * (booking.gst / 100)).toStringAsFixed(2)}'),
                  ],
                ),
                if (booking.discount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount:', style: TextStyle(color: Colors.grey[600])),
                      Text('-₹${booking.discount.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount:', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    Text(
                      '₹${booking.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Payment Status or Pay Now Button
          if (booking.paymentStatus == 'WaitingForPayment')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement payment logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else if (booking.paymentStatus == 'paymentCompleted')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  List<String> _getSteps(String status) {
    List<String> steps = [
      "Booking Requested",
      "Agency Accepted",
      "Waiting For Payment",
      "Payment Completed",
      "Waiting For Pickup",
      "Completed",
    ];

    return steps;
  }

  int _getCurrentStepIndex(String status) {
    final Map<String, int> statusMap = {
      "PENDING": 0,
      "CONFIRMED": 1,
      "WaitingForPayment": 2,
      "PaymentCompleted": 3,
      "WaitingForPickup": 4,
      "COMPLETED": 5,
    };

    return statusMap[status] ?? 0;
  }
}