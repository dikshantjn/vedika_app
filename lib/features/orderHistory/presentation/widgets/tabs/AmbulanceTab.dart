import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/AmbulanceOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/viewers/InvoiceViewerScreen.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class AmbulanceTab extends StatefulWidget {
  @override
  State<AmbulanceTab> createState() => _AmbulanceTabState();
}

class _AmbulanceTabState extends State<AmbulanceTab>
    with AutomaticKeepAliveClientMixin {
  final AmbulanceOrderViewModel viewModel = AmbulanceOrderViewModel();
  List<AmbulanceBooking> bookings = [];
  bool isLoading = true;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (_isDisposed) return;
    await viewModel.loadCompletedOrders();
    if (!_isDisposed && mounted) {
      setState(() {
        bookings = viewModel.orders; // get the updated orders
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return const Center(child: Text("No completed ambulance orders found."));
    }

    return RefreshIndicator(
      onRefresh: () {
        // Check if widget is still mounted before refreshing
        if (!mounted || _isDisposed) return Future.value();
        return _loadBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          // Check if widget is still mounted before building items
          if (!mounted || _isDisposed) return Container();

          final booking = bookings[index];
          return _buildBookingCard(context, booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, AmbulanceBooking booking) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    final formattedDate =
        DateFormat('EEE, MMM d, yyyy').format(booking.timestamp);
    final agencyName = booking.agency?.agencyName ?? "Ambulance Agency";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (!mounted || _isDisposed) return;
            _showBookingDetailsBottomSheet(context, booking);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.backgroundCard,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital_rounded,
                          size: 16,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusChip(booking.status),
                  ],
                ),
              ),

              // Agency info
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: DoctorConsultationColorPalette
                          .primaryBlue
                          .withOpacity(0.1),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        size: 30,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agencyName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ambulance Service',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  DoctorConsultationColorPalette.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 16,
                                color:
                                    DoctorConsultationColorPalette.primaryBlue,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  booking.vehicleType,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: DoctorConsultationColorPalette
                                        .textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: DoctorConsultationColorPalette.borderLight,
              ),

              // Booking info footer
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color:
                                    DoctorConsultationColorPalette.primaryBlue,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${booking.pickupLocation} → ${booking.dropLocation}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: DoctorConsultationColorPalette
                                        .textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.straighten_rounded,
                              size: 16,
                              color:
                                  DoctorConsultationColorPalette.successGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${booking.totalDistance.toStringAsFixed(2)} km',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    DoctorConsultationColorPalette.successGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.payment,
                              size: 16,
                              color: DoctorConsultationColorPalette.primaryBlue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '₹${booking.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color:
                                    DoctorConsultationColorPalette.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetailsBottomSheet(
      BuildContext context, AmbulanceBooking booking) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final double sheetHeight = MediaQuery.of(context).size.height * 0.88;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: sheetHeight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.local_hospital,
                          color: Colors.blueGrey[700], size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Booking #${booking.requestId}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(booking.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: _statusColor(booking.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(booking.timestamp),
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.apartment, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text('Agency',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(booking.agency?.agencyName ?? 'Unknown Agency',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87)),
                        if (booking.agency?.contactNumber != null)
                          Text('Contact: ${booking.agency!.contactNumber}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700])),
                        if (booking.agency?.address != null)
                          Text('Address: ${booking.agency!.address}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700])),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text('Vehicle',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Type: ${booking.vehicleType}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87)),
                        Text(
                            'Distance: ${booking.totalDistance.toStringAsFixed(2)} km',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                        Text(
                            'Cost per km: ₹${booking.costPerKm.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                        Text(
                            'Base Charge: ₹${booking.baseCharge.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text('Route',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Pickup: ${booking.pickupLocation}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87)),
                        Text('Drop: ${booking.dropLocation}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: booking.isPaymentBypassed
                          ? Colors.blue[50]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: booking.isPaymentBypassed
                              ? Colors.blue[100]!
                              : Colors.blue[100]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: booking.isPaymentBypassed
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payment Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    'Payment Waived',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              if (booking.bypassReason != null &&
                                  booking.bypassReason!.isNotEmpty) ...[
                                SizedBox(height: 12),
                                Text(
                                  'Reason:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  booking.bypassReason!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                              if (booking.bypassApprovedBy != null &&
                                  booking.bypassApprovedBy!.isNotEmpty) ...[
                                SizedBox(height: 12),
                                Text(
                                  'Approved By:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  booking.bypassApprovedBy!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _receiptRow('Base Charge', booking.baseCharge),
                              const SizedBox(height: 8),
                              _receiptRow('Distance Charge',
                                  booking.totalDistance * booking.costPerKm),
                              const Divider(height: 24, color: Colors.blueGrey),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '₹${booking.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: _ViewInvoiceButton(
                        booking: booking, viewModel: viewModel),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _receiptRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    Color chipColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = DoctorConsultationColorPalette.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'ongoing':
        chipColor = DoctorConsultationColorPalette.warningYellow;
        statusIcon = Icons.schedule;
        break;
      case 'pending':
        chipColor = DoctorConsultationColorPalette.primaryBlue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        chipColor = DoctorConsultationColorPalette.errorRed;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        chipColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Colors.grey; // Return default color if disposed
    }

    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _ViewInvoiceButton extends StatefulWidget {
  final AmbulanceBooking booking;
  final AmbulanceOrderViewModel viewModel;
  const _ViewInvoiceButton(
      {Key? key, required this.booking, required this.viewModel})
      : super(key: key);

  @override
  State<_ViewInvoiceButton> createState() => _ViewInvoiceButtonState();
}

class _ViewInvoiceButtonState extends State<_ViewInvoiceButton>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    return ElevatedButton.icon(
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.2,
              ),
            )
          : const Icon(Icons.receipt_long, size: 20, color: Colors.white),
      label: Text(
        _isLoading ? 'Opening Invoice...' : 'View Invoice',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      onPressed: _isLoading
          ? null
          : () async {
              // Check if widget is still mounted before proceeding
              if (!mounted || _isDisposed) return;

              setState(() => _isLoading = true);
              try {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvoiceViewerScreen(
                      orderId: widget.booking.requestId,
                      categoryLabel: 'Ambulance Service',
                    ),
                  ),
                );
              } finally {
                // Check if widget is still mounted before calling setState again
                if (!mounted || _isDisposed) return;
                setState(() => _isLoading = false);
              }
            },
    );
  }
}
