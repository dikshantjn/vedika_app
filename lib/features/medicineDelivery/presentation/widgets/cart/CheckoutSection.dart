import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseAddressSheet.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/OrderSummarySheet.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/OrderService.dart';

class CheckoutSection extends StatelessWidget {
  final CartAndPlaceOrderViewModel cartViewModel;

  const CheckoutSection({Key? key, required this.cartViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: _buildCheckoutButton(context),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showChooseAddressBottomSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showChooseAddressBottomSheet(BuildContext context) async {
    final String? selectedAddressId = await showModalBottomSheet<String>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ChooseAddressSheet();
      },
    );

    if (selectedAddressId != null) {
      _showOrderSummaryBottomSheet(context, selectedAddressId);
    }
  }

  void _showOrderSummaryBottomSheet(BuildContext context, String addressId) async {
    // Use OrderService to check selfDelivery status for all orderIds in the cart
    final orderService = OrderService();
    final orderIds = cartViewModel.cartItems.map((item) => item.orderId).toSet();
    bool hasAnyOrderWithSelfDeliveryFalse = false;
    for (final orderId in orderIds) {
      final isSelfDelivery = await orderService.getSelfDeliveryStatus(orderId);
      if (!isSelfDelivery) {
        hasAnyOrderWithSelfDeliveryFalse = true;
        break;
      }
    }
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return OrderSummarySheet(
          cartViewModel: cartViewModel,
          addressId: addressId,
          forceShowDeliveryPartner: hasAnyOrderWithSelfDeliveryFalse,
        );
      },
    );
  }
}
