import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewmodels/BookingsViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestProcessScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingsContent extends StatefulWidget {
  final int? initialTab;
  
  const BookingsContent({
    Key? key,
    this.initialTab,
  }) : super(key: key);

  @override
  State<BookingsContent> createState() => _BookingsContentState();
}

class _BookingsContentState extends State<BookingsContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BookingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize the ViewModel
    _viewModel = BookingsViewModel();
    _loadData();

    // Set initial tab if provided
    if (widget.initialTab != null) {
      _tabController.animateTo(widget.initialTab!);
    }

    // Add listener for booking updates
    _viewModel.addListener(_onBookingUpdated);
  }

  void _onBookingUpdated() {
    if (mounted) {
      setState(() {
        // The UI will automatically refresh when the ViewModel notifies listeners
      });
    }
  }
  
  Future<void> _loadData() async {
    await _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onBookingUpdated);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Column(
        children: [
          Container(
            color: LabTestColorPalette.backgroundPrimary,
            child: TabBar(
              controller: _tabController,
              labelColor: LabTestColorPalette.primaryBlue,
              unselectedLabelColor: LabTestColorPalette.textSecondary,
              indicatorColor: LabTestColorPalette.primaryBlue,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Today'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BookingListView(type: 'upcoming'),
                BookingListView(type: 'today'),
                BookingListView(type: 'past'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingListView extends StatelessWidget {
  final String type;

  const BookingListView({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: LabTestColorPalette.primaryBlue,
            ),
          );
        }

        // Check if there is a global error message
        if (viewModel.errorMessage != null) {
          // For any error, show the empty state with appropriate message
          return _buildEmptyState(type);
        }

        final List<LabTestBooking> bookings;
        switch (type) {
          case 'upcoming':
            bookings = viewModel.upcomingBookings;
            break;
          case 'today':
            bookings = viewModel.todayBookings;
            break;
          case 'past':
            bookings = viewModel.pastBookings;
            break;
          default:
            bookings = [];
        }

        if (bookings.isEmpty) {
          return _buildEmptyState(type);
        }

        return RefreshIndicator(
          onRefresh: viewModel.fetchBookings,
          color: LabTestColorPalette.primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: bookings[index],
                type: type,
                onAccept: () => viewModel.acceptBooking(bookings[index].bookingId!),
                onProcess: () => viewModel.processBooking(bookings[index].bookingId!),
              );
            },
          ),
        );
      },
    );
  }
  
  String _getEmptyMessage(String type) {
    switch (type) {
      case 'upcoming':
        return 'No pending bookings found.\nNew booking requests will appear here.';
      case 'today':
        return 'No bookings for today.\nAccepted bookings that need to be processed will appear here.';
      case 'past':
        return 'No completed bookings yet.\nBookings that have been completed will appear here.';
      default:
        return 'No bookings found';
    }
  }

  Widget _buildEmptyState(String type) {
    IconData icon;
    Color iconColor;
    String message = _getEmptyMessage(type);

    switch (type) {
      case 'upcoming':
        icon = Icons.event_busy_outlined;
        iconColor = Colors.orange.withOpacity(0.5);
        break;
      case 'today':
        icon = Icons.today_outlined;
        iconColor = Colors.blue.withOpacity(0.5);
        break;
      case 'past':
        icon = Icons.history_outlined;
        iconColor = Colors.green.withOpacity(0.5);
        break;
      default:
        icon = Icons.event_busy_outlined;
        iconColor = Colors.grey.withOpacity(0.5);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: iconColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          if (type == 'upcoming')
            Text(
              'You will be notified when new bookings arrive',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final LabTestBooking booking;
  final String type;
  final VoidCallback onAccept;
  final VoidCallback onProcess;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.type,
    required this.onAccept,
    required this.onProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookingsViewModel>(context);
    final bool isLoading = viewModel.isLoading;
    final String? errorMessage = viewModel.errorMessage;
    
    // Show a success message if needed
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: LabTestColorPalette.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
    
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: LabTestColorPalette.borderLight),
      ),
      child: InkWell(
        onTap: () => _showDetailBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LabTestColorPalette.primaryBlueLightest,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(booking.user?.name ?? ""),
                        style: const TextStyle(
                          color: LabTestColorPalette.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.user?.name ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: LabTestColorPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.user?.phoneNumber ?? "",
                          style: const TextStyle(
                            color: LabTestColorPalette.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: LabTestColorPalette.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "${booking.bookingDate} | ${booking.bookingTime}",
                                style: const TextStyle(
                                  color: LabTestColorPalette.textSecondary,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.bookingStatus ?? "").withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      booking.bookingStatus ?? "Unknown",
                      style: TextStyle(
                        color: _getStatusColor(booking.bookingStatus ?? ""),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: LabTestColorPalette.borderLight),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoPill(
                    icon: Icons.science_outlined,
                    label: (booking.selectedTests?.length ?? 0) > 1
                        ? "${booking.selectedTests?.length ?? 0} Tests"
                        : booking.selectedTests?.first ?? "No tests",
                  ),
                  const SizedBox(width: 8),
                  _buildInfoPill(
                    icon: Icons.location_on_outlined,
                    label: booking.homeCollectionRequired == true ? "Home Collection" : "At Center",
                  ),
                  const Spacer(),
                  Text(
                    "₹${booking.totalAmount?.toStringAsFixed(0) ?? '0'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: LabTestColorPalette.textPrimary,
                    ),
                  ),
                ],
              ),
              if (booking.prescriptionUrl != null && booking.prescriptionUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: LabTestColorPalette.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => _openPrescription(booking.prescriptionUrl!),
                          child: const Text(
                            "View Prescription",
                            style: TextStyle(
                              color: LabTestColorPalette.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (type != 'past') const SizedBox(height: 16),
              if (type != 'past') _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  void _openPrescription(String url) async {
    // If the URL is a Firebase Storage URL, open it directly
    if (url.startsWith('https://')) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    } else {
      // If it's a local path, show a message that the image is stored locally
      print('Local file path: $url');
      // In a real app, you might want to handle this differently
    }
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: LabTestColorPalette.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: LabTestColorPalette.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: LabTestColorPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    
    final nameParts = name.split(" ");
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();
    
    return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
  }

  Widget _buildActionButton(BuildContext context) {
    final viewModel = Provider.of<BookingsViewModel>(context);
    final bool isLoading = viewModel.isLoading;
    
    if (type == 'upcoming') {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onAccept,
          style: OutlinedButton.styleFrom(
            foregroundColor: LabTestColorPalette.primaryBlue,
            side: BorderSide(
              color: isLoading 
                  ? LabTestColorPalette.borderMedium 
                  : LabTestColorPalette.primaryBlue,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LabTestColorPalette.primaryBlue,
                  ),
                )
              : const Text(
                  'ACCEPT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
        ),
      );
    } else if (type == 'today') {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton(
          onPressed: isLoading ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabTestProcessScreen(booking: booking),
              ),
            ).then((value) {
              // Refresh data when coming back from process screen if needed
              if (value == true) {
                onProcess();
              }
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: LabTestColorPalette.primaryBlue,
            side: BorderSide(
              color: isLoading 
                  ? LabTestColorPalette.borderMedium 
                  : LabTestColorPalette.primaryBlue,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LabTestColorPalette.primaryBlue,
                  ),
                )
              : const Text(
                  'PROCESS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
        ),
      );
    } else {
      return const SizedBox.shrink(); // No button for past bookings
    }
  }

  void _showDetailBottomSheet(BuildContext context) {
    // Debug print for the entire booking
    print('Booking Report URLs: ${booking.reportUrls}');
    
    // Capture the current context that has access to the BookingsViewModel provider
    final viewModel = Provider.of<BookingsViewModel>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LabTestColorPalette.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (scrollContext, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: LabTestColorPalette.borderMedium,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          "Booking Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: LabTestColorPalette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.bookingStatus ?? "").withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            booking.bookingStatus ?? "Unknown",
                            style: TextStyle(
                              color: _getStatusColor(booking.bookingStatus ?? ""),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      title: "Patient Information",
                      icon: Icons.person_outline,
                      children: [
                        _buildDetailRow("Name", booking.user?.name ?? "Unknown"),
                        _buildDetailRow("Phone", booking.user?.phoneNumber ?? "N/A"),
                        _buildDetailRow("Email", booking.user?.emailId ?? "N/A"),
                        if (booking.user?.gender != null) _buildDetailRow("Gender", booking.user?.gender ?? "N/A"),
                        if (booking.user?.bloodGroup != null) _buildDetailRow("Blood Group", booking.user?.bloodGroup ?? "N/A"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      title: "Test Information",
                      icon: Icons.local_hospital_outlined,
                      children: [
                        _buildDetailRow("Test Center", booking.diagnosticCenter?.name ?? "N/A"),
                        _buildDetailRow("Home Collection", booking.homeCollectionRequired == true ? "Yes" : "No"),
                        _buildDetailRow("Report Delivery", booking.reportDeliveryAtHome == true ? "At Home" : "At Center"),
                        _buildDetailRow("Date & Time", "${booking.bookingDate ?? 'N/A'} at ${booking.bookingTime ?? 'N/A'}"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      title: "Tests",
                      icon: Icons.science_outlined,
                      children: [
                        if (booking.selectedTests?.isNotEmpty ?? false)
                          ...(booking.selectedTests ?? []).map((test) => 
                            _buildTestRow(test, booking.reportUrls)
                          ).toList()
                        else
                          const Text(
                            "No tests selected",
                            style: TextStyle(
                              color: LabTestColorPalette.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      title: "Prescription",
                      icon: Icons.description_outlined,
                      children: [
                        if (booking.prescriptionUrl != null && booking.prescriptionUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () => _openPrescription(booking.prescriptionUrl!),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: LabTestColorPalette.primaryBlue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "View Prescription",
                                    style: TextStyle(
                                      color: LabTestColorPalette.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Text(
                            "No prescription uploaded",
                            style: TextStyle(
                              color: LabTestColorPalette.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      title: "Payment Details",
                      icon: Icons.payment_outlined,
                      children: [
                        _buildDetailRow("Test Fees", "₹${booking.testFees?.toStringAsFixed(2) ?? '0.00'}"),
                        if (booking.reportDeliveryFees != null && booking.reportDeliveryFees! > 0)
                          _buildDetailRow("Delivery Fees", "₹${booking.reportDeliveryFees?.toStringAsFixed(2) ?? '0.00'}"),
                        if (booking.discount != null && booking.discount! > 0)
                          _buildDetailRow("Discount", "- ₹${booking.discount?.toStringAsFixed(2) ?? '0.00'}"),
                        if (booking.gst != null && booking.gst! > 0)
                          _buildDetailRow("GST", "₹${booking.gst?.toStringAsFixed(2) ?? '0.00'}"),
                        const Divider(color: LabTestColorPalette.borderLight),
                        _buildDetailRow("Total Amount", "₹${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}", isBold: true),
                        _buildDetailRow(
                          "Payment Status", 
                          booking.paymentStatus ?? "Pending",
                          valueColor: booking.paymentStatus?.toLowerCase() == "paid" 
                              ? LabTestColorPalette.successGreen 
                              : LabTestColorPalette.warningYellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      title: "Address Information",
                      icon: Icons.home_outlined,
                      children: [
                        _buildDetailRow("Address", booking.userAddress ?? "N/A"),
                        if (booking.userLocation != null && booking.userLocation!.isNotEmpty)
                          _buildDetailRow("Location", booking.userLocation!),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (type == 'upcoming')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : () {
                            Navigator.pop(context);
                            onAccept();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.isLoading
                                ? LabTestColorPalette.borderMedium
                                : LabTestColorPalette.primaryBlue,
                            foregroundColor: LabTestColorPalette.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('ACCEPT BOOKING'),
                        ),
                      )
                    else if (type == 'today')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LabTestProcessScreen(booking: booking),
                              ),
                            ).then((value) {
                              // Refresh data when coming back from process screen if needed
                              if (value == true) {
                                onProcess();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.isLoading
                                ? LabTestColorPalette.borderMedium
                                : LabTestColorPalette.primaryBlue,
                            foregroundColor: LabTestColorPalette.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('PROCESS BOOKING'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title, 
    required List<Widget> children,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: LabTestColorPalette.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: LabTestColorPalette.borderLight),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  color: LabTestColorPalette.textSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (label.isNotEmpty)
            const SizedBox(width: 8),
          Expanded(
            flex: label.isEmpty ? 4 : 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                color: valueColor ?? LabTestColorPalette.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestRow(String testName, Map<String, String>? reportUrls) {
    // Debug prints
    print('Test Name: $testName');
    print('Report URLs: $reportUrls');
    
    // Check if reportUrls exists and contains the test name
    final reportUrl = reportUrls?[testName];
    print('Report URL for $testName: $reportUrl');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              testName,
              style: const TextStyle(
                fontSize: 14,
                color: LabTestColorPalette.textPrimary,
              ),
            ),
          ),
          if (reportUrl != null && reportUrl.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => _openPrescription(reportUrl),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text("View Report"),
              style: OutlinedButton.styleFrom(
                foregroundColor: LabTestColorPalette.primaryBlue,
                side: BorderSide(color: LabTestColorPalette.primaryBlue),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const Text(
              "Report not available",
              style: TextStyle(
                fontSize: 12,
                color: LabTestColorPalette.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return LabTestColorPalette.successGreen;
      case 'confirmed':
      case 'accepted':
      case 'processing':
        return LabTestColorPalette.primaryBlue;
      case 'pending':
        return LabTestColorPalette.warningYellow;
      case 'cancelled':
      case 'rejected':
        return LabTestColorPalette.errorRed;
      default:
        return LabTestColorPalette.textSecondary;
    }
  }
} 