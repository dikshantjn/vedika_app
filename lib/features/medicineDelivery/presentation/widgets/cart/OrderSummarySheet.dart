import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for keyboard handling
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/DeliveryPartner/DeliveryPartner.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/OrderPlacedBottomSheet.dart';

class OrderSummarySheet extends StatefulWidget {
  final CartAndPlaceOrderViewModel cartViewModel;
  final addressId;

  const OrderSummarySheet({Key? key, required this.cartViewModel, required this.addressId}) : super(key: key);

  @override
  _OrderSummarySheetState createState() => _OrderSummarySheetState();
}

class _OrderSummarySheetState extends State<OrderSummarySheet> {
  bool _showOrderSummary = false;
  DeliveryPartner? _selectedPartner;
  double _deliveryCharge = 0.0;
  double _discount = 0.0;
  double _platformFee = 10.0;
  String _couponCode = '';
  bool _isCouponApplied = false;
  final TextEditingController _couponController = TextEditingController();
  final FocusNode _couponFocusNode = FocusNode(); // Added focus node for coupon field
  String _couponError = "";
  @override
  void initState() {
    super.initState();
    widget.cartViewModel.setOnPaymentSuccess(_handlePaymentSuccess);
    
    // Use addPostFrameCallback to set address ID after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.cartViewModel.setAddressId(widget.addressId);
    });
    
    _fetchNearbyDeliveryPartners();
    _setupKeyboardListeners();
  }

  @override
  void dispose() {
    widget.cartViewModel.setOnPaymentSuccess(null);
    _couponFocusNode.dispose(); // Clean up focus node
    super.dispose();
  }


  // Add this new method
  void _handlePaymentSuccess(String paymentId) {
    // Close the current bottom sheet
    Navigator.of(context).pop();

    // Show the success bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderPlacedBottomSheet.showOrderPlacedBottomSheet(context, paymentId);
    });
  }

  void _setupKeyboardListeners() {
    // Listen to keyboard visibility changes
    _couponFocusNode.addListener(() {
      if (_couponFocusNode.hasFocus) {
        // Scroll the sheet up when keyboard appears
        Future.delayed(const Duration(milliseconds: 300), () {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  void _fetchNearbyDeliveryPartners() {
    final deliveryPartnerViewModel = Provider.of<DeliveryPartnerViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      deliveryPartnerViewModel.fetchNearbyPartners(context);

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            if (deliveryPartnerViewModel.partners.isNotEmpty) {
              _selectedPartner = deliveryPartnerViewModel.partners.first;
              _deliveryCharge = deliveryPartnerViewModel.calculateDeliveryCharges(context, _selectedPartner!);
              widget.cartViewModel.setDeliveryCharge(_deliveryCharge);
            }
            _showOrderSummary = true;
          });
        }
      });
    });
  }

  void _applyCoupon() {
    if (_couponController.text.isEmpty) {
      setState(() {
        _couponError = "Please enter a coupon code.";
      });
      return;
    }

    // Call ViewModel method
    widget.cartViewModel.applyCoupon(_couponController.text);

    // Check if coupon is applied before proceeding
    if (!widget.cartViewModel.isCouponApplied) {
      setState(() {
        _couponError = "Invalid coupon code. Please try again.";
      });
      return;
    }

    setState(() {
      _isCouponApplied = widget.cartViewModel.isCouponApplied;
      _discount = widget.cartViewModel.discount;
      _couponError = ""; // Clear any previous error
    });

    // Dismiss keyboard before showing animation
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: Lottie.asset(
            'assets/animations/cheers.json',
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.9,
            repeat: false,
            fit: BoxFit.contain,
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
      ),
      child: Container(
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
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showOrderSummary) _loadingAnimation() else _buildOrderSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingAnimation() {
    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/findingDeliveryPartner.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'Finding Delivery Partner...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildOrderSummary() {
    final cartViewModel = widget.cartViewModel;
    final List<CartModel> cartItems = cartViewModel.cartItems; // Get stored cart items
    final Map<String, List<CartModel>> ordersGrouped = {};

    // If cart is empty, show message
    if (cartItems.isEmpty) {
      return Center(
        child: Text(
          "No orders found.",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Grouping cart items by order ID
    for (var item in cartItems) {
      ordersGrouped.putIfAbsent(item.orderId!, () => []).add(item);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                '${cartItems.length} Items',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              ...ordersGrouped.entries.map((entry) {
                String orderId = entry.key;
                List<CartModel> items = entry.value;

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
                              Icon(Icons.receipt_long, color: ColorPalette.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Order #${orderId.length > 12 ? '${orderId.substring(0, 8)}...' : orderId}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    if (entry.key != ordersGrouped.keys.last)
                      Divider(height: 1, color: Colors.grey[200]),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCouponSection(),
        if (cartViewModel.isCouponApplied) _discountBox(),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _priceRow('Subtotal', cartViewModel.subtotal),
              const SizedBox(height: 8),
              _priceRow('Delivery Charge', cartViewModel.deliveryCharge),
              const SizedBox(height: 8),
              _priceRow('Platform Fee', cartViewModel.total - cartViewModel.subtotal - cartViewModel.deliveryCharge + cartViewModel.discount),
              const Divider(height: 24),
              _priceRow('Total Amount', cartViewModel.total, isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPayNowButton(),
      ],
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

  Widget _buildCouponSection() {
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
              Icon(Icons.local_offer_outlined, color: ColorPalette.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Apply Coupon',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  focusNode: _couponFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorPalette.primaryColor),
                    ),
                    errorText: _couponError.isNotEmpty ? _couponError : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorPalette.primaryColor,
                      ColorPalette.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isCouponApplied ? null : _applyCoupon,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _discountBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green[700], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Discount Applied!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          Text(
            '- ₹${_discount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton() {
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
          onTap: _payNow,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
            ),
          ),
        ),
      ),
    );
  }

  void _payNow() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    // Ensure latest calculations before payment
    widget.cartViewModel.setDeliveryCharge(_deliveryCharge);
    widget.cartViewModel.setDiscount(_discount);
    widget.cartViewModel.setPlatformFee(_platformFee);

    // Recalculate total
    widget.cartViewModel.calculateTotal();

    // Ensuring total is positive
    if (widget.cartViewModel.total <= 0) {
      debugPrint("❌ Payment Aborted: Total amount is zero or negative.");
      return;
    }

    // Advanced Logging Before Payment Call
    debugPrint("✅ All checks passed. Proceeding to Razorpay...");

    // Ensuring `handlePayment` is called
    try {
      double amount = widget.cartViewModel.total.roundToDouble(); // ✅ Ensuring integer conversion
      widget.cartViewModel.handlePayment(amount);
      debugPrint("🎉 Razorpay Payment Triggered Successfully.");
    } catch (e, stackTrace) {
      debugPrint("❌ ERROR: Payment Failed.");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
    }
  }
}