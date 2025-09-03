import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartPaymentService.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  
  // Payment service
  late CartPaymentService _paymentService;
  
  // Razorpay configuration (you should move these to environment variables)
  static const String _razorpayKey = 'rzp_test_YOUR_KEY_HERE'; // Replace with your actual key
  static const String _appName = 'Vedika Healthcare';

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
          _buildOrderSummary(),
          const SizedBox(height: 20),
          _buildPriceBreakdown(),
          const SizedBox(height: 24),
          _buildPayNowButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Product Order Summary',
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
                        child: Image.asset(
                          product['image'],
                          fit: BoxFit.cover,
                        ),
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
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Order placed successfully.'),
          backgroundColor: Colors.green[600],
        ),
      );

      // Clear the cart after successful payment
      widget.onOrderPlaced?.call();

      print('✅ [ProductOrderSummarySheet] Cart cleared after successful payment');

      // Close the summary sheet
      Navigator.pop(context);
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
