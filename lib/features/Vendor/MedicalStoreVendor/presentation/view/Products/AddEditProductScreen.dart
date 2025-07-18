import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicalStoreFileUploadService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineProductViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/shared/utils/firebase_metadata_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final MedicineProduct? product;

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name, manufacturer, type, packSizeLabel, shortComposition;
  late double price, discount;
  List<String> productURLs = [];
  List<File> newImages = [];
  List<Map<String, Object>> uploadedFiles = [];
  late int quantity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      name = widget.product!.name;
      price = widget.product!.price;
      discount = widget.product!.discount;
      manufacturer = widget.product!.manufacturer;
      type = widget.product!.type;
      packSizeLabel = widget.product!.packSizeLabel;
      shortComposition = widget.product!.shortComposition;
      productURLs = List<String>.from(widget.product!.productURLs);
      quantity = widget.product!.quantity;
    } else {
      name = '';
      price = 0.0;
      discount = 0.0;
      manufacturer = '';
      type = '';
      packSizeLabel = '';
      shortComposition = '';
      quantity = 0;
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      final newProduct = MedicineProduct(
        productId: widget.product?.productId ?? const Uuid().v4(),
        name: name,
        price: price,
        discount: discount,
        manufacturer: manufacturer,
        type: type,
        packSizeLabel: packSizeLabel,
        shortComposition: shortComposition,
        productURLs: productURLs,
        quantity: quantity,
      );

      try {
        final productVM = Provider.of<MedicineProductViewModel>(context, listen: false);
        if (widget.product == null) {
          await productVM.addProduct(newProduct);
        } else {
          await productVM.editProduct(widget.product!.productId, newProduct);
        }
        
        await productVM.fetchProducts();
        
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.product == null ? 'Product added successfully!' : 'Product updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving product: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required Function(String) onSaved,
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
        onSaved: (value) {
          if (isNumeric) {
            if (keyboardType == TextInputType.number) {
              onSaved(value != null && value.isNotEmpty ? value : '0');
            } else {
              onSaved(value != null && value.isNotEmpty ? value : '0.0');
            }
          } else {
            onSaved(value!);
          }
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    if (productURLs.isEmpty && newImages.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No images uploaded',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productURLs.length + newImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < productURLs.length) {
          return _buildImageItem(productURLs[index], isNetwork: true, index: index);
        } else {
          return _buildImageItem(newImages[index - productURLs.length].path, isNetwork: false, index: index);
        }
      },
    );
  }

  Widget _buildImageItem(String imagePath, {required bool isNetwork, required int index}) {
    return FutureBuilder<String>(
      future: _getImageName(imagePath, isNetwork),
      builder: (context, snapshot) {
        String imageName = snapshot.data ?? 'No Name';

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isNetwork
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.grey[600]),
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red[500],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: () async {
                      setState(() {
                        if (isNetwork) {
                          String fileUrl = productURLs[index];
                          productURLs.removeAt(index);
                          MedicalStoreFileUploadService().deleteFile(fileUrl).then((isDeleted) {
                            if (isDeleted) {
                              print("File deleted from Firebase Storage: $fileUrl");
                            } else {
                              print("Failed to delete the file from Firebase Storage");
                            }
                          });
                        } else {
                          newImages.removeAt(index - productURLs.length);
                        }
                      });
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    imageName,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getImageName(String imagePath, bool isNetwork) async {
    try {
      if (isNetwork) {
        FullMetadata metadata = await FirebaseMetadataService().getFileMetadata(imagePath);
        return metadata.customMetadata?["description"] ?? "Unnamed Image";
      } else {
        return imagePath.split('/').last;
      }
    } catch (e) {
      debugPrint("❌ Error fetching image name: $e");
      return "Error Fetching Name";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          widget.product == null ? 'Add New Product' : 'Edit Product',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.product == null ? Icons.add_circle : Icons.edit,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product == null ? 'Add New Product' : 'Edit Product',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.product == null 
                                    ? 'Fill in the details below to add a new product'
                                    : 'Update the product information below',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Product Information Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Product Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildTextField(
                      label: 'Medicine Name',
                      icon: Icons.medication,
                      initialValue: name,
                      onSaved: (val) => name = val,
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Price (₹)',
                            icon: Icons.attach_money,
                            initialValue: price.toString(),
                            onSaved: (val) => price = double.parse(val),
                            keyboardType: TextInputType.number,
                            isNumeric: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Discount (%)',
                            icon: Icons.percent,
                            initialValue: discount.toString(),
                            onSaved: (val) => discount = double.parse(val),
                            keyboardType: TextInputType.number,
                            isNumeric: true,
                          ),
                        ),
                      ],
                    ),
                    
                    _buildTextField(
                      label: 'Manufacturer',
                      icon: Icons.business,
                      initialValue: manufacturer,
                      onSaved: (val) => manufacturer = val,
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Type (Tablet, Syrup, etc.)',
                            icon: Icons.category,
                            initialValue: type,
                            onSaved: (val) => type = val,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Quantity',
                            icon: Icons.inventory,
                            initialValue: quantity.toString(),
                            onSaved: (val) {
                              if (val != null && val.isNotEmpty) {
                                quantity = int.tryParse(val) ?? 0;
                              } else {
                                quantity = 0;
                              }
                            },
                            keyboardType: TextInputType.number,
                            isNumeric: true,
                          ),
                        ),
                      ],
                    ),
                    
                    _buildTextField(
                      label: 'Pack Size Label',
                      icon: Icons.inventory_2,
                      initialValue: packSizeLabel,
                      onSaved: (val) => packSizeLabel = val,
                    ),
                    
                    _buildTextField(
                      label: 'Short Composition',
                      icon: Icons.description,
                      initialValue: shortComposition,
                      onSaved: (val) => shortComposition = val,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Images Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Product Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    UploadSectionWidget(
                      label: "Upload Product Images",
                      onFilesSelected: (files) {
                        setState(() {
                          uploadedFiles = files;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildImageGrid(),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Saving...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.product == null ? 'Add Product' : 'Update Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 