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

class AddEditProductDialog extends StatefulWidget {
  final MedicineProduct? product;

  const AddEditProductDialog({Key? key, this.product}) : super(key: key);

  @override
  _AddEditProductDialogState createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name, manufacturer, type, packSizeLabel, shortComposition;
  late double price, discount;
  List<String> productURLs = []; // Store existing URLs
  List<File> newImages = []; // Store newly selected images
  List<Map<String, Object>> uploadedFiles = []; // Store selected files
  late int quantity;
  bool isLoading = false; // Track the loading state

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
        isLoading = true;  // Set loading to true when starting the operation
      });

      // Create a new product with the updated data
      final newProduct = MedicineProduct(
        productId: widget.product?.productId ?? const Uuid().v4(),
        name: name,
        price: price,
        discount: discount,
        manufacturer: manufacturer,
        type: type,
        packSizeLabel: packSizeLabel,
        shortComposition: shortComposition,
        productURLs: productURLs,  // Include URLs here
        quantity: quantity,  // ✅ Ensure quantity is included
      );

      // Debugging: Print the new product data before saving
      print("New Product Data: ${newProduct.toJson()}");

      try {
        final productVM = Provider.of<MedicineProductViewModel>(context, listen: false);
        if (widget.product == null) {
          await productVM.addProduct(newProduct);
        } else {
          await productVM.editProduct(widget.product!.productId, newProduct);
        }
        
        // After adding/editing the product, fetch the updated list of products
        await productVM.fetchProducts();
        
        if (mounted) {
          setState(() {
            isLoading = false;  // Set loading to false when the operation is done
          });
          Navigator.pop(context); // Close the dialog
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving product: ${e.toString()}'),
              backgroundColor: Colors.red,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
        onSaved: (value) {
          if (isNumeric) {
            if (keyboardType == TextInputType.number) {
              // For integer fields (e.g., quantity)
              onSaved(value != null && value.isNotEmpty ? value : '0');
            } else {
              // For double fields (e.g., price, discount)
              onSaved(value != null && value.isNotEmpty ? value : '0.0'); // Pass as String
            }
          } else {
            onSaved(value!); // For non-numeric fields
          }
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productURLs.length + newImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
        String imageName = snapshot.data ?? 'No Name'; // Fallback name if metadata isn't available

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isNetwork
                  ? Image.network(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: CircleAvatar(
                backgroundColor: Colors.redAccent,
                radius: 16, // Increased radius for better fit
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.white), // Adjusted size
                  onPressed: () async {
                    setState(() {
                      if (isNetwork) {
                        // Handle network image deletion (remove URL)
                        String fileUrl = productURLs[index];
                        productURLs.removeAt(index);
                        // Call deleteFile from FirebaseStorage
                        MedicalStoreFileUploadService().deleteFile(fileUrl).then((isDeleted) {
                          if (isDeleted) {
                            // Optionally, update the database here to remove the URL
                            print("File deleted from Firebase Storage: $fileUrl");
                          } else {
                            print("Failed to delete the file from Firebase Storage");
                          }
                        });
                      } else {
                        // Handle local image deletion (remove the image file)
                        newImages.removeAt(index - productURLs.length);
                      }
                    });
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black54,
                child: Text(
                  imageName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> _getImageName(String imagePath, bool isNetwork) async {
    try {
      if (isNetwork) {
        // If it's a network image, get the metadata from FirebaseStorage or similar service
        FullMetadata metadata = await FirebaseMetadataService().getFileMetadata(imagePath);
        return metadata.customMetadata?["description"] ?? "Unnamed Image";  // Extract description or use fallback
      } else {
        // For local images, use the file name as the name
        return imagePath.split('/').last; // Extract file name from the path
      }
    } catch (e) {
      debugPrint("❌ Error fetching image name: $e");
      return "Error Fetching Name"; // Fallback name if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.product == null ? 'Add' : 'Edit',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(label: 'Medicine Name', icon: Icons.medication, initialValue: name, onSaved: (val) => name = val),
                    _buildTextField(label: 'Price', icon: Icons.attach_money, initialValue: price.toString(), onSaved: (val) => price = double.parse(val), keyboardType: TextInputType.number, isNumeric: true),
                    _buildTextField(label: 'Discount', icon: Icons.percent, initialValue: discount.toString(), onSaved: (val) => discount = double.parse(val), keyboardType: TextInputType.number, isNumeric: true),
                    _buildTextField(label: 'Manufacturer', icon: Icons.business, initialValue: manufacturer, onSaved: (val) => manufacturer = val),
                    _buildTextField(label: 'Type (Tablet, Syrup, etc.)', icon: Icons.category, initialValue: type, onSaved: (val) => type = val),
                    _buildTextField(label: 'Pack Size Label', icon: Icons.inventory, initialValue: packSizeLabel, onSaved: (val) => packSizeLabel = val),
                    _buildTextField(label: 'Short Composition', icon: Icons.description, initialValue: shortComposition, onSaved: (val) => shortComposition = val),
                    _buildTextField(
                      label: 'Quantity',
                      icon: Icons.list,
                      initialValue: quantity.toString(),
                      onSaved: (val) {
                        if (val != null && val.isNotEmpty) {
                          quantity = int.tryParse(val) ?? 0; // Default to 0 if the value is invalid
                        } else {
                          quantity = 0; // Ensure that an empty value is treated as 0
                        }
                        print("🔄 Quantity Field Saved: $quantity"); // Debug log
                      },
                      keyboardType: TextInputType.number,
                      isNumeric: true,
                    ),

                    const SizedBox(height: 15),
                    UploadSectionWidget(
                      label: "Upload Product Images",
                      onFilesSelected: (files) {
                        setState(() {
                          uploadedFiles = files;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildImageGrid(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: Colors.red), // Red border
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 4,
                          ),
                          icon: isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          )
                              : const Icon(Icons.add, size: 20, color: Colors.white),
                          label: isLoading
                              ? const Text(
                            'Saving...',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                              : const Text(
                            'Add',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
