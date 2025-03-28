import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for keyboard handling
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderDeliveryRazorPayService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/DeliveryPartner/DeliveryPartner.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';

class OrderSummarySheet extends StatefulWidget {
  final CartViewModel cartViewModel;

  const OrderSummarySheet({Key? key, required this.cartViewModel}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
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
    if (_couponController.text.isEmpty) return;

    setState(() {
      _isCouponApplied = true;
      _discount = widget.cartViewModel.subtotal * 0.1; // 10% discount
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
    double total = widget.cartViewModel.subtotal + _deliveryCharge + _platformFee - _discount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Divider(),
        _priceRow('Subtotal', widget.cartViewModel.subtotal),
        _buildCouponSection(),
        if (_isCouponApplied) _discountBox(),
        _priceRow('Delivery Charge', _deliveryCharge),
        _priceRow('Platform Fee', _platformFee),
        _priceRow('Total', total, isBold: true),
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
              focusNode: _couponFocusNode, // Assign focus node
              decoration: InputDecoration(
                hintText: 'Enter Coupon Code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isCouponApplied ? null : _applyCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    // Dismiss keyboard before payment
    FocusScope.of(context).unfocus();

    final razorPayService = MedicineOrderDeliveryRazorPayService();
    razorPayService.openPaymentGateway(
      widget.cartViewModel.total.toDouble(),
      ApiConstants.razorpayApiKey,
      'Medicine Order Delivery',
      'Payment for your medicine delivery order',
    );
  }
}