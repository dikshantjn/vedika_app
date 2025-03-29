import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/CheckoutSection.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartAndPlaceOrderViewModel>(context, listen: false).fetchOrdersAndCartItems();
    });
  }

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
      drawer:  DrawerMenu(),
      body: Consumer<CartAndPlaceOrderViewModel>(
        builder: (context, cartViewModel, child) {
          final cartItems = cartViewModel.cartItems;

          if (cartViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
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

  Widget _buildCartItems(BuildContext context, CartAndPlaceOrderViewModel cartViewModel, List<CartModel> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final medicine = cartItems[index];
        final isRemoved = medicine.quantity == 0;

        return FutureBuilder<List<MedicineProduct>>(
          future: cartViewModel.fetchProductByCartId(medicine.cartId),
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

            final product = snapshot.data!.first;
            String imageUrl = product.productURLs.isNotEmpty ? product.productURLs.first : '';

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
                          imageUrl,
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
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isRemoved ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isRemoved ? Colors.grey : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
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

                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _removeItemFromCart(cartViewModel, medicine.cartId, context);
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

  Future<void> _removeItemFromCart(CartAndPlaceOrderViewModel cartViewModel, String cartId, BuildContext context) async {
    await cartViewModel.removeFromCart(cartId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item removed from cart"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildQuantitySelector(CartAndPlaceOrderViewModel cartViewModel, CartModel medicine, bool isRemoved) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isRemoved ? Colors.grey.shade300 : Colors.grey.shade200,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quantity: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
            ),
          ),
          Text(
            '${medicine.quantity}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
