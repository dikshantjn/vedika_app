import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBookingRazorPayService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/viewmodel/AmbulanceSearchViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class AmbulanceSearchPage extends StatefulWidget {
  @override
  _AmbulanceSearchPageState createState() => _AmbulanceSearchPageState();
}

class _AmbulanceSearchPageState extends State<AmbulanceSearchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;
  late AmbulanceSearchViewModel _viewModel;
  GoogleMapController? _mapController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, 
      duration: Duration(seconds: 1)
    )..repeat(reverse: true);
    
    // Initialize view model
    _viewModel = AmbulanceSearchViewModel(context);
    _viewModel.initialize();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStep();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Nearby Ambulance Services"),
          backgroundColor: ColorPalette.primaryColor,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        drawer: DrawerMenu(),
      body: ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<AmbulanceSearchViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // Map takes full screen
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    viewModel.mapController = controller;
                    viewModel.getUserLocation();
                  },
                  initialCameraPosition: CameraPosition(
                    target: viewModel.currentPosition ?? LatLng(20.5937, 78.9629),
                    zoom: 14,
                  ),
                  markers: viewModel.markers,
                  myLocationEnabled: viewModel.isLocationEnabled,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                ),
                // Bottom section overlays the map
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _isLoading 
                    ? _buildLoadingBottomSheet()
                    : viewModel.ambulanceBookings.isNotEmpty
                        ? _buildOngoingBookingBottomSheet(viewModel)
                        : _buildBottomSection(viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSection(AmbulanceSearchViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Need an Ambulance Urgently?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Call an ambulance now for immediate assistance.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _animationController.value,
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  // Prevent multiple calls by checking loading state
                  if (_isLoading) return;
                  
                  // Show loading state in bottom sheet
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    // Call ambulance
                    bool success = await viewModel.callNearestAmbulance();

                    if (success) {
                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ambulance booking successful!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // Show error message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to book ambulance. Please try again."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } finally {
                    // Reset loading state regardless of success/failure
                    if (context.mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Call Ambulance", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBottomSheet() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            "Finding nearest ambulance...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please wait while we locate the nearest available ambulance",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingBookingBottomSheet(AmbulanceSearchViewModel viewModel) {
    final razorpayService = AmbulanceBookingRazorPayService();
    final booking = viewModel.ambulanceBookings.first;

    final steps = viewModel.getSteps(booking.status ?? "pending");
    final currentStepIndex = viewModel.getCurrentStepIndex(booking.status ?? "pending");

    final isPaymentCompleted = booking.status == "paymentCompleted";
    final isWaitingForPayment = booking.status == "WaitingForPayment";
    final isCompleted = booking.status == "Completed";

    // If booking is completed, show completion message
    if (isCompleted) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add close button at the top
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () {
                  viewModel.clearBookings();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Service Completed",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Your ambulance service has been completed successfully. Thank you for choosing our service.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    viewModel.clearBookings();
                  },
                  icon: Icon(Icons.close),
                  label: Text("Close"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add any additional action here if needed
                    viewModel.clearBookings();
                  },
                  icon: Icon(Icons.star_outline),
                  label: Text("Rate Service"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final hasPaymentInfo = booking.totalAmount != null &&
        booking.totalDistance != null &&
        booking.costPerKm != null &&
        booking.baseCharge != null;

    final formattedDate = booking.timestamp != null
        ? DateFormat("dd MMMM yyyy hh:mm a").format(booking.timestamp)
        : "N/A";

    // Check if both pickup and drop locations are available
    final hasValidLocations = booking.pickupLocation != null && 
                            booking.pickupLocation!.isNotEmpty && 
                            booking.dropLocation != null && 
                            booking.dropLocation!.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.fetchActiveAmbulanceBookings();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add close button at the top
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () {
                    viewModel.clearBookings();
                  },
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 32, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      "Ongoing Ambulance Booking",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.apartment_rounded, size: 20, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.agency?.agencyName ?? "Unknown Agency",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Only show location timeline if both locations are available
              if (hasValidLocations) ...[
                _buildHorizontalPickupDropTimeline(booking),
                SizedBox(height: 10),
              ],

              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Date: $formattedDate", style: TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
              SizedBox(height: 20),

              _buildTimeline(steps, currentStepIndex),
              SizedBox(height: 20),

              if (hasPaymentInfo && (isWaitingForPayment || isPaymentCompleted || booking.isPaymentBypassed))
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: booking.isPaymentBypassed ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: booking.isPaymentBypassed ? Colors.blue.shade200 : Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (booking.isPaymentBypassed)
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Your payment has been waived for this ambulance service.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                      Row(
                        children: [
                            Text(
                              "Payment Receipt",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          Spacer(),
                          if (isPaymentCompleted)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text("Payment Completed", style: TextStyle(color: Colors.green, fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildReceiptRow("Base Charge", "₹${booking.baseCharge!.toStringAsFixed(2)}"),
                      _buildReceiptRow("Distance", "${booking.totalDistance} km"),
                      _buildReceiptRow("Rate per km", "₹${booking.costPerKm!.toStringAsFixed(2)}"),
                      Divider(height: 24, thickness: 1),
                      _buildReceiptRow("Total Amount", "₹${booking.totalAmount!.toStringAsFixed(2)}", bold: true),
                      ],
                    ],
                  ),
                ),

              SizedBox(height: 12),

              if (isWaitingForPayment)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      razorpayService.openPaymentGateway(
                        requestId: booking.requestId,
                        amount: booking.totalAmount,
                        description: "Ambulance Booking #${booking.requestId}",
                        email: "USER_EMAIL",
                        name: "Ambulance Booking",
                        phoneNumber: "USER_PHONE_NUMBER",
                        key: ApiConstants.razorpayApiKey,
                        onPaymentSuccess: () async {
                          await viewModel.fetchActiveAmbulanceBookings();
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

              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final contactNumber = booking.agency?.contactNumber ?? "";
                    final Uri phoneUri = Uri(scheme: 'tel', path: contactNumber);
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Unable to launch phone dialer")),
                      );
                    }
                  },
                  icon: Icon(Icons.call),
                  label: Text("Call Agency"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Receipt row helper
  Widget _buildReceiptRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildHorizontalPickupDropTimeline(AmbulanceBooking booking) {
    return SizedBox(
      height: 100, // 🛠️ adjust as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.manual,
                lineXY: 0.3,
                isFirst: true,
                indicatorStyle: IndicatorStyle(
                  color: Colors.red,
                  iconStyle: IconStyle(iconData: Icons.location_on_rounded, color: Colors.white),
                ),
                beforeLineStyle: LineStyle(color: Colors.grey.shade400, thickness: 2),
                afterLineStyle: LineStyle(color: Colors.grey.shade400, thickness: 2),
                endChild: Padding(
                  padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Pickup", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      SizedBox(height: 4),
                      Text(
                        booking.pickupLocation ?? "N/A",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.manual,
                lineXY: 0.3,
                isLast: true,
                indicatorStyle: IndicatorStyle(
                  color: Colors.green,
                  iconStyle: IconStyle(iconData: Icons.local_hospital, color: Colors.white),
                ),
                beforeLineStyle: LineStyle(color: Colors.grey.shade400, thickness: 2),
                endChild: Padding(
                  padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Drop", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      SizedBox(height: 4),
                      Text(
                        booking.dropLocation ?? "N/A",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Adjust the timeline builder to ensure "Payment Completed" stays visible
  Widget _buildTimeline(List<String> steps, int currentStepIndex) {
    final scrollController = ScrollController();
    final animatedStepIndex = ValueNotifier<int>(currentStepIndex);  // Initialize with current step

    // Update the animated index when currentStepIndex changes
    void updateAnimatedIndex() {
      if (animatedStepIndex.value != currentStepIndex) {
        animatedStepIndex.value = currentStepIndex;
        if (scrollController.hasClients) {
          scrollController.animateTo(
            currentStepIndex * 80.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut
          );
        }
      }
    }

    // Call updateAnimatedIndex when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) => updateAnimatedIndex());

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

  void _scrollToCurrentStep() {
    if (_scrollController.hasClients) {
      final screenWidth = MediaQuery.of(context).size.width;
      final stepWidth = screenWidth / 4;
      final booking = _viewModel.ambulanceBookings.firstOrNull;
      if (booking != null) {
        final currentStepIndex = _viewModel.getCurrentStepIndex(booking.status);
        // Calculate scroll position to center the current step
        double scrollPosition;
        if (currentStepIndex >= 3) { // From "On the Way" onwards
          scrollPosition = (currentStepIndex * stepWidth) - (screenWidth / 2) + (stepWidth / 2);
        } else {
          scrollPosition = 0; // Keep at start for earlier steps
        }
        
        _scrollController.animateTo(
          scrollPosition,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}
