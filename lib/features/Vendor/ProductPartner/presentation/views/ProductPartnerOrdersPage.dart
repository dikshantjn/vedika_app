import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../viewmodels/ProductPartnerOrdersViewModel.dart';
import '../../data/models/ProductOrder.dart';

class ProductPartnerOrdersPage extends StatefulWidget {
  final String vendorId;
  
  const ProductPartnerOrdersPage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<ProductPartnerOrdersPage> createState() => _ProductPartnerOrdersPageState();
}

class _ProductPartnerOrdersPageState extends State<ProductPartnerOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  bool _isUpdatingStatus = false;
  String? _updatingOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch orders when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrders() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    try {
      final viewModel = context.read<ProductPartnerOrdersViewModel>();
      await viewModel.fetchOrders(widget.vendorId);
      await viewModel.fetchConfirmedOrders(widget.vendorId);
      await viewModel.fetchDeliveredOrders(widget.vendorId);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerOrdersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !_isRefreshing) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ProductPartnerColorPalette.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ProductPartnerColorPalette.background,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: ProductPartnerColorPalette.primary,
                  unselectedLabelColor: ProductPartnerColorPalette.textSecondary,
                  indicatorColor: ProductPartnerColorPalette.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      height: 72,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pending_actions, size: 24),
                          const SizedBox(height: 4),
                          const Text(
                            'Pending',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      height: 72,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sync, size: 24),
                          const SizedBox(height: 4),
                          const Text(
                            'Processing',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      height: 72,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 24),
                          const SizedBox(height: 4),
                          const Text(
                            'Completed',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRefreshableOrderList(context, viewModel, 'pending'),
                    _buildRefreshableOrderList(context, viewModel, 'processing'),
                    _buildRefreshableOrderList(context, viewModel, 'completed'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefreshableOrderList(BuildContext context, ProductPartnerOrdersViewModel viewModel, String status) {
    List<ProductOrder> filteredOrders;
    
    if (status == 'processing') {
      // For the Processing tab, show all processing-related statuses
      filteredOrders = viewModel.orders.where((order) => 
        order.status == 'confirmed' || 
        order.status == 'processing' || 
        order.status == 'shipped' || 
        order.status == 'out_for_delivery'
      ).toList();
    } else if (status == 'completed') {
      // For the Completed tab, show delivered orders
      filteredOrders = viewModel.deliveredOrders;
    } else {
      // For the Pending tab, show only pending orders
      filteredOrders = viewModel.orders.where((order) => 
        order.status == 'pending'
      ).toList();
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 64,
              color: ProductPartnerColorPalette.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'processing' 
                ? 'No Processing Orders' 
                : status == 'completed'
                  ? 'No Completed Orders'
                  : 'No Pending Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'processing'
                ? 'Orders will appear here when they are confirmed, processing, shipped, or out for delivery'
                : status == 'completed'
                  ? 'Orders will appear here when they are delivered'
                  : 'Orders will appear here when they are pending',
              style: TextStyle(
                fontSize: 14,
                color: ProductPartnerColorPalette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      color: ProductPartnerColorPalette.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final user = order.user;
          final orderStatus = order.status;
          
          return GestureDetector(
            onTap: () => _showOrderDetailsBottomSheet(context, order, viewModel),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(orderStatus).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getStatusIcon(orderStatus),
                                color: _getStatusColor(orderStatus),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Unknown Customer',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 14,
                                      color: ProductPartnerColorPalette.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user?.phoneNumber ?? 'N/A',
                                      style: TextStyle(
                                        color: ProductPartnerColorPalette.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(orderStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            orderStatus.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(orderStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items',
                              style: TextStyle(
                                color: ProductPartnerColorPalette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.orderItems?.length ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                color: ProductPartnerColorPalette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: ProductPartnerColorPalette.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: ProductPartnerColorPalette.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(order.placedAt),
                          style: TextStyle(
                            color: ProductPartnerColorPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, ProductOrder order, ProductPartnerOrdersViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ProductPartnerColorPalette.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserDetails(order),
                    const SizedBox(height: 24),
                    _buildOrderItems(order),
                    const SizedBox(height: 24),
                    _buildOrderSummary(order),
                    const SizedBox(height: 24),
                    // Show action buttons for orders in pending tab or processing tab
                    if (order.status == 'pending' || 
                        order.status == 'confirmed' || 
                        order.status == 'processing' || 
                        order.status == 'shipped' || 
                        order.status == 'out_for_delivery') ...[
                      _buildActionButtons(order, viewModel),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(ProductOrder order) {
    final user = order.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: ProductPartnerColorPalette.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Name', user.name ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Phone', user.phoneNumber),
          const SizedBox(height: 8),
          _buildDetailRow('Email', user.emailId ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Location', user.location ?? 'N/A'),
          if (user.city != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow('City', user.city!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: ProductPartnerColorPalette.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(ProductOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...order.orderItems!.map((item) {
          final product = item.vendorProduct;
          if (product == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item.priceAtPurchase.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOrderSummary(ProductOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Total Amount',
            order.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? ProductPartnerColorPalette.textPrimary : ProductPartnerColorPalette.textSecondary,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? ProductPartnerColorPalette.primary : ProductPartnerColorPalette.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProductOrder order, ProductPartnerOrdersViewModel viewModel) {
    // Define the status progression
    final Map<String, Map<String, dynamic>> statusProgression = {
      'pending': {
        'nextStatus': 'confirmed',
        'buttonText': 'Confirm Order',
        'icon': Icons.check_circle,
      },
      'confirmed': {
        'nextStatus': 'processing',
        'buttonText': 'Start Processing',
        'icon': Icons.sync,
      },
      'processing': {
        'nextStatus': 'shipped',
        'buttonText': 'Mark as Shipped',
        'icon': Icons.local_shipping,
      },
      'shipped': {
        'nextStatus': 'out_for_delivery',
        'buttonText': 'Out for Delivery',
        'icon': Icons.delivery_dining,
      },
      'out_for_delivery': {
        'nextStatus': 'delivered',
        'buttonText': 'Mark as Delivered',
        'icon': Icons.check_circle,
      },
    };

    // Get the next status configuration
    final nextStatusConfig = statusProgression[order.status];

    // If no next status is available, don't show any button
    if (nextStatusConfig == null) {
      return const SizedBox.shrink();
    }

    final String nextStatus = nextStatusConfig['nextStatus'] as String;
    final String buttonText = nextStatusConfig['buttonText'] as String;
    final IconData icon = nextStatusConfig['icon'] as IconData;

    final bool isThisOrderUpdating = _isUpdatingStatus && _updatingOrderId == order.orderId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Update Order Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ProductPartnerColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: isThisOrderUpdating 
            ? null 
            : () async {
                setState(() {
                  _isUpdatingStatus = true;
                  _updatingOrderId = order.orderId;
                });
                
                try {
                  await viewModel.updateOrderStatus(order.orderId, nextStatus);
                  if (mounted) {
                    // Refresh orders after successful status update
                    await _refreshOrders();
                    // Keep the current tab index
                    final currentIndex = _tabController.index;
                    _tabController.animateTo(currentIndex);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order status updated to $nextStatus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update order status: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isUpdatingStatus = false;
                      _updatingOrderId = null;
                    });
                  }
                }
              },
          icon: isThisOrderUpdating 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon),
          label: Text(isThisOrderUpdating ? 'Updating...' : buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: ProductPartnerColorPalette.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: ProductPartnerColorPalette.primary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.deepPurple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'confirmed':
        return Icons.check_circle;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
} 