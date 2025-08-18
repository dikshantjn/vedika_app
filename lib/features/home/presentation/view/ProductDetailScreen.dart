import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/CategoryColorPalette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ProductCartViewModel.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductCartService.dart';
import 'package:dio/dio.dart';

class ProductDetailScreenWrapper extends StatelessWidget {
  final VendorProduct product;

  const ProductDetailScreenWrapper({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductCartViewModel(
        ProductCartService(Dio()),
      ),
      child: ProductDetailScreen(product: product),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final VendorProduct product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final List<String> _mediaUrls = [];
  bool _isLiked = false;
  bool _hasCheckedCart = false;

  // Color palette for product details
  final Map<String, Color> _colorPalette = {
    'primary': const Color(0xFF2196F3),    // Blue
    'secondary': const Color(0xFF4CAF50),  // Green
    'accent': const Color(0xFFFFC107),     // Amber
    'background': Colors.white,
    'text': const Color(0xFF333333),
    'textLight': const Color(0xFF666666),
    'divider': const Color(0xFFEEEEEE),
  };

  @override
  void initState() {
    super.initState();
    // Combine all images into a single list
    _mediaUrls.addAll(widget.product.images);
    if (widget.product.additionalImages != null) {
      _mediaUrls.addAll(widget.product.additionalImages!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColorPalette.getCategoryTextColor(widget.product.category);
    
    return ChangeNotifierProvider(
      create: (context) => ProductCartViewModel(
        ProductCartService(Dio()),
      ),
      child: Builder(
        builder: (context) {
          // Check cart status once when the widget is built
          if (!_hasCheckedCart && widget.product.productId != null) {
            _hasCheckedCart = true;
            print('Initiating cart status check for product: ${widget.product.productId}');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final cartViewModel = context.read<ProductCartViewModel>();
              cartViewModel.checkCartStatus(widget.product.productId!);
            });
          }

          return Consumer<ProductCartViewModel>(
            builder: (context, cartViewModel, child) {
              print('Building UI with cart status: ${cartViewModel.isInCart}');
              return Scaffold(
                backgroundColor: _colorPalette['background'],
                body: CustomScrollView(
                  slivers: [
                    _buildAppBar(context, categoryColor),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductName(categoryColor),
                            const SizedBox(height: 16),
                            _buildUSP(categoryColor),
                            const SizedBox(height: 24),
                            _buildPriceTiers(categoryColor),
                            const SizedBox(height: 24),
                            _buildHowToUse(categoryColor),
                            const SizedBox(height: 24),
                            _buildHighlights(categoryColor),
                            const SizedBox(height: 24),
                            if (widget.product.demoLink != null) _buildDemoLink(context, categoryColor),
                            const SizedBox(height: 32),
                            _buildActionButtons(context, categoryColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color categoryColor) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image Carousel
            if (_mediaUrls.isEmpty)
              Container(
                color: Colors.grey[100],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: _mediaUrls.length > 1,
                  autoPlay: _mediaUrls.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: _mediaUrls.map((url) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey[100],
                        child: CachedNetworkImage(
                          imageUrl: url,
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
                      );
                    },
                  );
                }).toList(),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Image pagination dots
            if (_mediaUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _mediaUrls.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: categoryColor,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: _isLiked ? Colors.red : categoryColor,
            ),
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              // TODO: Implement like functionality
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              // TODO: Implement share functionality
            },
            color: categoryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductName(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUSP(Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: categoryColor),
              const SizedBox(width: 8),
              const Text(
                'Unique Selling Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.product.usp.map((usp) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: categoryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    usp,
                    style: TextStyle(
                      fontSize: 16,
                      color: _colorPalette['textLight'],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPriceTiers(Color categoryColor) {
    if (widget.product.priceTiers == null || widget.product.priceTiers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.price_check, color: categoryColor),
            const SizedBox(width: 8),
            const Text(
              'Pricing Plans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.product.priceTiers!.length,
            itemBuilder: (context, index) {
              final tier = widget.product.priceTiers![index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tier.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${tier.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (tier.description != null) ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              tier.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: _colorPalette['textLight'],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Select Plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHowToUse(Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorPalette['background'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _colorPalette['divider']!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: categoryColor),
              const SizedBox(width: 8),
              const Text(
                'How to Use',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.howItWorks,
            style: TextStyle(
              fontSize: 16,
              color: _colorPalette['textLight'],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: categoryColor),
            const SizedBox(width: 8),
            const Text(
              'Highlights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.product.highlights.map((highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: categoryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      highlight,
                      style: TextStyle(
                        fontSize: 16,
                        color: _colorPalette['textLight'],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDemoLink(BuildContext context, Color categoryColor) {
    return InkWell(
      onTap: () async {
        if (widget.product.demoLink != null) {
          final Uri url = Uri.parse(widget.product.demoLink!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.link,
              color: categoryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Visit Demo Website',
                style: TextStyle(
                  fontSize: 16,
                  color: categoryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: categoryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color categoryColor) {
    return Consumer<ProductCartViewModel>(
      builder: (context, cartViewModel, child) {
        print('Building action buttons with cart status: ${cartViewModel.isInCart}');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Price Display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.priceTiers != null && widget.product.priceTiers!.isNotEmpty
                          ? 'From ₹${widget.product.priceTiers!.first.price.toStringAsFixed(2)}'
                          : '₹${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Cart Button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: cartViewModel.isLoading 
                      ? null 
                      : () async {
                          if (widget.product.productId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product ID is missing'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (cartViewModel.isInCart) {
                            // Navigate to cart using AppRoutes
                            Navigator.pushNamed(context, AppRoutes.goToCart);
                          } else {
                            try {
                              await cartViewModel.addToCart(
                                productId: widget.product.productId!,
                                quantity: 1,
                                context: context,
                              );
                              
                              if (cartViewModel.error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart successfully'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${cartViewModel.error}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (cartViewModel.isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else ...[
                            Icon(
                              cartViewModel.isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cartViewModel.isInCart ? 'Go to Cart' : 'Add to Cart',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 