import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/MedicineOrderHistoryViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomOrderInfoDialog.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/invoice_pdf.dart';

class MedicineTab extends StatefulWidget {
  const MedicineTab({Key? key}) : super(key: key);

  @override
  _MedicineTabState createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  final MedicineOrderHistoryViewModel viewModel = MedicineOrderHistoryViewModel();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    await viewModel.fetchOrdersByUser();
  }

  @override
  Widget build(BuildContext context) {
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
            onRefresh: _fetchOrders,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
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
    final dateTime = (order.createdAt);
    final formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Info Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderId}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                onPressed: () => _showOrderDetailsBottomSheet(context, order),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Items Row
          Text(
            'Items: ${order.orderItems.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),

          const SizedBox(height: 8),

          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(order.orderStatus),
              Text(
                'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date and Time Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                formattedTime,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    String formattedStatus = status.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)} ${match.group(2)}');

    Color chipColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        chipColor = Colors.green;
        break;
      case 'shipped':
        chipColor = Colors.orange;
        break;
      case 'processing':
        chipColor = Colors.blue;
        break;
      case 'outfordelivery':
        chipColor = Colors.yellow.shade700;
        break;
      case 'pending':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formattedStatus,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, MedicineOrderModel order) {
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

class _OrderDetailsBottomSheetState extends State<_OrderDetailsBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                        setState(() => _isLoading = true);
                        await generateAndDownloadInvoicePDF(order);
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
    return status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  Widget _receiptRow(String label, double value, {bool isDiscount = false}) {
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
