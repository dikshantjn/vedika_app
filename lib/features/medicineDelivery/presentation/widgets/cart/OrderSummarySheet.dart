import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchNearbyDeliveryPartners();
  }

  void _fetchNearbyDeliveryPartners() {
    final deliveryPartnerViewModel = Provider.of<DeliveryPartnerViewModel>(context, listen: false);

    // Use addPostFrameCallback to call the function after the current frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deliveryPartnerViewModel.fetchNearbyPartners(context);

      // Delay the setState until the data is fetched
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
        _priceRow('Delivery Charge', _deliveryCharge),
        _priceRow('Total', widget.cartViewModel.total, isBold: true),
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

  Widget _buildPayNowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _payNow();
        },
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

  // Method to handle the payment process
  void _payNow() {
    // Initialize the Razorpay service
    final razorPayService = MedicineOrderDeliveryRazorPayService();

    // Pass the delivery charge as amount to the Razorpay service
    razorPayService.openPaymentGateway(
      widget.cartViewModel.total.toDouble(),  // Convert to integer as Razorpay expects amount in paise
      ApiConstants.razorpayApiKey,  // Replace with your Razorpay API Key
      'Medicine Order Delivery',
      'Payment for your medicine delivery order',
    );
  }
}
