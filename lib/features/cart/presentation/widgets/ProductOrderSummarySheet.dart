import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartPaymentService.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductOrderService.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/cart/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class ProductOrderSummarySheet extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final String addressId;
  final VoidCallback? onOrderPlaced; // Callback to clear cart when order is placed

  ProductOrderSummarySheet({
    Key? key,
    required this.products,
    required this.addressId,
    this.onOrderPlaced,
  }) : super(key: key);

  @override
  _ProductOrderSummarySheetState createState() => _ProductOrderSummarySheetState();
}

class _ProductOrderSummarySheetState extends State<ProductOrderSummarySheet> {
  double _deliveryCharge = 20.0;
  double _platformFee = 10.0;
  bool _isProcessingPayment = false;
  bool _isPaymentFailed = false;
  bool _isOrderPlaced = false;
  
  // Payment service
  late CartPaymentService _paymentService;
  final ProductOrderService _orderService = ProductOrderService();
  
  // Razorpay configuration (you should move these to environment variables)
  static const String _appName = 'Vedika Healthtech';

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
  }
  
  void _initializePaymentService() {
    _paymentService = CartPaymentService();
    
    // Set up payment callbacks
    _paymentService.onPaymentSuccess = _handlePaymentSuccess;
    _paymentService.onPaymentError = _handlePaymentError;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          if (_isOrderPlaced) ...[
            _buildOrderPlacedUI(),
          ] else if (_isPaymentFailed) ...[
            _buildPaymentFailureUI(),
          ] else if (_isProcessingPayment) ...[
            _buildPaymentProcessingUI(),
          ] else ...[
            _buildOrderSummary(),
            const SizedBox(height: 20),
            _buildPriceBreakdown(),
            const SizedBox(height: 24),
            _buildPayNowButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order Summary',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.products.length} Items',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorPalette.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: widget.products.map((product) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                    child: _buildImage(product['image']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['description'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Qty: ${product['quantity']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.primaryColor,
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
              if (product != widget.products.last)
                Divider(height: 1, color: Colors.grey[200]),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final subtotal = widget.products.fold<double>(
      0.0, 
      (sum, product) => sum + (product['price'] * product['quantity']),
    );
    final totalAmount = subtotal + _deliveryCharge + _platformFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _priceRow('Subtotal', subtotal),
          const SizedBox(height: 8),
          _priceRow('Delivery Charge', _deliveryCharge),
          const SizedBox(height: 8),
          _priceRow('Platform Fee', _platformFee),
          const Divider(height: 24),
          _priceRow('Total Amount', totalAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _buildImage(String pathOrUrl) {
    final bool isNetwork = pathOrUrl.startsWith('http');
    if (isNetwork) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    return Image.asset(
      pathOrUrl,
      fit: BoxFit.cover,
    );
  }

  Widget _buildPaymentProcessingUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Processing Payment...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we complete your transaction',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentFailureUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red[400]!,
                  Colors.red[600]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red[400]!.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Failed',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t process your payment',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Please try again or use a different payment method',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isPaymentFailed = false;
                  _isProcessingPayment = false;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? ColorPalette.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPayNowButton() {
    final subtotal = widget.products.fold<double>(
      0.0, 
      (sum, product) => sum + (product['price'] * product['quantity']),
    );
    final totalAmount = subtotal + _deliveryCharge + _platformFee;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isProcessingPayment ? null : () => _payNow(totalAmount),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessingPayment)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  Text(
                    'Pay Now',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _payNow(double totalAmount) {
    setState(() {
      _isProcessingPayment = true;
    });

    // Open Razorpay payment gateway
    _paymentService.openProductPaymentGateway(
      amount: totalAmount,
      key: ApiConstants.razorpayApiKey,
      name: _appName,
      description: 'Product Order - ${widget.products.length} items',
    );
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    setState(() {
      _isProcessingPayment = false;
    });

    try {
      // Place product order via API
      await _orderService.placeProductOrder();

      // Update product cart count after successful placement
      try {
        final cartVM = Provider.of<CartViewModel>(context, listen: false);
        await cartVM.fetchProductCartCount();
      } catch (_) {}

      if (!mounted) return;
      // Refresh cart in caller
      widget.onOrderPlaced?.call();

      setState(() {
        _isOrderPlaced = true;
        _isPaymentFailed = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placement failed'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  Widget _buildOrderPlacedUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green[400]!,
                  Colors.green[600]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green[400]!.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Placed Successfully! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You can track your product order in Order History',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _navigateToProductOrders,
              icon: const Icon(Icons.local_shipping_rounded),
              label: const Text('Track Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProductOrders() {
    // Close the sheet first
    Navigator.pop(context);
    // Navigate to Order History -> Products tab
    Future.delayed(const Duration(milliseconds: 120), () {
      try {
        OrderHistoryNavigation.initialTab = 6; // Products tab index
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderHistoryPage()),
        );
      } catch (_) {}
    });
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessingPayment = false;
      _isPaymentFailed = true;
    });
  }
  
  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
