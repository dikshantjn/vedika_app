import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/MedicineDeliveryOrderHistoryViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/viewers/InvoiceViewerScreen.dart';

import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';
import 'package:provider/provider.dart';

class MedicineDeliveryOrderHistoryTab extends StatefulWidget {
  const MedicineDeliveryOrderHistoryTab({Key? key}) : super(key: key);

  @override
  _MedicineDeliveryOrderHistoryTabState createState() => _MedicineDeliveryOrderHistoryTabState();
}

class _MedicineDeliveryOrderHistoryTabState extends State<MedicineDeliveryOrderHistoryTab> with AutomaticKeepAliveClientMixin {
  late MedicineDeliveryOrderHistoryViewModel viewModel;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    viewModel = MedicineDeliveryOrderHistoryViewModel();
    _fetchOrders();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (_isDisposed) return;
    await viewModel.fetchDeliveredOrdersByUser();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    return ChangeNotifierProvider<MedicineDeliveryOrderHistoryViewModel>(
      create: (_) => viewModel,
      child: Consumer<MedicineDeliveryOrderHistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (!mounted || _isDisposed) return;
                      viewModel.clearError();
                      _fetchOrders();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final orders = viewModel.orders;

          if (orders.isEmpty) {
            return const Center(child: Text('No delivered medicine orders found.'));
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
        },
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, {required Order order}) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    final dateTime = order.createdAt;
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
                onPressed: () {
                  // Check if widget is still mounted before showing dialog
                  if (!mounted || _isDisposed) return;
                  _showOrderDetailsBottomSheet(context, order);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Vendor Name
          if (order.vendor != null) ...[
            Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  order.vendor!.name,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(order.status),
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
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) {
      return Container(); // Return empty container if disposed
    }

    String formattedStatus = _formatStatus(status);

    Color chipColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        chipColor = Colors.green;
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

  String _formatStatus(String status) {
    return status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }



  void _showOrderDetailsBottomSheet(BuildContext context, Order order) {
    // Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OrderDetailsBottomSheet(order: order, viewModel: viewModel);
      },
    );
  }
}

class _OrderDetailsBottomSheet extends StatefulWidget {
  final Order order;
  final MedicineDeliveryOrderHistoryViewModel viewModel;
  const _OrderDetailsBottomSheet({required this.order, required this.viewModel});

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
                color: _statusColor(order.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatStatus(order.status),
                style: TextStyle(
                  color: _statusColor(order.status),
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
            const SizedBox(height: 8),
            if (order.vendor != null) ...[
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Vendor: ${order.vendor!.name}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Order Details Section - Line-wise design
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Order Information Lines
                _buildDetailLine(
                  Icons.payment,
                  'Payment ID',
                  order.paymentId ?? 'N/A',
                  Colors.green.shade600,
                ),

                const SizedBox(height: 12),

                _buildDetailLine(
                  Icons.account_balance_wallet,
                  'Platform Fee',
                  '₹${order.platformFee.toStringAsFixed(2)}',
                  Colors.orange.shade600,
                ),

                // Delivery Address Section
                if (order.deliveryAddress != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.location_on, color: Colors.purple.shade700, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.purple.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address Type
                              Row(
                                children: [
                                  Icon(
                                    order.deliveryAddress!.addressType.toLowerCase() == 'home'
                                        ? Icons.home
                                        : order.deliveryAddress!.addressType.toLowerCase() == 'work'
                                            ? Icons.work
                                            : Icons.location_on,
                                    size: 16,
                                    color: Colors.purple.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    order.deliveryAddress!.addressType,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Address Lines
                              if (order.deliveryAddress!.houseStreet.isNotEmpty)
                                Text(
                                  order.deliveryAddress!.houseStreet,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                ),
                              if (order.deliveryAddress!.addressLine1.isNotEmpty)
                                Text(
                                  order.deliveryAddress!.addressLine1,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                ),
                              if (order.deliveryAddress!.addressLine2 != null && order.deliveryAddress!.addressLine2!.isNotEmpty)
                                Text(
                                  order.deliveryAddress!.addressLine2!,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                ),
                              // City, State, ZIP, Country
                              Text(
                                '${order.deliveryAddress!.city}, ${order.deliveryAddress!.state} ${order.deliveryAddress!.zipCode}',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                              ),
                              if (order.deliveryAddress!.country.isNotEmpty)
                                Text(
                                  order.deliveryAddress!.country,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  _buildDetailLine(
                    Icons.location_on,
                    'Address ID',
                    order.addressId ?? 'N/A',
                    Colors.grey.shade600,
                  ),
                ],

                // Order Note
                if (order.note != null && order.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.note, color: Colors.amber.shade700, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Order Note',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade100),
                          ),
                          child: Text(
                            order.note!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Payment Summary Divider
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 16),

                // Payment Summary Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.currency_rupee, color: Colors.green.shade700, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Platform Fee',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '₹${order.platformFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
                    : const Icon(Icons.receipt_long, size: 20, color: Colors.white),
                label: Text(
                  _isLoading ? 'Opening Invoice...' : 'View Invoice',
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
                        try {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InvoiceViewerScreen(
                                orderId: widget.order.orderId,
                                categoryLabel: 'Medicine Delivery',
                              ),
                            ),
                          );
                        } finally {
                          if (!mounted || _isDisposed) return;
                          setState(() => _isLoading = false);
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

  Widget _buildOrderInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blueGrey),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  String _formatAddress(DeliveryAddressModel address) {
    List<String> addressParts = [];

    if (address.houseStreet.isNotEmpty) {
      addressParts.add(address.houseStreet);
    }
    if (address.addressLine1.isNotEmpty) {
      addressParts.add(address.addressLine1);
    }
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      addressParts.add(address.addressLine2!);
    }
    if (address.city.isNotEmpty) {
      addressParts.add(address.city);
    }
    if (address.state.isNotEmpty) {
      addressParts.add(address.state);
    }
    if (address.zipCode.isNotEmpty) {
      addressParts.add(address.zipCode);
    }
    if (address.country.isNotEmpty) {
      addressParts.add(address.country);
    }

    return addressParts.join(', ');
  }
}
