import 'package:vedika_healthcare/features/orderHistory/data/models/MedicineOrder.dart';

class MedicineOrderRepository {
  // Sample list of orders stored in the repository
  List<MedicineOrder> getOrders() {
    return [
      MedicineOrder(
        orderNumber: 'Order #12345',
        date: 'Oct 10, 2023',
        status: 'Delivered',
        items: '2 Items',
        total: '\₹45.00',
        imageUrls: [
          'https://img.freepik.com/free-vector/realistic-style-hand-sanitizer_23-2148481920.jpg',
          'https://img.freepik.com/free-vector/realistic-medical-supplies-background_1284-16386.jpg',
          'https://img.freepik.com/free-photo/front-view-coronavirus-concept_23-2148592511.jpg'
        ],
      ),
      MedicineOrder(
        orderNumber: 'Order #12346',
        date: 'Oct 12, 2023',
        status: 'Shipped',
        items: '3 Items',
        total: '\₹67.50',
        imageUrls: [
          'https://img.freepik.com/free-vector/realistic-medical-supplies-background_1284-16386.jpg',
          'https://img.freepik.com/free-photo/front-view-coronavirus-concept_23-2148592511.jpg',
          'https://img.freepik.com/free-vector/realistic-style-hand-sanitizer_23-2148481920.jpg'
        ],
      ),
      MedicineOrder(
        orderNumber: 'Order #12347',
        date: 'Oct 15, 2023',
        status: 'Processing',
        items: '1 Item',
        total: '\₹22.00',
        imageUrls: [
          'https://img.freepik.com/free-photo/front-view-coronavirus-concept_23-2148592511.jpg',
          'https://img.freepik.com/free-vector/realistic-medical-supplies-background_1284-16386.jpg',
          'https://img.freepik.com/free-vector/realistic-style-hand-sanitizer_23-2148481920.jpg'
        ],
      ),
    ];
  }
}
