import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/Modals/InventoryItem.dart';

class InventoryViewModel extends ChangeNotifier {
  final List<InventoryItem> _inventory = [];
  final List<MedicineProduct> _products = [];

  List<InventoryItem> get inventory => _inventory;
  List<MedicineProduct> get products => _products;

  // Add Medicine Product and Reflect in Inventory
  void addMedicineProduct(MedicineProduct product) {
    _products.add(product);

    // Automatically create inventory entry for the new product
    _inventory.add(
      InventoryItem(
        id: Uuid().v4(),
        productId: product.productId,
        category: product.type, // Using type as category
        quantity: 0, // Default quantity to 0, vendor will update later
        vendorId: "Vendor123", // Placeholder vendor
      ),
    );

    notifyListeners();
  }

  // Add Inventory Manually (If Needed)
  void addInventoryItem(InventoryItem item) {
    _inventory.add(item);
    notifyListeners();
  }

  // Edit Inventory Item
  void editInventoryItem(String id, InventoryItem updatedItem) {
    final index = _inventory.indexWhere((item) => item.id == id);
    if (index != -1) {
      _inventory[index] = updatedItem;
      notifyListeners();
    }
  }

  // Delete Inventory Item
  void deleteInventoryItem(String id) {
    _inventory.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
