import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineProductViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Products/AddEditProductDialog.dart';

class ProductListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProductViewModel>(
      builder: (context, productVM, child) {
        if (productVM.products.isEmpty) {
          return const Center(
            child: Text(
              "No products available.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await productVM.fetchProducts(); // Trigger the refresh to reload products
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: productVM.products.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
              thickness: 0.5, // Thin modern line
              height: 12, // Space between items
            ),
            itemBuilder: (context, index) {
              final MedicineProduct product = productVM.products[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.medical_services, color: Colors.blue),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "₹${product.price}  |  ${product.type}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddEditProductDialog(product: product),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await _showDeleteConfirmation(context, product.name);
                        if (confirmDelete) {
                          await productVM.deleteProduct(product.productId);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddEditProductDialog(product: product),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String productName) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 30),
            const SizedBox(width: 10),
            const Text("Confirm Delete", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you sure you want to delete the product?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            Text(
              '"$productName"',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "This action cannot be undone.",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.redAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(fontSize: 16, color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }
}
