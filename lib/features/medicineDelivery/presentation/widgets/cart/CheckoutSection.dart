import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseAddressSheet.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/OrderSummarySheet.dart';

class CheckoutSection extends StatelessWidget {
  final CartAndPlaceOrderViewModel cartViewModel;

  const CheckoutSection({Key? key, required this.cartViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: _buildCheckoutButton(context),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(

        onPressed: () => _showChooseAddressBottomSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ChooseAddressSheet(
          onAddressConfirmed: () {}, // Handled via Navigator.pop()
        );
      },
    );

    if (selectedAddressId != null) {
      _showOrderSummaryBottomSheet(context, selectedAddressId);
    }
  }

  void _showOrderSummaryBottomSheet(BuildContext context, String addressId) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return OrderSummarySheet(cartViewModel: cartViewModel, addressId: addressId);
      },
    );
  }
}
