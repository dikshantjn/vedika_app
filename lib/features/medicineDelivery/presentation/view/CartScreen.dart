import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/CheckoutSection.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: ColorPalette.primaryColor,
      ),
      drawer: DrawerMenu(),
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          final cartItems = cartViewModel.cartItems;
          return cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
            children: [
              Expanded(child: _buildCartItems(context, cartViewModel, cartItems)),
              CheckoutSection(cartViewModel: cartViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 90, color: Colors.grey),
          SizedBox(height: 12),
          Text('Your cart is empty!', style: TextStyle(fontSize: 18, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CartViewModel cartViewModel, List<MedicineProduct> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final medicine = cartItems[index];
        final isRemoved = medicine.quantity == 0;

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      medicine.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: isRemoved ? TextDecoration.lineThrough : TextDecoration.none,
                            color: isRemoved ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${medicine.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isRemoved ? Colors.grey : Colors.black87,
                            decoration: isRemoved ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildQuantitySelector(cartViewModel, medicine, isRemoved),
                ],
              ),
            ),

            // Remove Permanently Tag (Top-Right Corner)
            if (isRemoved)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: () => cartViewModel.removeItemPermanently(medicine.id),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Remove Permanently'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelector(CartViewModel cartViewModel, MedicineProduct medicine, bool isRemoved) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isRemoved ? Colors.grey.shade300 : Colors.grey.shade200,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 14, color: Colors.black87),
            onPressed: isRemoved || medicine.quantity <= 0
                ? null
                : () => cartViewModel.updateQuantity(medicine.id, medicine.quantity - 1),
          ),
          Text(
            '${medicine.quantity}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 14, color: Colors.black87),
            onPressed: () {
              if (isRemoved) {
                // If the item was removed, add it back with quantity = 1
                cartViewModel.updateQuantity(medicine.id, 1);
              } else {
                cartViewModel.updateQuantity(medicine.id, medicine.quantity + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}
