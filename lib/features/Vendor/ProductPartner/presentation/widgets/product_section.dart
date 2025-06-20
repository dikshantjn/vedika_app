import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/product_partner_model.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/viewmodels/product_partner_viewmodel.dart';

class ProductSection extends StatefulWidget {
  @override
  _ProductSectionState createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedCategory = 'OTC';
  List<String> _selectedUserApplicability = [];
  List<String> _selectedUSP = [];

  final List<String> _categories = [
    'OTC',
    'Wearable',
    'Non-Wearable',
    'Consumable',
    'Prescription'
  ];

  final List<String> _userApplicability = [
    'Children',
    'Women',
    'Men',
    'Elders',
    'Generic'
  ];

  final List<String> _uspOptions = [
    'Sustainable',
    'Recycled Product',
    'Eco-friendly'
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductPartnerViewModel>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Products'),
          SizedBox(height: 16),
          _buildProductForm(viewModel),
          SizedBox(height: 24),
          _buildProductList(viewModel),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorPalette.primaryColor,
      ),
    );
  }

  Widget _buildProductForm(ProductPartnerViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Product',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _productNameController,
              label: 'Product Name',
              hint: 'Enter product name',
            ),
            SizedBox(height: 16),
            _buildDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            _buildMultiSelect(
              label: 'User Applicability',
              selectedItems: _selectedUserApplicability,
              items: _userApplicability,
              onChanged: (values) {
                setState(() {
                  _selectedUserApplicability = values;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    hint: 'Enter price',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _discountController,
                    label: 'Discount (%)',
                    hint: 'Enter discount',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildMultiSelect(
              label: 'Unique Selling Points',
              selectedItems: _selectedUSP,
              items: _uspOptions,
              onChanged: (values) {
                setState(() {
                  _selectedUSP = values;
                });
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter product description',
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _quantityController,
              label: 'Quantity',
              hint: 'Enter available quantity',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final product = Product(
                      productName: _productNameController.text,
                      category: _selectedCategory,
                      userApplicability: _selectedUserApplicability,
                      price: double.parse(_priceController.text),
                      discount: double.parse(_discountController.text),
                      usp: _selectedUSP,
                      description: _descriptionController.text,
                      images360: [], // TODO: Implement image upload
                      demoVideos: [], // TODO: Implement video upload
                      quantity: int.parse(_quantityController.text),
                    );
                    viewModel.addProduct(product);
                    _clearForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(ProductPartnerViewModel viewModel) {
    if (viewModel.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No products added yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => viewModel.removeProduct(index),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Category: ${product.category}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Price: ₹${product.price} (${product.discount}% off)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Quantity: ${product.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelect({
    required String label,
    required List<String> selectedItems,
    required List<String> items,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<String>.from(selectedItems);
                if (selected) {
                  newSelection.add(item);
                } else {
                  newSelection.remove(item);
                }
                onChanged(newSelection);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: ColorPalette.primaryColor.withOpacity(0.2),
              checkmarkColor: ColorPalette.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearForm() {
    _productNameController.clear();
    _priceController.clear();
    _discountController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    setState(() {
      _selectedCategory = 'OTC';
      _selectedUserApplicability = [];
      _selectedUSP = [];
    });
  }
} 