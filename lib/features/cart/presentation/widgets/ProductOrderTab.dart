import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/cart/presentation/viewmodel/ProductCartViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/widgets/ChooseAddressSheet.dart';
import 'package:vedika_healthcare/features/cart/presentation/widgets/ProductOrderSummarySheet.dart';

class ProductOrderTab extends StatefulWidget {
  const ProductOrderTab({Key? key}) : super(key: key);

  @override
  State<ProductOrderTab> createState() => _ProductOrderTabState();
}

class _ProductOrderTabState extends State<ProductOrderTab> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductCartViewModel>(
      create: (_) => ProductCartViewModel()..loadCart(),
      child: Consumer<ProductCartViewModel>(
        builder: (context, vm, _) {
          final hasItems = vm.items.isNotEmpty;
          return Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (hasItems ? _buildProductList(vm) : _buildEmptyState()),
                ),
                if (hasItems) _buildBottomCheckoutBar(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(ProductCartViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.items.length,
      itemBuilder: (context, index) => _buildProductCard(vm, index),
    );
  }

  Widget _buildProductCard(ProductCartViewModel vm, int index) {
    final item = vm.items[index];
    final name = item.productName ?? 'Product';
    final price = item.price ?? 0.0;
    final qty = item.quantity ?? 0;
    final category = item.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image with fallback icon on error
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                ? Image.network(
                    item.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (category != null && category.isNotEmpty)
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (category != null && category.isNotEmpty)
                  const SizedBox(height: 6),
                // Price row with proper overflow handling
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          // Right side controls
          Column(
            children: [
              // Remove button
              IconButton(
                onPressed: () => vm.removeItem(item.cartId!),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 20,
                ),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(height: 8),
              
              // Quantity controls with increment/decrement
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decrement button
                    GestureDetector(
                      onTap: () => vm.decrementQuantity(item.cartId!),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (qty <= 1) ? Colors.grey[100] : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: (qty <= 1) ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                    
                    // Quantity display
                    Container(
                      width: 40,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Increment button
                    GestureDetector(
                      onTap: () => vm.incrementQuantity(item.cartId!),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: ColorPalette.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(ProductCartViewModel vm) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${vm.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.items.isNotEmpty ? () => _proceedToCheckout(vm) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_checkout, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToCheckout(ProductCartViewModel vm) async {
    final String? selectedAddressId = await showModalBottomSheet<String>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: ChooseAddressSheet(),
        );
      },
    );

    if (!mounted) return;
    if (selectedAddressId == null) return;

    // Build summary input from vm.items
    final products = vm.items.map((it) => {
          'image': it.imageUrl ?? '',
          'name': it.productName ?? 'Product',
          'description': it.category ?? '',
          'price': (it.price ?? 0.0),
          'quantity': (it.quantity ?? 0),
        }).toList();

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ProductOrderSummarySheet(
          products: products,
          addressId: selectedAddressId,
          onOrderPlaced: () async {
            await vm.loadCart();
          },
        );
      },
    );
  }
}
