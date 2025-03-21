class InventoryItem {
  String id;
  String productId; // Link to MedicineProduct
  String category;
  int quantity;
  String vendorId;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.category,
    required this.quantity,
    required this.vendorId,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'category': category,
      'quantity': quantity,
      'vendorId': vendorId,
    };
  }

  // From JSON
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      productId: json['productId'],
      category: json['category'],
      quantity: json['quantity'],
      vendorId: json['vendorId'],
    );
  }
}
