import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/HospitalSearchViewModel.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/hospital/data/service/RazorpayService.dart';
import '../../../../../core/constants/colorpalette/ColorPalette.dart';

class OngoingBookingBottomSheet extends StatefulWidget {
  final BedBooking booking;
  final VoidCallback? onCallHospital;
  final Future<void> Function()? onRefresh;

  const OngoingBookingBottomSheet({
    Key? key,
    required this.booking,
    this.onCallHospital,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<OngoingBookingBottomSheet> createState() => _OngoingBookingBottomSheetState();
}

class _OngoingBookingBottomSheetState extends State<OngoingBookingBottomSheet> {
  final ScrollController _timelineScrollController = ScrollController();
  bool _isRefreshing = false;
  final _razorpayService = RazorpayService();

  final steps = [
    'pending',
    'accepted',
    'WaitingForPayment',
    'Completed',
  ];

  final displayNames = {
    'pending': 'Pending',
    'accepted': 'Accepted',
    'WaitingForPayment': 'Waiting for Payment',
    'Completed': 'Completed',
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

    // Set up Razorpay callbacks
    _razorpayService.onPaymentSuccess = (response) async {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    };

    _razorpayService.onPaymentError = (response) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

    _razorpayService.onPaymentCancelled = (response) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled by user'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _razorpayService.clear();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
      
      final viewModel = Provider.of<HospitalSearchViewModel>(context, listen: false);
      await viewModel.loadUserBookings(context);
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error refreshing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final formattedCreatedAt = DateFormat("dd MMM yyyy, hh:mm a").format(booking.bookingDate);
    final isPaymentCompleted = steps.indexOf(booking.status) >= steps.indexOf('Completed');
    final isWaitingForPayment = booking.status == 'WaitingForPayment';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isRefreshing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
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
                  Center(child: Icon(Icons.local_hospital, size: 32, color: ColorPalette.primaryColor)),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Ongoing Bed Booking",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInfoRow(Icons.person, "Patient Name", booking.user.name ?? "Not Mentioned"),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.bed, "Bed Type", booking.bedType),
                  const SizedBox(height: 24),

                  _buildStatusTimeline(),
                  const SizedBox(height: 20),

                  if (isWaitingForPayment || isPaymentCompleted)
                    _buildPaymentReceipt(),

                  if (isWaitingForPayment)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _razorpayService.openPaymentGateway(
                                (booking.price - booking.paidAmount).toInt(),
                                'YOUR_RAZORPAY_KEY', // Replace with your Razorpay key
                                'Bed Booking Payment',
                                'Payment for bed booking at ${booking.hospital.name}',
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
                        SizedBox(height: 12),
                      ],
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onCallHospital,
                      icon: const Icon(Icons.call),
                      label: const Text("Call Hospital"),
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
              if (booking.paymentStatus == "completed")
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
              else if (booking.paymentStatus == "pending")
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
          _buildReceiptRow("Total Amount", "₹${booking.price.toStringAsFixed(2)}", bold: true),
          _buildReceiptRow("Paid Amount", "₹${booking.paidAmount.toStringAsFixed(2)}"),
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