import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/OrderHistoryViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/product_order_invoice_pdf.dart';
import 'package:printing/printing.dart';

class ProductOrdersTab extends StatefulWidget {
  const ProductOrdersTab({Key? key}) : super(key: key);

  @override
  State<ProductOrdersTab> createState() => _ProductOrdersTabState();
}

class _ProductOrdersTabState extends State<ProductOrdersTab> {
  bool _isGeneratingInvoice = false;
  bool _isLoading = false;

  // Calculate subtotal from order items with proper null safety
  double _calculateSubtotal(ProductOrder order) {
    if (order.items == null || order.items!.isEmpty) {
      return 0.0;
    }
    return order.items!.fold<double>(
      0.0,
      (sum, item) => sum + (item.quantity * item.priceAtPurchase),
    );
  }

  // Calculate delivery fee (example fixed fee)
  double _calculateDeliveryFee(double subtotal) {
    return subtotal >= 500 ? 0.0 : 40.0; // Free delivery above ₹500
  }

  // Calculate GST (example 18%)
  double _calculateGST(double subtotal) {
    return subtotal * 0.18;
  }

  // Calculate total amount
  double _calculateTotal(double subtotal, double deliveryFee, double gst) {
    return subtotal + deliveryFee + gst;
  }

  double _calculateTotalAmount(ProductOrder order) {
    if (order.items == null || order.items!.isEmpty) {
      return 0.0;
    }
    return order.items!.fold<double>(
      0.0,
      (total, item) => total + (item.priceAtPurchase * item.quantity),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderHistoryViewModel>(context, listen: false)
          .fetchDeliveredProductOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderHistoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (viewModel.deliveredProductOrders.isEmpty) {
          return const Center(
            child: Text('No delivered orders found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.deliveredProductOrders.length,
          itemBuilder: (context, index) {
            final order = viewModel.deliveredProductOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(ProductOrder order) {
    String formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(order.placedAt);

    return InkWell(
      onTap: () => _showOrderDetails(order),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorPalette.primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderId.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on: $formattedDate',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Delivered',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items!.map((item) {
                  final product = item.vendorProduct;
                  if (product == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (product.images.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: product.images.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantity: ${item.quantity}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item.priceAtPurchase.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: ColorPalette.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: ColorPalette.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showOrderDetails(ProductOrder order) {
    // Calculate all values
    final subtotal = _calculateSubtotal(order);
    final deliveryFee = _calculateDeliveryFee(subtotal);
    final gst = _calculateGST(subtotal);
    final total = _calculateTotal(subtotal, deliveryFee, gst);

    // Get the first product's vendor details safely
    final firstProduct = order.items?.firstOrNull?.vendorProduct?.productPartner;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                    // Header with Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Order Info Card
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Order ID', '#${order.orderId.substring(0, 8)}'),
                          const Divider(height: 20),
                          _buildInfoRow('Order Date', DateFormat('dd MMM yyyy').format(order.placedAt)),
                          const Divider(height: 20),
                          _buildInfoRow('Order Time', DateFormat('hh:mm a').format(order.placedAt)),
                          const Divider(height: 20),
                          _buildInfoRow('Status', order.status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Customer Info Card
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildInfoRow('Name', order.user?.name ?? 'N/A'),
                          const Divider(height: 20),
                          _buildInfoRow('Phone', order.user?.phoneNumber ?? 'N/A'),
                          if (order.user?.emailId != null) ...[
                            const Divider(height: 20),
                            _buildInfoRow('Email', order.user?.emailId ?? ''),
                          ],
                          if (order.user?.location != null) ...[
                            const Divider(height: 20),
                            _buildInfoRow('Location', order.user?.location ?? ''),
                          ],
                          if (order.user?.city != null) ...[
                            const Divider(height: 20),
                            _buildInfoRow('City', order.user?.city ?? ''),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vendor Info Card
                    if (firstProduct != null)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vendor Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow('Brand Name', firstProduct.brandName),
                            const Divider(height: 20),
                            _buildInfoRow('Company Name', firstProduct.companyLegalName),
                            const Divider(height: 20),
                            _buildInfoRow('Phone', firstProduct.phoneNumber),
                            const Divider(height: 20),
                            _buildInfoRow('Email', firstProduct.email),
                            const Divider(height: 20),
                            _buildInfoRow('City', firstProduct.city),
                            const Divider(height: 20),
                            _buildInfoRow('State', firstProduct.state),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Order Items
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items!.map((item) {
                      final product = item.vendorProduct;
                      if (product == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            if (product.images.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.images.first,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item.priceAtPurchase.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: ColorPalette.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),

                    // Cost Details Card
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorPalette.primaryColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Items Total', '₹${subtotal.toStringAsFixed(2)}'),
                          if (deliveryFee > 0) ...[
                            const Divider(height: 20),
                            _buildInfoRow('Delivery Fee', '₹${deliveryFee.toStringAsFixed(2)}'),
                          ],
                          const Divider(height: 20),
                          _buildInfoRow(
                            'GST (18%)',
                            '₹${gst.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            'Total Amount',
                            '₹${total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Download Invoice Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGeneratingInvoice
                          ? null
                          : () async {
                              try {
                                setState(() {
                                  _isGeneratingInvoice = true;
                                });
                                
                                await _downloadInvoice(order);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to download invoice'),
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
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGeneratingInvoice)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 12),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            Icon(
                              _isGeneratingInvoice ? Icons.hourglass_empty : Icons.download,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isGeneratingInvoice ? 'Generating Invoice...' : 'Download Invoice',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? ColorPalette.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _downloadInvoice(ProductOrder order) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdfBytes = await ProductOrderInvoicePdf.generate(order);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'order_invoice_${order.orderId.substring(0, 8)}.pdf'
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate invoice. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 