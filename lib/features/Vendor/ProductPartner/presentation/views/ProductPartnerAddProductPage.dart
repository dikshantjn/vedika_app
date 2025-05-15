import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../../data/models/VendorProduct.dart';
import '../viewmodels/ProductPartnerAddProductViewModel.dart';

class ProductPartnerAddProductPage extends StatefulWidget {
  final VendorProduct? product;
  
  const ProductPartnerAddProductPage({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<ProductPartnerAddProductPage> createState() => _ProductPartnerAddProductPageState();
}

class _ProductPartnerAddProductPageState extends State<ProductPartnerAddProductPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _howItWorksController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _uspController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _imagePicker = ImagePicker();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Schedule the initialization after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    print('Initializing form with product: ${widget.product?.toJson()}');
    if (widget.product != null) {
      print('Product ID: ${widget.product!.productId}');
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _howItWorksController.text = widget.product!.howItWorks;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _isActive = widget.product!.isActive;
      
      // Set the USPs in the ViewModel
      final viewModel = context.read<ProductPartnerAddProductViewModel>();
      for (final usp in widget.product!.usp) {
        viewModel.addUSP(usp);
      }
      
      // Set the images in the ViewModel
      for (final imageUrl in widget.product!.images) {
        viewModel.addImage(File(imageUrl));
      }

      // Set additional images in the ViewModel
      if (widget.product!.additionalImages != null) {
        for (final imageUrl in widget.product!.additionalImages!) {
          viewModel.addAdditionalImage(File(imageUrl));
        }
      }

      // Set other additional fields
      viewModel.setDemoLink(widget.product!.demoLink);
      viewModel.setVideoUrl(widget.product!.videoUrl);
      viewModel.setSubCategory(widget.product!.subCategory);
      viewModel.setComingSoon(widget.product!.comingSoon);
      
      // Set highlights
      if (widget.product!.highlights != null) {
        for (final highlight in widget.product!.highlights) {
          viewModel.addHighlight(highlight);
        }
      }

      // Set price tiers
      if (widget.product!.priceTiers != null) {
        for (final tier in widget.product!.priceTiers!) {
          viewModel.addPriceTier(tier);
        }
      }

      // Set specifications
      if (widget.product!.specifications != null) {
        viewModel.setSpecifications(widget.product!.specifications);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _howItWorksController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _uspController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerAddProductViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              widget.product != null ? 'Edit Product' : 'Add New Product',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: ProductPartnerColorPalette.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  // TODO: Show help dialog
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
                    children: [
                      _buildImageSection(viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildBasicInfoSection(context, viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildDetailsSection(),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildAdditionalDetailsSection(context, viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildUSPSection(context, viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildStatusSection(context, viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing * 2),
                      _buildSubmitButton(context, viewModel),
                    ],
                  ),
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ProductPartnerColorPalette.primary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(ProductPartnerAddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image, color: ProductPartnerColorPalette.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Product Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.images.length + 1,
              itemBuilder: (context, index) {
                if (index == viewModel.images.length) {
                  return _buildAddImageButton(context);
                }
                return _buildImagePreview(context, index, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: ProductPartnerColorPalette.smallSpacing),
      decoration: BoxDecoration(
        color: ProductPartnerColorPalette.quickActionBg,
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        border: Border.all(color: ProductPartnerColorPalette.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: ProductPartnerColorPalette.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Image',
                style: TextStyle(
                  color: ProductPartnerColorPalette.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, int index, ProductPartnerAddProductViewModel viewModel) {
    final imagePath = viewModel.images[index];
    final isNetworkImage = imagePath.startsWith('http');

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: ProductPartnerColorPalette.smallSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
            child: isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.cover,
                    width: 140,
                    height: 140,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  )
                : Image.file(
                    File(imagePath),
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => _removeImage(index),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (image != null) {
        final viewModel = context.read<ProductPartnerAddProductViewModel>();
        await viewModel.addImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
            ),
          ),
        );
      }
    }
  }

  Future<void> _removeImage(int index) async {
    try {
      final viewModel = context.read<ProductPartnerAddProductViewModel>();
      await viewModel.removeImage(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing image: $e')),
      );
    }
  }

  Widget _buildBasicInfoSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: ProductPartnerColorPalette.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Product Name',
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product name';
              }
              return null;
            },
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          DropdownButtonFormField<String>(
            value: viewModel.selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
              ),
            ),
            items: viewModel.categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.setCategory(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description_outlined, color: ProductPartnerColorPalette.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product description';
              }
              return null;
            },
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          TextFormField(
            controller: _howItWorksController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'How It Works',
              prefixIcon: const Icon(Icons.help_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter how the product works';
              }
              return null;
            },
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                      borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: ProductPartnerColorPalette.spacing),
              Expanded(
                child: TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
                      borderSide: BorderSide(color: ProductPartnerColorPalette.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
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
          Row(
            children: [
              Icon(Icons.add_circle_outline, color: ProductPartnerColorPalette.primary),
              const SizedBox(width: 8),
              Text(
                'Additional Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Demo Link',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
            ),
            onChanged: (value) => viewModel.setDemoLink(value),
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Video URL',
              prefixIcon: const Icon(Icons.video_library),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
            ),
            onChanged: (value) => viewModel.setVideoUrl(value),
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Sub Category',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
              ),
            ),
            onChanged: (value) => viewModel.setSubCategory(value),
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          _buildHighlightsSection(context, viewModel),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          _buildPriceTiersSection(context, viewModel),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          _buildSpecificationsSection(context, viewModel),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          _buildAdditionalImagesSection(context, viewModel),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          SwitchListTile(
            title: const Text('Coming Soon'),
            value: viewModel.comingSoon,
            onChanged: (value) => viewModel.setComingSoon(value),
            activeColor: ProductPartnerColorPalette.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Highlights',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddHighlightDialog(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text('Add Highlight'),
              style: TextButton.styleFrom(
                foregroundColor: ProductPartnerColorPalette.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.highlights.map((highlight) {
            return Chip(
              label: Text(highlight),
              onDeleted: () => viewModel.removeHighlight(highlight),
              backgroundColor: ProductPartnerColorPalette.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: ProductPartnerColorPalette.primary),
              deleteIconColor: ProductPartnerColorPalette.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceTiersSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price Tiers',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddPriceTierDialog(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text('Add Price Tier'),
              style: TextButton.styleFrom(
                foregroundColor: ProductPartnerColorPalette.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.priceTiers.length,
          itemBuilder: (context, index) {
            final tier = viewModel.priceTiers[index];
            return Card(
              child: ListTile(
                title: Text(tier.name),
                subtitle: Text('₹${tier.price}${tier.description != null ? ' - ${tier.description}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => viewModel.removePriceTier(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Specifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddSpecificationDialog(context, viewModel),
              icon: const Icon(Icons.list_alt),
              label: const Text('Add Specification'),
              style: TextButton.styleFrom(
                foregroundColor: ProductPartnerColorPalette.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.specifications != null)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.specifications!.length,
            itemBuilder: (context, index) {
              final key = viewModel.specifications!.keys.elementAt(index);
              final value = viewModel.specifications![key];
              return Card(
                child: ListTile(
                  title: Text(key),
                  subtitle: Text(value.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final newSpecs = Map<String, dynamic>.from(viewModel.specifications!);
                      newSpecs.remove(key);
                      viewModel.setSpecifications(newSpecs);
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAdditionalImagesSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.photo_library_outlined, color: ProductPartnerColorPalette.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Additional Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.additionalImages.length + 1,
            itemBuilder: (context, index) {
              if (index == viewModel.additionalImages.length) {
                return _buildAddAdditionalImageButton(context, viewModel);
              }
              return _buildAdditionalImagePreview(context, index, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddAdditionalImageButton(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: ProductPartnerColorPalette.smallSpacing),
      decoration: BoxDecoration(
        color: ProductPartnerColorPalette.quickActionBg,
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        border: Border.all(color: ProductPartnerColorPalette.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _pickAdditionalImage(viewModel),
          borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: ProductPartnerColorPalette.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Image',
                style: TextStyle(
                  color: ProductPartnerColorPalette.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalImagePreview(BuildContext context, int index, ProductPartnerAddProductViewModel viewModel) {
    final imagePath = viewModel.additionalImages[index];
    final isNetworkImage = imagePath.startsWith('http');

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: ProductPartnerColorPalette.smallSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
            child: isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  )
                : Image.file(
                    File(imagePath),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => viewModel.removeAdditionalImage(index),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAdditionalImage(ProductPartnerAddProductViewModel viewModel) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (image != null) {
        await viewModel.addAdditionalImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
            ),
          ),
        );
      }
    }
  }

  void _showAddHighlightDialog(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.star_outline, color: ProductPartnerColorPalette.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Highlight',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter Highlight',
                  hintText: 'Enter a key feature or benefit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        viewModel.addHighlight(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProductPartnerColorPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPriceTierDialog(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.attach_money, color: ProductPartnerColorPalette.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Price Tier',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tier Name',
                  hintText: 'e.g., Basic, Premium, Enterprise',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter the price for this tier',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add any additional details about this tier',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        final price = double.tryParse(priceController.text);
                        if (price != null) {
                          viewModel.addPriceTier(PriceTier(
                            name: nameController.text,
                            price: price,
                            description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                          ));
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProductPartnerColorPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSpecificationDialog(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.list_alt, color: ProductPartnerColorPalette.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Specification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  labelText: 'Specification Name',
                  hintText: 'e.g., Dimensions, Weight, Material',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter the specification value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                        final newSpecs = Map<String, dynamic>.from(viewModel.specifications ?? {});
                        newSpecs[keyController.text] = valueController.text;
                        viewModel.setSpecifications(newSpecs);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProductPartnerColorPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUSPSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
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
          Row(
            children: [
              Icon(Icons.star_outline, color: ProductPartnerColorPalette.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unique Selling Points',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ProductPartnerColorPalette.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddUSPDialog(context, viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Add USP'),
                style: TextButton.styleFrom(
                  foregroundColor: ProductPartnerColorPalette.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.smallSpacing),
          Wrap(
            spacing: ProductPartnerColorPalette.smallSpacing,
            runSpacing: ProductPartnerColorPalette.smallSpacing,
            children: viewModel.usp.map((usp) {
              return Chip(
                label: Text(usp),
                onDeleted: () => viewModel.removeUSP(usp),
                backgroundColor: ProductPartnerColorPalette.primary.withOpacity(0.1),
                labelStyle: TextStyle(color: ProductPartnerColorPalette.primary),
                deleteIconColor: ProductPartnerColorPalette.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.toggle_on, color: ProductPartnerColorPalette.primary),
              const SizedBox(width: 8),
              Text(
                'Product Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: ProductPartnerColorPalette.success,
            activeTrackColor: ProductPartnerColorPalette.success.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ProductPartnerColorPalette.spacing),
      child: ElevatedButton(
        onPressed: () => _submitForm(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: ProductPartnerColorPalette.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.product != null ? Icons.save : Icons.add_circle_outline,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              widget.product != null ? 'Update Product' : 'Add Product',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUSPDialog(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ProductPartnerColorPalette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.star_outline, color: ProductPartnerColorPalette.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add USP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter USP',
                  hintText: 'Enter a unique selling point',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ProductPartnerColorPalette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        viewModel.addUSP(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProductPartnerColorPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, ProductPartnerAddProductViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (viewModel.images.isEmpty) {
          _showErrorSnackBar(context, 'Please add at least one product image');
          return;
        }

        _showLoadingDialog(context, widget.product != null ? 'Updating product...' : 'Creating product...');

        bool success;
        if (widget.product != null) {
          print('Product object: ${widget.product?.toJson()}');
          print('Product ID from object: ${widget.product?.productId}');
          
          if (widget.product?.productId == null || widget.product!.productId!.isEmpty) {
            if (mounted) {
              Navigator.pop(context); // Remove loading dialog
              _showErrorSnackBar(context, 'Invalid product ID. Cannot update product.');
            }
            return;
          }

          print('Starting product update...');
          print('Product ID: ${widget.product!.productId}');
          print('Form data:');
          print('Name: ${_nameController.text}');
          print('Description: ${_descriptionController.text}');
          print('How it works: ${_howItWorksController.text}');
          print('Price: ${_priceController.text}');
          print('Stock: ${_stockController.text}');
          print('Category: ${viewModel.selectedCategory}');
          print('Is Active: $_isActive');
          print('Images: ${viewModel.images}');
          print('USPs: ${viewModel.usp}');

          success = await viewModel.updateProduct(
            productId: widget.product!.productId!,
            name: _nameController.text,
            description: _descriptionController.text,
            howItWorks: _howItWorksController.text,
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
          );
        } else {
          print('Starting product creation...');
          print('Form data:');
          print('Name: ${_nameController.text}');
          print('Description: ${_descriptionController.text}');
          print('How it works: ${_howItWorksController.text}');
          print('Price: ${_priceController.text}');
          print('Stock: ${_stockController.text}');
          print('Category: ${viewModel.selectedCategory}');
          print('Is Active: $_isActive');
          print('Images: ${viewModel.images}');
          print('USPs: ${viewModel.usp}');

          success = await viewModel.createProduct(
            name: _nameController.text,
            description: _descriptionController.text,
            howItWorks: _howItWorksController.text,
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
          );
        }

        if (mounted) {
          Navigator.pop(context); // Remove loading dialog
        }

        if (success && mounted) {
          _showSuccessSnackBar(
            context, 
            widget.product != null ? 'Product updated successfully!' : 'Product added successfully!'
          );
          
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else if (mounted) {
          _showErrorSnackBar(
            context,
            viewModel.error.isNotEmpty 
                ? viewModel.error 
                : widget.product != null 
                    ? 'Failed to update product. Please try again.'
                    : 'Failed to add product. Please try again.'
          );
        }
      } catch (e, stackTrace) {
        print('Error in _submitForm: $e');
        print('Stack trace: $stackTrace');
        
        if (mounted) {
          Navigator.pop(context); // Remove loading dialog
          _showErrorSnackBar(
            context, 
            'An error occurred: ${e.toString()}\nPlease try again or contact support if the issue persists.'
          );
        }
      }
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ProductPartnerColorPalette.primary),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  color: ProductPartnerColorPalette.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: ProductPartnerColorPalette.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: ProductPartnerColorPalette.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
} 