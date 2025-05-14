import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/views/ProductPartnerAddProductPage.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../viewmodels/ProductPartnerProductsViewModel.dart';
import '../viewmodels/ProductPartnerAddProductViewModel.dart';
import '../../data/models/VendorProduct.dart';

class ProductPartnerProductsPage extends StatefulWidget {
  const ProductPartnerProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductPartnerProductsPage> createState() => _ProductPartnerProductsPageState();
}

class _ProductPartnerProductsPageState extends State<ProductPartnerProductsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductPartnerProductsViewModel>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerProductsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ProductPartnerColorPalette.error,
                ),
                const SizedBox(height: ProductPartnerColorPalette.spacing),
                Text(
                  'Error loading products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ProductPartnerColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: ProductPartnerColorPalette.smallSpacing),
                Text(
                  viewModel.error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: ProductPartnerColorPalette.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ProductPartnerColorPalette.spacing),
                ElevatedButton.icon(
                  onPressed: () {
                      viewModel.fetchProducts();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<ProductPartnerAddProductViewModel>(
                        create: (_) => ProductPartnerAddProductViewModel(),
                        child: const ProductPartnerAddProductPage(),
                      ),
                    ),
                  );
                  // Refresh products if a new product was added
                  if (result == true) {
                    viewModel.fetchProducts();
                  }
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
      width: 170,
      height: 250,
      margin: const EdgeInsets.only(right: ProductPartnerColorPalette.smallSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with fixed height
          Stack(
            children: [
              SizedBox(
                height: 120,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(ProductPartnerColorPalette.cardBorderRadius)),
                  child: Image.network(
                    product.images.isNotEmpty ? product.images[0] : 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(ProductPartnerColorPalette.primary),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: ProductPartnerColorPalette.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: ProductPartnerColorPalette.error, size: 20),
                          const SizedBox(width: 8),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider<ProductPartnerAddProductViewModel>(
                            create: (_) => ProductPartnerAddProductViewModel(),
                            child: ProductPartnerAddProductPage(product: product),
                          ),
                        ),
                      );
                      if (result == true) {
                        viewModel.fetchProducts();
                      }
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Product'),
                          content: const Text('Are you sure you want to delete this product?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: ProductPartnerColorPalette.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        try {
                          await viewModel.deleteProduct(product.productId!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text('Product deleted successfully'),
                                  ],
                                ),
                                backgroundColor: ProductPartnerColorPalette.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Failed to delete product: ${e.toString()}'),
                                    ),
                                  ],
                                ),
                                backgroundColor: ProductPartnerColorPalette.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          // Content Section with fixed height
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(ProductPartnerColorPalette.smallSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: ProductPartnerColorPalette.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.isActive 
                              ? ProductPartnerColorPalette.success.withOpacity(0.1)
                              : ProductPartnerColorPalette.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: product.isActive 
                                ? ProductPartnerColorPalette.success
                                : ProductPartnerColorPalette.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider<ProductPartnerAddProductViewModel>(
                    create: (_) => ProductPartnerAddProductViewModel(),
                    child: const ProductPartnerAddProductPage(),
                  ),
                ),
              );
              // Refresh products if a new product was added
              if (result == true) {
                context.read<ProductPartnerProductsViewModel>().fetchProducts();
              }
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