import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/views/ProductPartnerAddProductPage.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../viewmodels/ProductPartnerProductsViewModel.dart';
import '../viewmodels/ProductPartnerAddProductViewModel.dart';
import '../../data/models/VendorProduct.dart';

class ProductPartnerProductsPage extends StatelessWidget {
  const ProductPartnerProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerProductsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildSearchAndFilter(context, viewModel),
            Expanded(
              child: viewModel.products.isEmpty
                  ? _buildEmptyState(context)
                  : _buildProductGrid(context, viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, ProductPartnerProductsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: ProductPartnerColorPalette.spacing),
                  ),
                  onChanged: viewModel.setSearchQuery,
                ),
              ),
              const SizedBox(width: ProductPartnerColorPalette.smallSpacing),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<ProductPartnerAddProductViewModel>(
                        create: (_) => ProductPartnerAddProductViewModel(),
                        child: const ProductPartnerAddProductPage(),
                      ),
                    ),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: ProductPartnerColorPalette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(ProductPartnerColorPalette.smallSpacing),
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final category = viewModel.categories[index];
                final isSelected = category == viewModel.selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        viewModel.setCategory(category);
                      }
                    },
                    backgroundColor: ProductPartnerColorPalette.quickActionBg,
                    selectedColor: ProductPartnerColorPalette.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? ProductPartnerColorPalette.primary : ProductPartnerColorPalette.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductPartnerProductsViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: ProductPartnerColorPalette.spacing,
        mainAxisSpacing: ProductPartnerColorPalette.spacing,
      ),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return _buildProductCard(context, product, viewModel);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, VendorProduct product, ProductPartnerProductsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        border: Border.all(color: ProductPartnerColorPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ProductPartnerColorPalette.cardBorderRadius),
                ),
                child: Image.network(
                  product.images.first,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: ProductPartnerColorPalette.quickActionBg,
                      child: const Icon(Icons.image, size: 40),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isActive
                        ? ProductPartnerColorPalette.success.withOpacity(0.9)
                        : ProductPartnerColorPalette.error.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(ProductPartnerColorPalette.smallSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: ProductPartnerColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ProductPartnerColorPalette.primary,
                      ),
                    ),
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: ProductPartnerColorPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        product.isActive ? Icons.toggle_on : Icons.toggle_off,
                        color: product.isActive ? ProductPartnerColorPalette.success : ProductPartnerColorPalette.error,
                        size: 28,
                      ),
                      onPressed: () => viewModel.toggleProductStatus(product.productId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: ProductPartnerColorPalette.primary,
                      onPressed: () {
                        // TODO: Navigate to edit product page
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: ProductPartnerColorPalette.error,
                      onPressed: () {
                        // TODO: Show delete confirmation dialog
                        viewModel.deleteProduct(product.productId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: ProductPartnerColorPalette.textSecondary,
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ProductPartnerColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: ProductPartnerColorPalette.smallSpacing),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              fontSize: 14,
              color: ProductPartnerColorPalette.textSecondary,
            ),
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider<ProductPartnerAddProductViewModel>(
                    create: (_) => ProductPartnerAddProductViewModel(),
                    child: const ProductPartnerAddProductPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProductPartnerColorPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: ProductPartnerColorPalette.spacing,
                vertical: ProductPartnerColorPalette.smallSpacing,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 