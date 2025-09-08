import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/MedicineDeliveryOrderService.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onProcessRequest;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onProcessRequest,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildCustomerInfo(),
            SizedBox(height: 16),
            _buildStatusSection(),
            SizedBox(height: 16),
            _buildProcessButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green[100]!,
                Colors.green[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: Colors.green[600],
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${widget.order.orderId}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Total: ₹${widget.order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.person,
              color: Colors.blue[600],
              size: 18,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  widget.order.user?.name ?? 'Unknown Customer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  widget.order.user?.phoneNumber ?? 'No phone number',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Show call button only if order is not delivered and phone number exists
          if (widget.order.status.toLowerCase() != 'delivered' && 
              widget.order.user?.phoneNumber != null && 
              widget.order.user!.phoneNumber!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: IconButton(
                onPressed: () => _makeCall(widget.order.user!.phoneNumber!),
                icon: Icon(
                  Icons.phone,
                  color: Colors.green[600],
                  size: 18,
                ),
                padding: EdgeInsets.all(6),
                constraints: BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildStatusSection() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        SizedBox(width: 8),
        Text(
          _formatDateTime(widget.order.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (widget.order.status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
        break;
      case 'verified':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        statusText = 'Verified';
        statusIcon = Icons.check_circle;
        break;
      case 'waiting_for_payment':
        chipColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        statusText = 'Waiting for Payment';
        statusIcon = Icons.payment;
        break;
      case 'payment_completed':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Payment Completed';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'ready_to_pickup':
        chipColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        statusText = 'Ready for Pickup';
        statusIcon = Icons.local_pharmacy;
        break;
      case 'out_for_delivery':
        chipColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        statusText = 'Out for Delivery';
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Delivered';
        statusIcon = Icons.done_all;
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: textColor,
          ),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    // Show see more button for delivered orders
    if (widget.order.status.toLowerCase() == 'delivered') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showOrderDetailsBottomSheet(context),
          icon: Icon(Icons.expand_more, size: 18),
          label: Text('See More'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: ColorPalette.primaryColor, width: 1.5),
            foregroundColor: ColorPalette.primaryColor,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Show process button for non-delivered orders
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.onProcessRequest,
        icon: Icon(Icons.history, size: 18),
        label: Text('Process Order'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: ColorPalette.primaryColor, width: 2),
          foregroundColor: ColorPalette.primaryColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _showOrderDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsBottomSheet(order: widget.order),
    );
  }

  Future<void> _downloadInvoice() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final service = MedicineDeliveryOrderService();
      await service.downloadMedicineDeliveryInvoice(widget.order.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not make call to $phoneNumber'),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _OrderDetailsBottomSheet extends StatefulWidget {
  final Order order;

  const _OrderDetailsBottomSheet({required this.order});

  @override
  State<_OrderDetailsBottomSheet> createState() => _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<_OrderDetailsBottomSheet> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle and Header
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

            // Order Header
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blueGrey[700], size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${widget.order.orderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(widget.order.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatStatus(widget.order.status),
                style: TextStyle(
                  color: _statusColor(widget.order.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Info
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(widget.order.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.order.vendor != null) ...[
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Vendor: ${widget.order.vendor!.name}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Customer Details Section
            if (widget.order.user != null) ...[
              _buildSectionHeader('Customer Details', Icons.person),
              const SizedBox(height: 12),
              _buildDetailLine(
                Icons.person,
                'Name',
                widget.order.user!.name ?? 'N/A',
                Colors.blue.shade600,
              ),
              const SizedBox(height: 8),
              _buildDetailLine(
                Icons.phone,
                'Phone',
                widget.order.user!.phoneNumber ?? 'N/A',
                Colors.green.shade600,
              ),
              const SizedBox(height: 20),
            ],

            // Order Details Section
            _buildSectionHeader('Order Details', Icons.receipt_long),
            const SizedBox(height: 12),
            _buildDetailLine(
              Icons.payment,
              'Payment ID',
              widget.order.paymentId ?? 'N/A',
              Colors.green.shade600,
            ),
            const SizedBox(height: 8),
            _buildDetailLine(
              Icons.attach_money,
              'Platform Fee',
              '₹${widget.order.platformFee.toStringAsFixed(2)}',
              Colors.orange.shade600,
            ),
            const SizedBox(height: 8),
            _buildDetailLine(
              Icons.account_balance_wallet,
              'Total Amount',
              '₹${widget.order.totalAmount.toStringAsFixed(2)}',
              Colors.blue.shade600,
            ),
            const SizedBox(height: 20),

            // Delivery Address Section
            if (widget.order.deliveryAddress != null) ...[
              _buildSectionHeader('Delivery Address', Icons.location_on),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Type
                    Row(
                      children: [
                        Icon(
                          widget.order.deliveryAddress!.addressType.toLowerCase() == 'home'
                              ? Icons.home
                              : widget.order.deliveryAddress!.addressType.toLowerCase() == 'work'
                                  ? Icons.work
                                  : Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.order.deliveryAddress!.addressType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Address Lines
                    if (widget.order.deliveryAddress!.houseStreet.isNotEmpty)
                      Text(
                        widget.order.deliveryAddress!.houseStreet,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    if (widget.order.deliveryAddress!.addressLine1.isNotEmpty)
                      Text(
                        widget.order.deliveryAddress!.addressLine1,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    if (widget.order.deliveryAddress!.addressLine2 != null && widget.order.deliveryAddress!.addressLine2!.isNotEmpty)
                      Text(
                        widget.order.deliveryAddress!.addressLine2!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),

                    // City, State, ZIP
                    Text(
                      '${widget.order.deliveryAddress!.city}, ${widget.order.deliveryAddress!.state} ${widget.order.deliveryAddress!.zipCode}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),

                    // Country
                    if (widget.order.deliveryAddress!.country.isNotEmpty)
                      Text(
                        widget.order.deliveryAddress!.country,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              _buildSectionHeader('Address', Icons.location_on),
              const SizedBox(height: 12),
              _buildDetailLine(
                Icons.location_on,
                'Address ID',
                widget.order.addressId ?? 'N/A',
                Colors.grey.shade600,
              ),
              const SizedBox(height: 20),
            ],

            // Order Note
            if (widget.order.note != null && widget.order.note!.isNotEmpty) ...[
              _buildSectionHeader('Order Note', Icons.note),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade100),
                ),
                child: Text(
                  widget.order.note!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Download Invoice Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download, size: 20, color: Colors.white),
                label: Text(
                  _isDownloading ? 'Generating Invoice...' : 'Download Invoice',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _isDownloading
                    ? null
                    : () async {
                        setState(() => _isDownloading = true);
                        try {
                          final service = MedicineDeliveryOrderService();
                          await service.downloadMedicineDeliveryInvoice(widget.order.orderId);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invoice downloaded successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Navigator.of(context).pop(); // Close bottom sheet
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to download invoice: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isDownloading = false);
                          }
                        }
                      },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailLine(IconData icon, String label, String value, Color iconColor) {
    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'payment_completed':
        return Colors.blue;
      case 'out_for_delivery':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }
}
