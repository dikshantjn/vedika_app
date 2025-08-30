import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseAddressSheet.dart';
import 'package:vedika_healthcare/features/cart/presentation/widgets/MedicineOrderSummarySheet.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicineOrderTab extends StatefulWidget {
  const MedicineOrderTab({Key? key}) : super(key: key);

  @override
  State<MedicineOrderTab> createState() => _MedicineOrderTabState();
}

class _MedicineOrderTabState extends State<MedicineOrderTab> {
  final CartService _cartService = CartService();
  List<Order> _medicineOrders = [];
  Set<String> _removedOrderIds = {}; // Track removed orders
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingPaymentOrders();
  }

  Future<void> _loadPendingPaymentOrders() async {
    try {
      print('🔄 [MedicineOrderTab] Starting to load pending payment orders...');
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Replace with actual user ID from auth service
      const String userId = 'GOrt7AWP82dMYs8tVejjLyvdPyy2'; // This should come from your auth service
      print('👤 [MedicineOrderTab] Using user ID: $userId');
      
      print('📞 [MedicineOrderTab] Calling CartService.getPendingPaymentOrders...');
      final result = await _cartService.getPendingPaymentOrders(
        userId: userId,
        // authToken: 'your-auth-token', // Add this when you have auth
      );

      print('✅ [MedicineOrderTab] CartService call completed');
      print('📊 [MedicineOrderTab] Result: $result');

      if (result['success']) {
        final List<dynamic> ordersData = result['data'];
        print('📊 [MedicineOrderTab] Orders data length: ${ordersData.length}');
        print('📊 [MedicineOrderTab] Orders data: $ordersData');
        
        try {
          final List<Order> parsedOrders = ordersData.map((json) {
            print('🔄 [MedicineOrderTab] Parsing order: $json');
            return Order.fromJson(json);
          }).toList();
          
          print('✅ [MedicineOrderTab] Successfully parsed ${parsedOrders.length} orders');
          
          setState(() {
            _medicineOrders = parsedOrders;
            _isLoading = false;
          });
          
          print('✅ [MedicineOrderTab] State updated successfully');
        } catch (parseError) {
          print('🚨 [MedicineOrderTab] Error parsing orders: $parseError');
          print('📊 [MedicineOrderTab] Parse error stack trace: ${StackTrace.current}');
          setState(() {
            _error = 'Error parsing orders: $parseError';
            _isLoading = false;
          });
        }
      } else {
        print('❌ [MedicineOrderTab] API call failed');
        print('📊 [MedicineOrderTab] Error message: ${result['message']}');
        setState(() {
          _error = result['message'] ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('🚨 [MedicineOrderTab] Unexpected error occurred');
      print('📊 [MedicineOrderTab] Error: $e');
      print('📊 [MedicineOrderTab] Stack trace: $stackTrace');
      setState(() {
        _error = 'Error loading orders: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          if (_getActiveOrdersCount() > 0) _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_error != null) {
      return _buildErrorState();
    } else if (_medicineOrders.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildMedicineOrderList();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Error loading orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPendingPaymentOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }



  Widget _buildMedicineOrderList() {
    return RefreshIndicator(
      onRefresh: _loadPendingPaymentOrders,
      color: ColorPalette.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _medicineOrders.length,
        itemBuilder: (context, index) {
          return _buildMedicineOrderCard(_medicineOrders[index], index);
        },
      ),
    );
  }

  Widget _buildCheckoutSection() {
    final activeOrders = _medicineOrders.where((order) => !_removedOrderIds.contains(order.orderId)).toList();
    final totalAmount = activeOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total amount display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: activeOrders.isNotEmpty ? _proceedToCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_checkout, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildMedicineOrderCard(Order order, int index) {
    final bool isRemoved = _removedOrderIds.contains(order.orderId);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isRemoved ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order ID and Status
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRemoved 
                        ? Colors.grey[300] 
                        : ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: isRemoved ? Colors.grey[600] : ColorPalette.primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID with strike-through when removed
                      Stack(
                        children: [
                          Text(
                            'Order ID: ${order.orderId}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isRemoved ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          if (isRemoved)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[600]!,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isRemoved ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Medical Store Details
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRemoved ? Colors.grey[200] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isRemoved ? Colors.grey[400]! : Colors.blue[200]!),
                  ),
                  child: Icon(
                    Icons.storefront_outlined,
                    color: isRemoved ? Colors.grey[600] : Colors.blue[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMedicalStoreName(order),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isRemoved ? Colors.grey[500] : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Prescription ID: ${order.prescriptionId.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 12,
                          color: isRemoved ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Amount and Note
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Amount: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: isRemoved ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isRemoved ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (order.platformFee > 0) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Platform Fee: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isRemoved ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      Text(
                        '₹${order.platformFee.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isRemoved ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 8),
                Divider(height: 1, color: isRemoved ? Colors.grey[300] : Colors.grey[300]),
                SizedBox(height: 8),
                if (order.note != null && order.note!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: isRemoved ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          order.note!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isRemoved ? Colors.grey[500] : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callStore(order),
                    icon: Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: isRemoved ? Colors.grey[500] : Colors.blue[600],
                    ),
                    label: Text(
                      'Call Store',
                      style: TextStyle(
                        color: isRemoved ? Colors.grey[500] : Colors.blue[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isRemoved ? Colors.grey[400]! : Colors.blue[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleOrderRemoval(order.orderId),
                    icon: Icon(
                      _removedOrderIds.contains(order.orderId) 
                          ? Icons.restore_from_trash_outlined 
                          : Icons.delete_outline,
                      size: 18,
                    ),
                    label: Text(
                      _removedOrderIds.contains(order.orderId) 
                          ? 'Restore' 
                          : 'Remove',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _removedOrderIds.contains(order.orderId) 
                          ? Colors.green[600] 
                          : Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        statusText = 'Pending';
        break;
      case 'waiting_for_payment':
        chipColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        statusText = 'Payment Pending';
        break;
      case 'payment_completed':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        statusText = 'Payment Completed';
        break;
      case 'ready_to_pickup':
        chipColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        statusText = 'Ready to Pickup';
        break;
      case 'out_for_delivery':
        chipColor = Colors.indigo[100]!;
        textColor = Colors.indigo[700]!;
        statusText = 'Out for Delivery';
        break;
      case 'delivered':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Delivered';
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        statusText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.add_shopping_cart,
              size: 80,
              color: Colors.blue[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'All your medicine orders are paid for',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }



  void _viewOrderDetails(Order order) {
    // TODO: Navigate to order details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${order.orderId}'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _callStore(Order order) async {
    // Since the simplified vendor model doesn't have contact number,
    // we'll show a message that it's not available
          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Store contact information not available in this view'),
          backgroundColor: Colors.orange[600]!,
        ),
      );
    
    // TODO: If you need to show contact number, you can:
    // 1. Add contactNumber field to OrderVendor model, or
    // 2. Make another API call to get full vendor details
  }

  void _toggleOrderRemoval(String orderId) {
    setState(() {
      if (_removedOrderIds.contains(orderId)) {
        _removedOrderIds.remove(orderId);
      } else {
        _removedOrderIds.add(orderId);
      }
    });
  }

  int _getActiveOrdersCount() {
    return _medicineOrders.where((order) => !_removedOrderIds.contains(order.orderId)).length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMedicalStoreName(Order order) {
    // Try to get medical store name from vendor profile
    if (order.vendor != null) {
      return order.vendor!.name;
    }
    return 'Medical Store'; // Fallback
  }

    Future<void> _proceedToCheckout() async {
    final String? selectedAddressId = await showModalBottomSheet<String>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: ChooseAddressSheet(),
        );
      },
    );

    if (selectedAddressId != null) {
      _showMedicineOrderSummarySheet(context, selectedAddressId);
    }
  }

  void _showMedicineOrderSummarySheet(BuildContext context, String addressId) {
    // Filter out removed orders for checkout
    final activeOrders = _medicineOrders.where((order) => !_removedOrderIds.contains(order.orderId)).toList();
    
    if (activeOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No active orders to checkout'),
          backgroundColor: Colors.orange[600]!,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return MedicineOrderSummarySheet(
          medicineOrders: activeOrders,
          addressId: addressId,
        );
      },
    );
  }
}

// Custom painter for drawing strike-through lines
class StrikeThroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[400]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw diagonal strike-through line
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );

    // Draw another diagonal line in opposite direction for better coverage
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
