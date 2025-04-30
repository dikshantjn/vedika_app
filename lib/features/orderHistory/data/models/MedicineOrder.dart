class MedicineOrder {
  final String orderId;
  final String userId;
  final String vendorId;
  final String vendorName;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final List<MedicineOrderItem> items;

  MedicineOrder({
    required this.orderId,
    required this.userId,
    required this.vendorId,
    required this.vendorName,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    required this.items,
  });

  factory MedicineOrder.fromJson(Map<String, dynamic> json) {
    return MedicineOrder(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      deliveryDate: json['deliveryDate'] != null 
          ? DateTime.parse(json['deliveryDate']) 
          : null,
      deliveryAddress: json['deliveryAddress'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => MedicineOrderItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'status': status,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class MedicineOrderItem {
  final String medicineId;
  final String medicineName;
  final int quantity;
  final double price;
  final String imageUrl;

  MedicineOrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory MedicineOrderItem.fromJson(Map<String, dynamic> json) {
    return MedicineOrderItem(
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
} 