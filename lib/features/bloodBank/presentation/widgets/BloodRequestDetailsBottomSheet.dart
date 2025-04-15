import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankPaymentService.dart';
import '../../../../../core/constants/colorpalette/ColorPalette.dart';

class BloodRequestDetailsBottomSheet extends StatefulWidget {
  final BloodBankBooking booking;
  final VoidCallback? onCallBloodBank;

  const BloodRequestDetailsBottomSheet({
    Key? key,
    required this.booking,
    this.onCallBloodBank,
  }) : super(key: key);

  @override
  State<BloodRequestDetailsBottomSheet> createState() => _BloodRequestDetailsBottomSheetState();
}

class _BloodRequestDetailsBottomSheetState extends State<BloodRequestDetailsBottomSheet> {
  final ScrollController _timelineScrollController = ScrollController();
  final razorpayService = BloodBankPaymentService();

  final steps = [
    'PENDING',
    'CONFIRMED',
    'WaitingForPayment',
    'PaymentCompleted',
    'WaitingForPickup',
    'COMPLETED',
  ];

  final displayNames = {
    'PENDING': 'Pending',
    'CONFIRMED': 'Confirmed',
    'WaitingForPayment': 'Waiting for Payment',
    'PaymentCompleted': 'Payment Completed',
    'WaitingForPickup': 'Waiting for Pickup',
    'COMPLETED': 'Completed',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = steps.indexOf(widget.booking.status);
      if (index > 1) {
        _timelineScrollController.animateTo(
          (index - 1) * 120.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // This method will be triggered when the user performs the swipe-to-refresh action
  Future<void> _onRefresh() async {
    // Logic for refreshing the content, like re-fetching the booking details or other data
    // Example: You could call a method in your view model or service to fetch updated data
    // await widget.viewModel.fetchBookingDetails(widget.booking.bookingId);
    setState(() {
      // You can add any changes to state here that would reflect the updated data
    });
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final formattedCreatedAt = DateFormat("dd MMM yyyy, hh:mm a").format(booking.createdAt);
    final isPaymentCompleted = steps.indexOf(booking.status) >= steps.indexOf('PaymentCompleted');
    final isWaitingForPayment = booking.status == 'WaitingForPayment';

    final hasPaymentInfo = booking.totalAmount != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh, // Trigger the refresh function
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Icon(Icons.bloodtype_rounded, size: 32, color: Colors.red)),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Ongoing Blood Request",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInfoRow(Icons.person, "Customer Name", booking.user.name ?? "Not Mentioned"),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.bloodtype_outlined, "Blood Types", booking.bloodType.join(", ")),
                  const SizedBox(height: 24),

                  _buildStatusTimeline(),
                  const SizedBox(height: 20),

                  if (hasPaymentInfo && (isWaitingForPayment || isPaymentCompleted))
                    _buildPaymentReceipt(),

                  if (isWaitingForPayment)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          razorpayService.openPaymentGateway(
                            amount: booking.totalAmount,
                            name: "Blood Bank Booking Payment",
                            description: "Payment for Blood Bank Booking",
                            bookingId: booking.bookingId!,
                            onPaymentSuccess: () async {
                              // await widget.viewModel.fetchBookingsForVendor(); // Re-fetch after payment
                            },
                          );
                        },
                        icon: Icon(Icons.payment_outlined),
                        label: Text("Pay Now"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: BorderSide(color: Colors.teal),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                  if (isPaymentCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onCallBloodBank,
                        icon: const Icon(Icons.call),
                        label: const Text("Call Blood Bank"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -50,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 24, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline() {
    final currentIndex = steps.indexOf(widget.booking.status);

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _timelineScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final status = steps[index];
          final isDone = index <= currentIndex;
          final isLast = index == steps.length - 1;

          return Container(
            width: 120,
            child: TimelineTile(
              axis: TimelineAxis.horizontal,
              alignment: TimelineAlign.center,
              isFirst: index == 0,
              isLast: isLast,
              beforeLineStyle: LineStyle(
                color: isDone ? Colors.green : Colors.grey.shade300,
                thickness: 2,
              ),
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: isDone ? Colors.green : Colors.grey.shade300,
                iconStyle: IconStyle(
                  iconData: Icons.check,
                  color: Colors.white,
                ),
              ),
              endChild: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    displayNames[status] ?? status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDone ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentReceipt() {
    final booking = widget.booking;
    final paymentStatus = booking.paymentStatus; // Directly get paymentStatus

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Payment Receipt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (paymentStatus == "PAID")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text("Payment Completed", style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                )
              else if (paymentStatus == "PENDING")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text("Payment Pending", style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 24, thickness: 1),
          _buildReceiptRow("Total Amount", "₹${booking.totalAmount?.toStringAsFixed(2) ?? '--'}", bold: true),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: ColorPalette.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
