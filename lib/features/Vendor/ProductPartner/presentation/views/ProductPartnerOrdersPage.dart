import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../viewmodels/ProductPartnerOrdersViewModel.dart';

class ProductPartnerOrdersPage extends StatelessWidget {
  const ProductPartnerOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerOrdersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ProductPartnerColorPalette.primary),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
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
                    children: [
                      _buildOrderList(context, viewModel, 'Pending'),
                      _buildOrderList(context, viewModel, 'Processing'),
                      _buildOrderList(context, viewModel, 'Completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, ProductPartnerOrdersViewModel viewModel, String status) {
    final filteredOrders = viewModel.orders.where((order) => order['status'] == status).toList();

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
              'No $status Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders will appear here when they are $status',
              style: TextStyle(
                fontSize: 14,
                color: ProductPartnerColorPalette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
              ),
              title: Text(
                'Order #${order['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: ProductPartnerColorPalette.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order['customerName'],
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: ProductPartnerColorPalette.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order['date'],
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order['total']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ProductPartnerColorPalette.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(ProductPartnerColorPalette.cardBorderRadius),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Order items list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order['items']?.length ?? 0,
                        itemBuilder: (context, index) {
                          final item = order['items'][index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(item['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${item['quantity']}',
                                        style: TextStyle(
                                          color: ProductPartnerColorPalette.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item['price']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              color: ProductPartnerColorPalette.textSecondary,
                            ),
                          ),
                          Text(
                            '\$${order['total']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ProductPartnerColorPalette.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (status == 'Pending')
                            ElevatedButton.icon(
                              onPressed: () {
                                viewModel.updateOrderStatus(order['id'], 'Processing');
                              },
                              icon: const Icon(Icons.sync),
                              label: const Text('Process Order'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ProductPartnerColorPalette.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                                ),
                              ),
                            ),
                          if (status == 'Processing')
                            ElevatedButton.icon(
                              onPressed: () {
                                viewModel.updateOrderStatus(order['id'], 'Completed');
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Complete Order'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ProductPartnerColorPalette.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                                ),
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: () {
                              // View order details
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ProductPartnerColorPalette.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                              ),
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
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_actions;
      case 'Processing':
        return Icons.sync;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
} 