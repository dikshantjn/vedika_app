import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankPaymentService.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import '../../../../../core/constants/colorpalette/ColorPalette.dart';

class BloodRequestDetailsBottomSheet extends StatefulWidget {
  final BloodBankBooking booking;
  final VoidCallback? onCallBloodBank;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onClose;

  const BloodRequestDetailsBottomSheet({
    Key? key,
    required this.booking,
    this.onCallBloodBank,
    this.onRefresh,
    this.onClose,
  }) : super(key: key);

  @override
  State<BloodRequestDetailsBottomSheet> createState() => _BloodRequestDetailsBottomSheetState();
}

class _BloodRequestDetailsBottomSheetState extends State<BloodRequestDetailsBottomSheet> {
  final ScrollController _timelineScrollController = ScrollController();
  final razorpayService = BloodBankPaymentService();
  bool _isRefreshing = false;
  late ValueNotifier<String> _currentStatus;
  late BloodBankViewModel _viewModel;
  late BloodBankBooking _currentBooking;

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
    _currentBooking = widget.booking;
    _currentStatus = ValueNotifier<String>(_currentBooking.status);
    _viewModel = context.read<BloodBankViewModel>();
    
    // Listen to ViewModel changes
    _viewModel.addListener(_onViewModelChanged);
    
    // Initial scroll to current status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStatus();
    });
  }

  void _onViewModelChanged() {
    // Find the updated booking in the ViewModel's bookings list
    final updatedBooking = _viewModel.bookings.firstWhere(
      (b) => b.requestId == _currentBooking.requestId,
      orElse: () => _currentBooking,
    );
    
    if (updatedBooking.status != _currentStatus.value || 
        updatedBooking.totalAmount != _currentBooking.totalAmount ||
        updatedBooking.paymentStatus != _currentBooking.paymentStatus) {
      debugPrint('🩸 Status changed from ${_currentStatus.value} to ${updatedBooking.status}');
      debugPrint('🩸 Total amount changed to: ${updatedBooking.totalAmount}');
      debugPrint('🩸 Payment status changed to: ${updatedBooking.paymentStatus}');
      
      // Update the current status
      _currentStatus.value = updatedBooking.status;
      
      // Update the current booking
      if (mounted) {
        setState(() {
          _currentBooking = updatedBooking;
        });
      }
      
      // Scroll to the current status after a short delay to ensure the UI is updated
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToCurrentStatus();
        }
      });
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _currentStatus.dispose();
    _timelineScrollController.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  void _scrollToCurrentStatus() {
    final index = steps.indexOf(_currentStatus.value);
    if (index > 1) {
      _timelineScrollController.animateTo(
        (index - 1) * 120.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didUpdateWidget(BloodRequestDetailsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.booking.status != widget.booking.status) {
      _currentStatus.value = widget.booking.status;
      _scrollToCurrentStatus();
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Call the refresh callback if provided
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
      
      // Get the latest booking from the ViewModel
      final updatedBooking = _viewModel.bookings.firstWhere(
        (b) => b.requestId == _currentBooking.requestId,
        orElse: () => _currentBooking,
      );
      
      // Update the current booking
      if (mounted) {
        setState(() {
          _currentBooking = updatedBooking;
          _currentStatus.value = updatedBooking.status;
        });
      }
      
      // Scroll to the current status after a short delay
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToCurrentStatus();
        }
      });
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
    final booking = _currentBooking;
    final formattedCreatedAt = DateFormat("dd MMM yyyy, hh:mm a").format(booking.createdAt);
    final isPaymentCompleted = _currentStatus.value == 'PaymentCompleted' || booking.paymentStatus == 'PAID';
    final isWaitingForPayment = _currentStatus.value == 'WaitingForPayment';
    final hasPaymentInfo = booking.totalAmount != null;
    final isCompleted = _currentStatus.value == 'COMPLETED';

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
                  Center(child: Icon(Icons.bloodtype_rounded, size: 32, color: Colors.red)),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      isCompleted ? "Blood Request Completed" : "Ongoing Blood Request",
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

                  if (isCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Blood has been successfully delivered to the patient",
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (hasPaymentInfo && (isWaitingForPayment || isPaymentCompleted))
                    _buildPaymentReceipt(),

                  if (isWaitingForPayment && booking.totalAmount != null && !isPaymentCompleted)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              razorpayService.openPaymentGateway(
                                amount: booking.totalAmount!,
                                name: "Blood Bank Booking Payment",
                                description: "Payment for Blood Bank Booking",
                                bookingId: booking.bookingId!,
                                onPaymentSuccess: (response) async {
                                  await _onRefresh();
                                },
                                onRefreshData: _onRefresh,
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

                  // Only show call button if not completed
                  if (!isCompleted)
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
    return ValueListenableBuilder<String>(
      valueListenable: _currentStatus,
      builder: (context, currentStatus, _) {
        final currentIndex = steps.indexOf(currentStatus);
        debugPrint('🩸 Building timeline with current status: $currentStatus at index: $currentIndex');

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
      },
    );
  }

  Widget _buildPaymentReceipt() {
    final booking = _currentBooking;
    final paymentStatus = booking.paymentStatus;
    final isPaymentCompleted = _currentStatus.value == 'PaymentCompleted' || paymentStatus == 'PAID';

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
              const Text("Payment Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (isPaymentCompleted)
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
                      Text("PAID", style: TextStyle(color: Colors.green, fontSize: 12)),
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
                      Text("PENDING", style: TextStyle(color: Colors.orange, fontSize: 12)),
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
