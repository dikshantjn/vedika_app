import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
// import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseAddressSheet.dart';
import 'package:vedika_healthcare/features/cart/presentation/widgets/MedicineOrderSummarySheet.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/service/DeliveryAddressService.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class MedicineOrderTab extends StatefulWidget {
  const MedicineOrderTab({Key? key}) : super(key: key);

  @override
  State<MedicineOrderTab> createState() => _MedicineOrderTabState();
}

class _MedicineOrderTabState extends State<MedicineOrderTab> {
  final CartService _cartService = CartService();
  final DeliveryAddressService _addressService = DeliveryAddressService();
  List<Order> _medicineOrders = [];
  Set<String> _cancellingOrderIds = {}; // Track orders being cancelled
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
          if (_medicineOrders.isNotEmpty) _buildCheckoutSection(),
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
    final totalAmount = _medicineOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final orderCount = _medicineOrders.length;
    
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order count and Total amount in compact row
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 6),
                Text(
                  '$orderCount ${orderCount == 1 ? 'order' : 'orders'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  'Total: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.primaryColor,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _medicineOrders.isNotEmpty ? _proceedToCheckout : null,
                icon: Icon(
                  Icons.shopping_cart_checkout,
                  size: 18,
                ),
                label: Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildMedicineOrderCard(Order order, int index) {
    final bool isCancelling = _cancellingOrderIds.contains(order.orderId);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID
            Text(
              order.orderId,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[900],
                letterSpacing: -0.2,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Date and Status in same row
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[500],
                ),
                SizedBox(width: 6),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                _buildStatusChip(order.status),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Medical Store Name
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMedicalStoreName(order),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
            
            // Note (if exists)
            if (order.note != null && order.note!.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 14,
                      color: Colors.amber[700],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.note!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 12),
            
            // Action Buttons - Call Store and Menu
            if (!isCancelling)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callStore(order),
                      icon: Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      label: Text(
                        'Call Store',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.blue[300]!, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      if (value == 'cancel') {
                        _showCancelOrderDialog(order);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_outlined, color: Colors.red[600], size: 18),
                            SizedBox(width: 12),
                            Text(
                              'Cancel Order',
                              style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Cancelling order...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
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
      case 'cancelled':
        chipColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        statusText = 'Cancelled';
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

  void _showCancelOrderDialog(Order order) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.red[600],
                      size: 32,
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Cancel Order?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'This action cannot be undone',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Order Info Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.receipt, 'Order ID', order.orderId),
                        SizedBox(height: 12),
                        Divider(height: 1, color: Colors.grey[200]),
                        SizedBox(height: 12),
                        _buildInfoRow(Icons.currency_rupee, 'Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Action Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Keep Order Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Keep Order',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Cancel Order Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _cancelOrder(order.orderId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel Order',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    setState(() {
      _cancellingOrderIds.add(orderId);
    });

    try {
      final result = await _cartService.cancelMedicineOrder(
        orderId: orderId,
        // authToken: 'your-auth-token', // Add this when you have auth
      );

      if (result['success'] == true) {
        // Remove the order from the list
        setState(() {
          _medicineOrders.removeWhere((order) => order.orderId == orderId);
          _cancellingOrderIds.remove(orderId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Order cancelled successfully'),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _cancellingOrderIds.remove(orderId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to cancel order'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _cancellingOrderIds.remove(orderId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling order: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _clearCart() {
    setState(() {
      _medicineOrders.clear();
      _cancellingOrderIds.clear();
      print('🧹 [MedicineOrderTab] Cart cleared successfully');
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cart cleared successfully! Order placed.'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
      ),
    );
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
    try {
      if (_medicineOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No active orders to checkout'),
            backgroundColor: Colors.orange[600]!,
          ),
        );
        return;
      }

      final String? userId = await StorageService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login to continue'),
            backgroundColor: Colors.red[600],
          ),
        );
        return;
      }

      final addresses = await _addressService.getAllAddressesByUserId(userId);
      if (addresses.isEmpty || (addresses.first.addressId == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No delivery address found. Please add an address.'),
            backgroundColor: Colors.orange[700],
          ),
        );
        return;
      }

      final String addressId = addresses.first.addressId!;
      _showMedicineOrderSummarySheet(context, addressId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to proceed to checkout: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  void _showMedicineOrderSummarySheet(BuildContext context, String addressId) {
    if (_medicineOrders.isEmpty) {
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
          medicineOrders: _medicineOrders,
          addressId: addressId,
          onOrderPlaced: _clearCart, // Pass the callback to clear cart
        );
      },
    );
  }
}
