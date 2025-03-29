import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for keyboard handling
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/DeliveryPartner/DeliveryPartner.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';

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
    widget.cartViewModel.setAddressId(widget.addressId);
    _fetchNearbyDeliveryPartners();
    _setupKeyboardListeners();
  }

  @override
  void dispose() {
    _couponFocusNode.dispose(); // Clean up focus node
    super.dispose();
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
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
          const SizedBox(height: 8),
          const Text(
            'Finding Delivery Partner...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
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
      return const Center(
        child: Text("No orders found."),
      );
    }

    // Grouping cart items by order ID
    for (var item in cartItems) {
      ordersGrouped.putIfAbsent(item.orderId!, () => []).add(item);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Divider(),

        // 🛒 **Display Grouped Orders**
        ...ordersGrouped.entries.map((entry) {
          String orderId = entry.key;
          List<CartModel> items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: $orderId',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _priceRow('${item.name} (x${item.quantity})', item.price * item.quantity),
                );
              }).toList(),
              const Divider(),
            ],
          );
        }).toList(),

        _buildCouponSection(),
        if (cartViewModel.isCouponApplied) _discountBox(),

        // 💰 **Price Breakdown**
        _priceRow('Subtotal', cartViewModel.subtotal),
        _priceRow('Delivery Charge', cartViewModel.deliveryCharge),
        _priceRow('Platform Fee', cartViewModel.total - cartViewModel.subtotal - cartViewModel.deliveryCharge + cartViewModel.discount), // Ensure accurate fee display
        _priceRow('Total', cartViewModel.total, isBold: true),

        const SizedBox(height: 12),
        _buildPayNowButton(),
      ],
    );
  }



  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              focusNode: _couponFocusNode,
              decoration: InputDecoration(
                hintText: 'Enter Coupon Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Smaller border radius
                  borderSide: const BorderSide(color: Colors.grey), // Outlined border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue), // Highlight when focused
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                errorText: _couponError.isNotEmpty ? _couponError : null, // Shows error in TextField
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _isCouponApplied ? null : _applyCoupon,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ColorPalette.primaryColor), // Outlined border
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Smaller border radius
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: ColorPalette.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _discountBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Discount Applied!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            Text('- ₹${_discount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildPayNowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _payNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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