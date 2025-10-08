import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/MedicineOrderHistoryViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomOrderInfoDialog.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/invoice_pdf.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class MedicineTab extends StatefulWidget {
  const MedicineTab({Key? key}) : super(key: key);

  @override
  _MedicineTabState createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> with AutomaticKeepAliveClientMixin {
  final MedicineOrderHistoryViewModel viewModel = MedicineOrderHistoryViewModel();
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (_isDisposed) return;
    await viewModel.fetchOrdersByUser();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }
    
    return FutureBuilder(
      future: _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final orders = viewModel.orders;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return RefreshIndicator(
            onRefresh: () {
              // Check if widget is still mounted before refreshing
              if (!mounted || _isDisposed) return Future.value();
              return _fetchOrders();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                // Check if widget is still mounted before building items
                if (!mounted || _isDisposed) return Container();
                
                final order = orders[index];
                return _buildOrderItem(context, order: order);
              },
            ),
          );
        }
      },
    );
  }


  Widget _buildOrderItem(BuildContext context, {required MedicineOrderModel order}) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }
    
    final dateTime = order.createdAt;
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(dateTime);

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
            _showOrderDetailsBottomSheet(context, order);
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
                          Icons.medication_rounded,
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
                    _buildStatusChip(order.orderStatus),
                  ],
                ),
              ),
              
              // Medicine info
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                      child: Icon(
                        Icons.medication_rounded, 
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
                            'Medicine Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Order #${order.orderId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: DoctorConsultationColorPalette.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                size: 16,
                                color: DoctorConsultationColorPalette.primaryBlue,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '${order.orderItems.length} Items',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: DoctorConsultationColorPalette.textSecondary,
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
              
              // Order info footer
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                        SizedBox(width: 6),
                        Text(
                          DateFormat('hh:mm a').format(dateTime),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.textPrimary,
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
                          '₹${order.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.primaryBlue,
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
      ),
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
      case 'delivered':
        chipColor = DoctorConsultationColorPalette.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'shipped':
        chipColor = DoctorConsultationColorPalette.warningYellow;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'processing':
        chipColor = DoctorConsultationColorPalette.primaryBlue;
        statusIcon = Icons.schedule;
        break;
      case 'outfordelivery':
        chipColor = DoctorConsultationColorPalette.warningYellow;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case 'pending':
        chipColor = DoctorConsultationColorPalette.warningYellow;
        statusIcon = Icons.schedule;
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

  void _showOrderDetailsBottomSheet(BuildContext context, MedicineOrderModel order) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OrderDetailsBottomSheet(order: order);
      },
    );
  }
}

class _OrderDetailsBottomSheet extends StatefulWidget {
  final MedicineOrderModel order;
  const _OrderDetailsBottomSheet({required this.order});

  @override
  State<_OrderDetailsBottomSheet> createState() => _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<_OrderDetailsBottomSheet> with AutomaticKeepAliveClientMixin {
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
    
    final order = widget.order;
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
                Icon(Icons.receipt_long, color: Colors.blueGrey[700], size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${order.orderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(order.orderStatus).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatStatus(order.orderStatus),
                style: TextStyle(
                  color: _statusColor(order.orderStatus),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
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
                      Icon(Icons.medication_outlined, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text('Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...order.orderItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('x${item.quantity}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            const SizedBox(width: 8),
                            Text('₹${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        if (item.medicineProduct != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (item.medicineProduct!.manufacturer.isNotEmpty)
                                Flexible(child: Text('Manufacturer: ${item.medicineProduct!.manufacturer}', style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                              if (item.medicineProduct!.type.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Flexible(child: Text('Type: ${item.medicineProduct!.type}', style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                              ],
                            ],
                          ),
                          if (item.medicineProduct!.packSizeLabel.isNotEmpty)
                            Text('Pack Size: ${item.medicineProduct!.packSizeLabel}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          if (item.medicineProduct!.shortComposition.isNotEmpty)
                            Text('Composition: ${item.medicineProduct!.shortComposition}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        ],
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                  // Receipt Box
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[100]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _receiptRow('Subtotal', order.subtotal),
                        const SizedBox(height: 8),
                        _receiptRow('Delivery Charge', order.deliveryCharge),
                        const SizedBox(height: 8),
                        _receiptRow('Platform Fee', order.platformFee),
                        const SizedBox(height: 8),
                        _receiptRow('Discount', -order.discountAmount, isDiscount: true),
                        const Divider(height: 24, color: Colors.blueGrey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
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
                  _isLoading ? 'Generating Invoice...' : 'Download Invoice',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
                        await generateAndDownloadInvoicePDF(order);
                        
                        // Check if widget is still mounted before calling setState again
                        if (!mounted || _isDisposed) return;
                        setState(() => _isLoading = false);
                      },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Colors.grey; // Return default color if disposed
    }
    
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'outfordelivery':
        return Colors.yellow.shade700;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return status; // Return original status if disposed
    }
    
    return status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  Widget _receiptRow(String label, double value, {bool isDiscount = false}) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
        Text(
          (isDiscount ? '- ' : '') + '₹${value.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green[700] : Colors.blueGrey[900],
          ),
        ),
      ],
    );
  }
}
