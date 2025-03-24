import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineProductViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Products/ProductListWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Products/AddEditProductDialog.dart';

class MedicalProductsProductScreen extends StatefulWidget {
  @override
  _MedicalProductsProductScreenState createState() => _MedicalProductsProductScreenState();
}

class _MedicalProductsProductScreenState extends State<MedicalProductsProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicineProductViewModel>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MedicineProductViewModel>(
        builder: (context, productVM, child) {
          if (productVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (productVM.errorMessage != null) {
            return Center(child: Text(productVM.errorMessage!));
          }
          return ProductListWidget();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddEditProductDialog(),
          );
        },
        icon: const Icon(Icons.add, size: 22),
        label: const Text(
          "Add Product",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
