import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/cart/CheckoutSection.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.primaryColor,
        centerTitle: true,
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: Consumer<CartAndPlaceOrderViewModel>(
        builder: (context, cartViewModel, child) {
          final cartItems = cartViewModel.cartItems;
          final productCartItems = cartViewModel.productCartItems;

          if (cartViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              ),
            );
          }

          if (cartItems.isEmpty && productCartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (cartItems.isNotEmpty) ...[
                      Text(
                        'Medicine Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...cartItems.map((item) => _buildCartItem(context, cartViewModel, item)),
                      SizedBox(height: 24),
                    ],
                    if (productCartItems.isNotEmpty) ...[
                      Text(
                        'Product Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...productCartItems.map((item) => _buildProductCartItem(context, item, cartViewModel)),
                    ],
                  ],
                ),
              ),
              CheckoutSection(cartViewModel: cartViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCartItem(BuildContext context, ProductCart cartItem, CartAndPlaceOrderViewModel viewModel) {
    // Find the corresponding product details
    final productDetails = viewModel.productDetails.firstWhere(
      (product) => product.productId == cartItem.productId,
      orElse: () => VendorProduct(
        productId: cartItem.productId ?? '',
        vendorId: '',
        name: cartItem.productName ?? 'Product',
        description: '',
        howItWorks: '',
        usp: [],
        price: cartItem.price ?? 0.0,
        images: cartItem.imageUrl != null ? [cartItem.imageUrl!] : [],
        isActive: true,
        stock: 0,
        category: '',
        highlights: [],
        comingSoon: false,
        rating: 0.0,
        reviewCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Use fallback values if product details are missing
    final displayName = productDetails.name.isNotEmpty ? productDetails.name : (cartItem.productName ?? 'Product');
    final displayPrice = productDetails.price > 0 ? productDetails.price : (cartItem.price ?? 0.0);
    final displayImages = productDetails.images.isNotEmpty ? productDetails.images : (cartItem.imageUrl != null ? [cartItem.imageUrl!] : []);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: displayImages.isNotEmpty
                ? Image.network(
                    displayImages.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${displayPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () async {
                        if (cartItem.quantity != null && cartItem.quantity! > 1) {
                          try {
                            await viewModel.updateProductCartQuantity(
                              cartItem.cartId!,
                              cartItem.quantity! - 1,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quantity updated'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating quantity: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    Text(
                      '${cartItem.quantity ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () async {
                        if (cartItem.quantity != null) {
                          try {
                            await viewModel.updateProductCartQuantity(
                              cartItem.cartId!,
                              cartItem.quantity! + 1,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quantity updated'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating quantity: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              try {
                await viewModel.deleteProductFromCart(cartItem.cartId!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item removed from cart'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error removing item: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: ColorPalette.primaryColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Your cart is empty!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to your cart to proceed',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Shopping',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartAndPlaceOrderViewModel cartViewModel, CartModel item) {
    final isRemoved = item.quantity == 0;

    if (item.isProduct) {
      // Display product item
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.shopping_bag_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            )
                          : Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: isRemoved ? TextDecoration.lineThrough : TextDecoration.none,
                            color: isRemoved ? Colors.grey : Colors.black87,
                          ),
                        ),
                        if (item.category != null) ...[
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.category!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildQuantitySelector(cartViewModel, item, isRemoved),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                    ),
                    onPressed: () {
                      _removeItemFromCart(cartViewModel, item.cartId, context);
                    },
                  ),
                ],
              ),
            ),
            if (!isRemoved)
              Container(
                height: 1,
                color: Colors.grey.shade100,
              ),
          ],
        ),
      );
    } else {
      // Display medicine item
      return FutureBuilder<List<MedicineProduct>>(
        future: cartViewModel.fetchProductByCartId(item.cartId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching product details"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No product details available"));
          }

          final product = snapshot.data!.first;
          String imageUrl = product.productURLs.isNotEmpty ? product.productURLs.first : '';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.medication_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                )
                              : Icon(
                                  Icons.medication_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                        ),
                      ),
                      SizedBox(width: 16),
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
                                color: isRemoved ? Colors.grey : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColorPalette.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildQuantitySelector(cartViewModel, item, isRemoved),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                        onPressed: () {
                          _removeItemFromCart(cartViewModel, item.cartId, context);
                        },
                      ),
                    ],
                  ),
                ),
                if (!isRemoved)
                  Container(
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _removeItemFromCart(CartAndPlaceOrderViewModel cartViewModel, String cartId, BuildContext context) async {
    await cartViewModel.removeFromCart(cartId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Item removed from cart"),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(CartAndPlaceOrderViewModel cartViewModel, CartModel item, bool isRemoved) {
    return Container(
      decoration: BoxDecoration(
        color: isRemoved ? Colors.grey.shade200 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRemoved ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 16,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          Text(
            'Quantity: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${item.quantity}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isRemoved ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
