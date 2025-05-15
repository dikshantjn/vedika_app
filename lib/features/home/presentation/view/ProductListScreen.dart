import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ProductViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ProductDetailScreen.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/CategoryColorPalette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';

class ProductListScreen extends StatefulWidget {
  final String category;
  final String? subCategory;

  const ProductListScreen({
    Key? key,
    required this.category,
    this.subCategory,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Price: Low to High', 'Price: High to Low', 'Popular'];

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dental care':
        return Icons.medical_services_outlined;
      case 'heart care':
        return Icons.favorite;
      case 'baby care':
        return Icons.child_care;
      case 'medicine':
        return Icons.medication;
      case 'lab test':
        return Icons.science;
      case 'blood bank':
        return Icons.bloodtype;
      case 'clinic':
        return Icons.local_hospital;
      case 'hospital':
        return Icons.medical_services;
      case 'ambulance':
        return Icons.emergency;
      default:
        return Icons.category;
    }
  }

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ProductViewModel>();
    // Schedule the loading for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  void _loadProducts() {
    if (widget.subCategory != null) {
      _viewModel.loadProductsBySubCategory(widget.subCategory!);
    } else {
      _viewModel.loadProductsByCategory(widget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColors = CategoryColorPalette.categoryGradients[widget.category.toLowerCase()] ?? 
        CategoryColorPalette.categoryGradients['medicine']!;
    final categoryColor = CategoryColorPalette.getCategoryTextColor(widget.category);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: categoryColor.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light,
        ),
        child: Column(
          children: [
            // Header section with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: categoryColors,
                ),
              ),
              child: Stack(
                children: [
                  // Faded large icon
                  Positioned(
                    right: -30,
                    top: statusBarHeight - 10,
                    child: Icon(
                      _getCategoryIcon(widget.category),
                      size: 220,
                      color: categoryColor.withOpacity(0.12),
                    ),
                  ),
                  Column(
                    children: [
                      _buildCategoryHeader(categoryColor),
                      _buildSearchBar(categoryColor),
                      _buildFilterChips(categoryColor),
                    ],
                  ),
                ],
              ),
            ),
            // Products section with white background
            Expanded(
              child: Consumer<ProductViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${viewModel.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (viewModel.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.subCategory != null
                                ? 'No products found in ${widget.subCategory}'
                                : 'No products found in ${widget.category}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check back later or try a different category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadProducts,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: categoryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: viewModel.products.length,
                    itemBuilder: (context, index) {
                      final product = viewModel.products[index];
                      return _buildProductCard(context, product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(Color categoryColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: categoryColor,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(widget.category),
              color: categoryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Category text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.subCategory != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subCategory!,
                    style: TextStyle(
                      fontSize: 14,
                      color: categoryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color categoryColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: categoryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search ${widget.category}...',
            hintStyle: TextStyle(
              color: categoryColor.withOpacity(0.5),
            ),
            prefixIcon: Icon(Icons.search, color: categoryColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            _viewModel.searchProducts(value);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(Color categoryColor) {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : categoryColor,
              ),
              backgroundColor: Colors.white,
              selectedColor: categoryColor,
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                // TODO: Implement filter logic
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, VendorProduct product) {
    final categoryColor = CategoryColorPalette.getCategoryTextColor(widget.category);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: product.images.isNotEmpty ? product.images[0] : '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Price tiers badge
                  if (product.priceTiers != null && product.priceTiers!.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${product.priceTiers!.length} Plans',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price section
                    if (product.priceTiers != null && product.priceTiers!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'From ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '₹${product.priceTiers!.first.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 