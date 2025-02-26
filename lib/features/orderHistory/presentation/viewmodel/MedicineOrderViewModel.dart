import 'package:vedika_healthcare/features/orderHistory/data/repositories/MedicineOrder.dart';

class MedicineOrderViewModel {
  // Sample data representing orders, now including lists of image URLs
  final List<MedicineOrder> _orders = [
    MedicineOrder(
      orderNumber: 'Order #12345',
      date: 'Oct 10, 2023',
      status: 'Delivered',
      items: '2 Items',
      total: '\$45.00',
      imageUrls: [
        'https://img.freepik.com/free-vector/realistic-style-hand-sanitizer_23-2148481920.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
        'https://img.freepik.com/free-vector/realistic-medical-supplies-background_1284-16386.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
        'https://img.freepik.com/free-photo/front-view-coronavirus-concept_23-2148592511.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid'
      ],
    ),
    MedicineOrder(
      orderNumber: 'Order #12346',
      date: 'Oct 12, 2023',
      status: 'Shipped',
      items: '3 Items',
      total: '\$67.50',
      imageUrls: [
        'https://img.freepik.com/free-vector/realistic-medical-supplies-background_1284-16386.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
        'https://img.freepik.com/free-photo/front-view-coronavirus-concept_23-2148592511.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
        'https://img.freepik.com/free-vector/realistic-style-hand-sanitizer_23-2148481920.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid'
      ],
    ),
    MedicineOrder(
      orderNumber: 'Order #12347',
      date: 'Oct 15, 2023',
      status: 'Processing',
      items: '1 Item',
      total: '\$22.00',
      imageUrls: [
        'https://img.freepik.com/free-photo/front-view-coronavirus-concept_23-2148592511.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
        'https://img.freepik.com/free-vector/realistic-medical-supplies-background_1284-16386.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
        'https://img.freepik.com/free-vector/realistic-style-hand-sanitizer_23-2148481920.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid'
      ],
    ),
  ];

  // Getter to access the list of orders
  List<MedicineOrder> get orders => _orders;

// You can add more logic here like filtering, sorting, etc.
// Example: Fetch data from API or update the order list
}
