import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../../data/models/VendorProduct.dart';
import '../viewmodels/ProductPartnerAddProductViewModel.dart';

class ProductPartnerAddProductPage extends StatefulWidget {
  const ProductPartnerAddProductPage({Key? key}) : super(key: key);

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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _howItWorksController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerAddProductViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: ProductPartnerColorPalette.background,
          appBar: AppBar(
            title: const Text('Add New Product'),
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
                      _buildImageUploadSection(context, viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildBasicInfoSection(context, viewModel),
                      const SizedBox(height: ProductPartnerColorPalette.spacing),
                      _buildDetailsSection(),
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

  Widget _buildImageUploadSection(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
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
              Icon(Icons.image, color: ProductPartnerColorPalette.primary),
              const SizedBox(width: 8),
              Text(
                'Product Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: ProductPartnerColorPalette.spacing),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.images.length + 1,
              itemBuilder: (context, index) {
                if (index == viewModel.images.length) {
                  return _buildAddImageButton(context, viewModel);
                }
                return _buildImagePreview(context, index, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
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
          onTap: () => _pickImage(context, viewModel),
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

  Future<void> _pickImage(BuildContext context, ProductPartnerAddProductViewModel viewModel) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image to 70% quality
        maxWidth: 1000, // Limit image width
        maxHeight: 1000, // Limit image height
      );

      if (image != null) {
        // Convert XFile to File
        final File imageFile = File(image.path);
        
        // TODO: Upload image to server and get URL
        // For now, we'll use the local file path
        viewModel.addImage(imageFile.path);
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

  Widget _buildImagePreview(BuildContext context, int index, ProductPartnerAddProductViewModel viewModel) {
    final String imagePath = viewModel.images[index];
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: ProductPartnerColorPalette.smallSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        image: DecorationImage(
          image: imagePath.startsWith('http')
              ? NetworkImage(imagePath) as ImageProvider
              : FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
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
                onPressed: () => viewModel.removeImage(index),
              ),
            ),
          ),
        ],
      ),
    );
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
              Icon(Icons.info_outline, color: ProductPartnerColorPalette.primary),
              const SizedBox(width: 8),
              Text(
                'Basic Information',
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
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Product Name',
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
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
              Icon(Icons.description_outlined, color: ProductPartnerColorPalette.primary),
              const SizedBox(width: 8),
              Text(
                'Product Details',
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
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
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
              Text(
                'Unique Selling Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ProductPartnerColorPalette.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddUSPDialog(context, viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Add USP'),
                style: TextButton.styleFrom(
                  foregroundColor: ProductPartnerColorPalette.primary,
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
            value: viewModel.isActive,
            onChanged: viewModel.setActive,
            activeColor: ProductPartnerColorPalette.success,
            activeTrackColor: ProductPartnerColorPalette.success.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    return ElevatedButton(
      onPressed: () => _submitForm(context, viewModel),
      style: ElevatedButton.styleFrom(
        backgroundColor: ProductPartnerColorPalette.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: ProductPartnerColorPalette.spacing),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Add Product',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddUSPDialog(BuildContext context, ProductPartnerAddProductViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star_outline, color: ProductPartnerColorPalette.primary),
            const SizedBox(width: 8),
            const Text('Add USP'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter USP',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, ProductPartnerAddProductViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.createProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        howItWorks: _howItWorksController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error),
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
} 