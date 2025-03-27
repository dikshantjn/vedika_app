import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';

class SelectedMedicineWidget extends StatelessWidget {
  final CartModel cartItem;
  final TextEditingController quantityController;
  final Function(int) onQuantityChanged;
  final Function() onDelete;

  const SelectedMedicineWidget({
    Key? key,
    required this.cartItem,
    required this.quantityController,
    required this.onQuantityChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to top
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

          // Medicine Details (Wraps text instead of ellipsis)
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
                  softWrap: true, // Enable line breaks
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
                onPressed: cartItem.quantity > 1 ? () => onQuantityChanged(cartItem.quantity - 1) : null,
              ),
              Text(
                cartItem.quantity.toString(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.blueAccent),
                onPressed: () => onQuantityChanged(cartItem.quantity + 1),
              ),
            ],
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
