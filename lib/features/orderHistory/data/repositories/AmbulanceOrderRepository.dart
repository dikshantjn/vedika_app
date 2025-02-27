import 'package:vedika_healthcare/features/orderHistory/data/models/AmbulanceOrder.dart';

class AmbulanceOrderRepository {
  List<AmbulanceOrder> getOrders() {
    return [
      AmbulanceOrder(
        orderNumber: 'Order #A12345',
        date: 'Feb 10, 2024',
        status: 'Completed',
        serviceType: 'Emergency',
        total: '\₹100.00',
        imageUrls: [
          'https://img.freepik.com/free-vector/ambulance-car-flat-icon_1284-7929.jpg',
          'https://img.freepik.com/free-vector/emergency-medical-vehicle-realistic-set_1284-7856.jpg',
        ],
      ),
      AmbulanceOrder(
        orderNumber: 'Order #A12346',
        date: 'Feb 12, 2024',
        status: 'Ongoing',
        serviceType: 'Non-Emergency',
        total: '\₹75.50',
        imageUrls: [
          'https://img.freepik.com/free-vector/emergency-medical-vehicle-realistic-set_1284-7856.jpg',
          'https://img.freepik.com/free-vector/ambulance-car-flat-icon_1284-7929.jpg',
        ],
      ),
    ];
  }
}
