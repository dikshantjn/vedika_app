class BloodBankOrder {
  final String orderId;
  final String userId;
  final String bloodBankId;
  final String bloodBankName;
  final String bloodType;
  final int unitsOrdered;
  final String orderDate;
  final double totalPrice;
  final String status;

  BloodBankOrder({
    required this.orderId,
    required this.userId,
    required this.bloodBankId,
    required this.bloodBankName,
    required this.bloodType,
    required this.unitsOrdered,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
  });

  /// Convert JSON to Model
  factory BloodBankOrder.fromJson(Map<String, dynamic> json) {
    return BloodBankOrder(
      orderId: json['orderId'],
      userId: json['userId'],
      bloodBankId: json['bloodBankId'],
      bloodBankName: json['bloodBankName'],
      bloodType: json['bloodType'],
      unitsOrdered: json['unitsOrdered'],
      orderDate: json['orderDate'],
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
    );
  }

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'bloodBankId': bloodBankId,
      'bloodBankName': bloodBankName,
      'bloodType': bloodType,
      'unitsOrdered': unitsOrdered,
      'orderDate': orderDate,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
