import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/CheckoutSection.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);

    // Fetch the cart items based on the user ID when the screen is loaded
    // Replace `userId` with the actual userId
    cartViewModel.fetchOrdersAndCartItems();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: ColorPalette.primaryColor,
      ),
      drawer:  DrawerMenu(),
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          return FutureBuilder<List<CartModel>>(
            future: cartViewModel.fetchOrdersAndCartItems(), // Call the future here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading indicator while fetching data
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)),
                );
              }

              final cartItems = snapshot.data ?? [];

              return cartItems.isEmpty
                  ? _buildEmptyCart()
                  : Column(
                children: [
                  Expanded(child: _buildCartItems(context, cartViewModel, cartItems)),
                  CheckoutSection(cartViewModel: cartViewModel),
                ],
              );
            },
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

  Widget _buildCartItems(BuildContext context, CartViewModel cartViewModel, List<CartModel> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final medicine = cartItems[index];
        final isRemoved = medicine.quantity == 0;

        return FutureBuilder<List<MedicineProduct>>(
          future: cartViewModel.fetchProductByCartId(medicine.cartId), // Fetch product details by cartId
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error fetching product details"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No product details available"));
            }

            final product = snapshot.data!.first; // Assuming there's only one product for each cart item

            // Get the first image URL from the productURLs list
            String imageUrl = product.productURLs.isNotEmpty ? product.productURLs.first : '';
            print("imageUrl $imageUrl");

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
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl, // Now using the correct image URL
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            size: 70,
                            color: Colors.grey,
                          ),
                        )
                            : const Icon(
                          Icons.image_not_supported,
                          size: 70,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name, // Now using product's name
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isRemoved ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isRemoved ? Colors.grey : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}', // Now using product's price
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isRemoved ? Colors.grey : Colors.black87,
                                decoration: isRemoved ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      _buildQuantitySelector(cartViewModel, medicine, isRemoved),

                    ],
                  ),
                ),

                // Delete Icon (Top-Right Corner)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _removeItemFromCart(cartViewModel, medicine.cartId, context); // Call remove function
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Method to handle item removal and show snackbar
  Future<void> _removeItemFromCart(CartViewModel cartViewModel, String cartId, BuildContext context) async {
    await cartViewModel.removeFromCart(cartId);

    // Show Snackbar after removal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item removed from cart"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showProductDetailsDialog(BuildContext context, MedicineProduct product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: ₹${product.price.toStringAsFixed(2)}'),
                Text('Manufacturer: ${product.manufacturer}'),
                const SizedBox(height: 10),
                // Display images if available
                if (product.productURLs.isNotEmpty)
                  Image.network(
                    product.productURLs.first, // Display the first image
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelector(CartViewModel cartViewModel, CartModel medicine, bool isRemoved) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isRemoved ? Colors.grey.shade300 : Colors.grey.shade200,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Placeholder text for Quantity
          Text(
            'Quantity: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
            ),
          ),
          // Display the quantity
          Text(
            '${medicine.quantity}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
