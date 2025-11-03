class OrderMedicine {
  final String orderMedicineId;
  final String orderId;
  final String medicineName;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderMedicine({
    required this.orderMedicineId,
    required this.orderId,
    required this.medicineName,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderMedicine.fromJson(Map<String, dynamic> json) {
    return OrderMedicine(
      orderMedicineId: json['orderMedicineId'] ?? '',
      orderId: json['orderId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      quantity: (json['quantity'] ?? 1) as int,
      price: (json['price'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderMedicineId': orderMedicineId,
      'orderId': orderId,
      'medicineName': medicineName,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderMedicine copyWith({
    String? orderMedicineId,
    String? orderId,
    String? medicineName,
    int? quantity,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderMedicine(
      orderMedicineId: orderMedicineId ?? this.orderMedicineId,
      orderId: orderId ?? this.orderId,
      medicineName: medicineName ?? this.medicineName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

