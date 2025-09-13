import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/LabTestOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/viewers/InvoiceViewerScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/ReportViewScreen.dart';
import 'package:intl/intl.dart';

class LabTestTab extends StatefulWidget {
  @override
  _LabTestTabState createState() => _LabTestTabState();
}

class _LabTestTabState extends State<LabTestTab> {
  @override
  void initState() {
    super.initState();
    final userId = "GOrt7AWP82dMYs8tVejjLyvdPyy2";
    Future.microtask(() =>
        Provider.of<LabTestOrderViewModel>(context, listen: false)
            .fetchCompletedLabTestOrders(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LabTestOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  "Loading your lab tests...",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final orders = viewModel.orders;
        if (orders.isEmpty || (viewModel.error != null && viewModel.error!.contains("No completed bookings found"))) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  "No lab tests found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 12),
                Text(
                  "Unable to load lab tests",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderItem(context, orders[index]);
          },
        );
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, LabTestBooking order) {
    return GestureDetector(
      onTap: () => _showInvoiceBottomSheet(context, order),
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.science_outlined,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.diagnosticCenter?.name ?? 'Unknown Lab',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${order.bookingDate} at ${order.bookingTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusChip(order.bookingStatus ?? 'Unknown'),
                      SizedBox(width: 8),
                      Icon(
                        Icons.receipt_long,
                        color: Colors.blue.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(color: Colors.grey.withOpacity(0.2)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoPill(
                    icon: Icons.science_outlined,
                    label: (order.selectedTests?.length ?? 0) > 1
                        ? "${order.selectedTests?.length ?? 0} Tests"
                        : order.selectedTests?.first ?? "No tests",
                  ),
                  _buildInfoPill(
                    icon: Icons.location_on_outlined,
                    label: order.homeCollectionRequired == true ? "Home Collection" : "At Center",
                  ),
                  Text(
                    "₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              if (order.reportUrls != null && order.reportUrls!.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Test Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 8),
                ...order.reportUrls!.entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportViewScreen(
                                reportUrl: entry.value,
                                testName: entry.key,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.visibility_outlined, size: 16),
                        label: Text("View Report"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceBottomSheet(BuildContext context, LabTestBooking order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LabTestInvoiceBottomSheet(order: order),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'ongoing':
        chipColor = Colors.orange;
        break;
      case 'pending':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch report URL')),
      );
    }
  }
}

class LabTestInvoiceBottomSheet extends StatefulWidget {
  final LabTestBooking order;

  const LabTestInvoiceBottomSheet({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<LabTestInvoiceBottomSheet> createState() => _LabTestInvoiceBottomSheetState();
}

class _LabTestInvoiceBottomSheetState extends State<LabTestInvoiceBottomSheet> {
  bool _isGeneratingInvoice = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Invoice Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Booking Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text('Booking ID:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                            Flexible(
                              child: Text(
                                widget.order.bookingId ?? 'N/A',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text('Booking Date:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                            Flexible(
                              child: Text(
                                widget.order.bookingDate ?? 'N/A',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text('Booking Time:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                            Flexible(
                              child: Text(
                                widget.order.bookingTime ?? 'N/A',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Diagnostic Center Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.science_outlined, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Diagnostic Center',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.order.diagnosticCenter?.name ?? 'Unknown Center',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.order.diagnosticCenter?.address ?? ''}, ${widget.order.diagnosticCenter?.city ?? ''}, ${widget.order.diagnosticCenter?.state ?? ''}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact: ${widget.order.diagnosticCenter?.mainContactNumber ?? 'N/A'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Patient Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Patient Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Name: ${widget.order.user?.name ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${widget.order.user?.phoneNumber ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (widget.order.user?.emailId != null && widget.order.user!.emailId!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Email: ${widget.order.user!.emailId}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Test Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.science, color: Colors.orange.shade600, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Test Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text('Collection Method:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                            Flexible(
                              child: Text(
                                widget.order.homeCollectionRequired == true ? "Home Collection" : "At Center",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text('Report Delivery:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                            Flexible(
                              child: Text(
                                widget.order.reportDeliveryAtHome == true ? "Home Delivery" : "At Center",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Selected Tests:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...(widget.order.selectedTests ?? []).map((test) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  test,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Cost Breakdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Cost Breakdown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCostRow('Test Fees', widget.order.testFees ?? 0.0),
                        _buildCostRow('Report Delivery Fees', widget.order.reportDeliveryFees ?? 0.0),
                        if ((widget.order.discount ?? 0.0) > 0)
                          _buildCostRow('Discount', -(widget.order.discount ?? 0.0)),
                        if ((widget.order.gst ?? 0.0) > 0)
                          _buildCostRow('GST', widget.order.gst ?? 0.0),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '₹${(widget.order.totalAmount ?? 0.0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // View Invoice Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingInvoice ? null : _viewInvoice,
                      icon: _isGeneratingInvoice
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.receipt_long, color: Colors.white),
                      label: Text(
                        _isGeneratingInvoice ? 'Opening Invoice...' : 'View Invoice',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            '₹${amount >= 0 ? amount.toStringAsFixed(2) : '-${amount.abs().toStringAsFixed(2)}'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewInvoice() async {
    setState(() {
      _isGeneratingInvoice = true;
    });

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoiceViewerScreen(
            orderId: widget.order.bookingId!,
            categoryLabel: 'Lab Test',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingInvoice = false;
        });
      }
    }
  }
}
