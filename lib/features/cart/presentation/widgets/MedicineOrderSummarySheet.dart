import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartPaymentService.dart';
import 'package:vedika_healthcare/features/cart/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MedicineOrderSummarySheet extends StatefulWidget {
  final List<Order> medicineOrders;
  final String addressId;

  MedicineOrderSummarySheet({
    Key? key, 
    required this.medicineOrders, 
    required this.addressId,
  }) : super(key: key);

  @override
  _MedicineOrderSummarySheetState createState() => _MedicineOrderSummarySheetState();
}

class _MedicineOrderSummarySheetState extends State<MedicineOrderSummarySheet> {
  double _deliveryCharge = 20.0;
  double _platformFee = 10.0;
  bool _isProcessingPayment = false;
  
  // Payment service and view model
  late CartPaymentService _paymentService;
  late CartViewModel _cartViewModel;
  
  // Razorpay configuration (you should move these to environment variables)
  static const String _razorpayKey = 'rzp_test_YOUR_KEY_HERE'; // Replace with your actual key
  static const String _appName = 'Vedika Healthcare';
  
  // Order placement state
  bool _isOrderPlaced = false;
  Order? _placedOrderDetails;
  
  // Payment state
  bool _isPaymentFailed = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
  }
  
  void _initializePaymentService() {
    _paymentService = CartPaymentService();
    _cartViewModel = CartViewModel();
    
    // Set up payment callbacks
    _paymentService.onPaymentSuccess = _handlePaymentSuccess;
    _paymentService.onPaymentError = _handlePaymentError;
    _paymentService.onOrderPlacementRequired = _handleOrderPlacementRequired;
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
            _buildPaymentSuccessUI(),
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
          'Medicine Order Summary',
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
            '${widget.medicineOrders.length} Orders',
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
        children: widget.medicineOrders.map((order) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medication_outlined, color: ColorPalette.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child:                         Text(
                          'Order #${order.orderId}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.vendor?.name ?? 'Medical Store',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child:                         Text(
                          'Prescription ID: ${order.prescriptionId.substring(0, 8)}...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        ),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (order.note != null && order.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.note_outlined, color: Colors.orange[600], size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.note!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (order != widget.medicineOrders.last)
                Divider(height: 1, color: Colors.grey[200]),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final subtotal = widget.medicineOrders.fold<double>(
      0.0, 
      (sum, order) => sum + order.totalAmount,
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
    final subtotal = widget.medicineOrders.fold<double>(
      0.0, 
      (sum, order) => sum + order.totalAmount,
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
    _paymentService.openMedicinePaymentGateway(
      amount: totalAmount,
      key: ApiConstants.razorpayApiKey,
      name: _appName,
      description: 'Medicine Order - ${widget.medicineOrders.length} orders',
      orderId: widget.medicineOrders.first.orderId, // Use first order ID for now
      addressId: widget.addressId,
    );
  }

    void _handleOrderPlacementRequired(String orderId, String addressId, String paymentId) {
    print('🎯 [MedicineOrderSummarySheet] Order placement required for: $orderId');
    print('📊 [MedicineOrderSummarySheet] Available orders: ${widget.medicineOrders.length}');
    print('📊 [MedicineOrderSummarySheet] Order IDs: ${widget.medicineOrders.map((o) => o.orderId).toList()}');
    
    // Call the view model to handle order placement
    _cartViewModel.handlePaymentSuccess(
      orderId: orderId,
      addressId: addressId,
      paymentId: paymentId,
    ).then((success) {
      if (success) {
        setState(() {
          _isOrderPlaced = true;
          // Find the order from the current widget's medicineOrders instead of the view model
          try {
            if (widget.medicineOrders.isNotEmpty) {
              _placedOrderDetails = widget.medicineOrders.firstWhere(
                (order) => order.orderId == orderId,
                orElse: () => widget.medicineOrders.first,
              );
            } else {
              print('⚠️ [MedicineOrderSummarySheet] No orders available in widget');
              _placedOrderDetails = null;
            }
          } catch (e) {
            print('🚨 [MedicineOrderSummarySheet] Error finding order: $e');
            // If we can't find the order, set to null
            _placedOrderDetails = null;
          }
          
          // If we still don't have order details, create a minimal one
          if (_placedOrderDetails == null) {
            print('⚠️ [MedicineOrderSummarySheet] Creating fallback order details');
            // We'll handle this in the UI by showing basic information
          }
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${_cartViewModel.orderPlacementError ?? 'Unknown error'}'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    });
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
        // Don't close the sheet, let the order placement callback handle it
      });
      
      print('🎯 [MedicineOrderSummarySheet] Payment success received, waiting for order placement...');
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
        _isPaymentFailed = true;
      });
      
      print('❌ [MedicineOrderSummarySheet] Payment failed: ${response.message}');
    }
  }

  Widget _buildPaymentFailureUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Failure Icon Container
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
          
          const SizedBox(height: 32),
          
          // Failure Message
          Text(
            'Payment Failed',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'We couldn\'t process your payment',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Please try again or use a different payment method',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Retry Button
          Container(
            width: double.infinity,
            height: 60,
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
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _isProcessingPayment = false;
                    _isPaymentFailed = false;
                  });
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Close Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProcessingUI() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Animated loading circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we complete your transaction',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSuccessUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Success Animation Container
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
          
          const SizedBox(height: 32),
          
          // Success Message
          Text(
            'Payment Successful! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Your medicine order has been placed successfully',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Order ID: ${_placedOrderDetails?.orderId ?? 'Processing...'}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Track Order Button - Modern Design
          Container(
            width: double.infinity,
            height: 60,
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
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Navigate to track order screen using MainScreen navigation
                  final scope = MainScreenScope.maybeOf(context);
                  if (scope != null) {
                    scope.setIndex(4); // Track Order screen is at index 4
                  } else {
                    // Fallback navigation if MainScreen scope is not available
                    Navigator.pushNamed(context, AppRoutes.trackOrderScreen);
                  }
                  // Close the bottom sheet
                  Navigator.pop(context);
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes_outlined, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Track Your Order',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Close Button - Minimal Design
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }


  
  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
