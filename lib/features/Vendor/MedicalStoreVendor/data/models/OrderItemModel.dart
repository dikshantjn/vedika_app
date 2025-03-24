class OrderItemModel {
  final int orderItemId;
  final int orderId;
  final String productId;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: json['orderItemId'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderItemId": orderItemId,
      "orderId": orderId,
      "productId": productId,
      "quantity": quantity,
      "price": price,
    };
  }
}
