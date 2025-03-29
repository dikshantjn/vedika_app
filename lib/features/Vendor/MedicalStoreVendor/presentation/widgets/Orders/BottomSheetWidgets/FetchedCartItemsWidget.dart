import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';

class FetchedCartItemsWidget extends StatelessWidget {
  final List<CartModel> fetchedCartItems;
  final Function(String productId) onDelete;

  const FetchedCartItemsWidget({
    Key? key,
    required this.fetchedCartItems,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);

    return fetchedCartItems.isNotEmpty
        ? Column(
      children: fetchedCartItems.map((cartItem) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_services, color: Colors.blueAccent, size: 22),
              ),

              const SizedBox(width: 10),

              // Medicine Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹${cartItem.price.toStringAsFixed(2)} per unit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Selector
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.blueAccent),
                    onPressed: cartItem.quantity > 1
                        ? () => cartViewModel.updateCartItemQuantity(
                      cartItem.cartId,
                      "decrement",
                      context,
                    )
                        : null,
                  ),
                  Text(
                    cartItem.quantity.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.blueAccent),
                    onPressed: () => cartViewModel.updateCartItemQuantity(
                      cartItem.cartId,
                      "increment",
                      context,
                    ),
                  ),
                ],
              ),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                onPressed: () => onDelete(cartItem.cartId),
              ),
            ],
          ),
        );
      }).toList(),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No items in cart.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
