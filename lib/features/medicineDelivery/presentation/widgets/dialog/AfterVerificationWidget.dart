import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/CartService.dart';

class AfterVerificationWidget extends StatefulWidget {
  final MedicalStore selectedStore;
  final VoidCallback onGoToCart;

  const AfterVerificationWidget({
    Key? key,
    required this.selectedStore,
    required this.onGoToCart,
  }) : super(key: key);

  @override
  _AfterVerificationWidgetState createState() => _AfterVerificationWidgetState();
}

class _AfterVerificationWidgetState extends State<AfterVerificationWidget> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _autoAddToCart();
  }

  /// Automatically adds all medicines to the cart
  void _autoAddToCart() {
    for (var medicine in widget.selectedStore.medicines) {
      _cartService.addToCart(medicine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Verification Done!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 10),
        Text(
          'Verified by: ${widget.selectedStore.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        Text(
          'Address: ${widget.selectedStore.address}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54),
        ),
        const SizedBox(height: 20),

        /// Medicine List
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medicines Added',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 250,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(widget.selectedStore.medicines.length, (index) {
                      final medicine = widget.selectedStore.medicines[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                medicine.imageUrl.first,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
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
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Price: ₹${medicine.price}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        /// Go to Cart Button
        ElevatedButton(
          onPressed: widget.onGoToCart,
          child: const Text('Go to Cart', style: TextStyle(fontSize: 16, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
