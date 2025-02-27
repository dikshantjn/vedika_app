class LabTestOrder {
  final String orderNumber;
  final List<String> testNames; // Changed from String to List<String>
  final String labName;
  final String date;
  final String status;
  final String total;
  final List<String> imageUrls; // For test reports

  LabTestOrder({
    required this.orderNumber,
    required this.testNames, // Now accepts a list of test names
    required this.labName,
    required this.date,
    required this.status,
    required this.total,
    this.imageUrls = const [],
  });

  // Factory method to create an instance from JSON
  factory LabTestOrder.fromJson(Map<String, dynamic> json) {
    return LabTestOrder(
      orderNumber: json['orderNumber'] ?? '',
      testNames: List<String>.from(json['testNames'] ?? []), // Changed to List<String>
      labName: json['labName'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      total: json['total'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'testNames': testNames, // Changed to a list
      'labName': labName,
      'date': date,
      'status': status,
      'total': total,
      'imageUrls': imageUrls,
    };
  }
}
