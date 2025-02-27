import 'package:vedika_healthcare/features/orderHistory/data/models/LabTestOrder.dart';

class LabTestRepository {
  List<LabTestOrder> fetchLabTestOrders() {
    return [
      LabTestOrder(
        orderNumber: 'LAB12345',
        testNames: ['Complete Blood Count (CBC)', 'Blood Sugar Test'], // Multiple test names
        labName: 'Apollo Diagnostics',
        date: 'Feb 20, 2024',
        status: 'Completed',
        total: '\₹500.00',
        imageUrls: [
          'https://example.com/report1.jpg',
          'https://example.com/report2.jpg'
        ],
      ),
      LabTestOrder(
        orderNumber: 'LAB12346',
        testNames: ['Lipid Profile', 'Liver Function Test'], // Multiple test names
        labName: 'MedLife Labs',
        date: 'Feb 22, 2024',
        status: 'Pending',
        total: '\₹700.00',
        imageUrls: [],
      ),
      LabTestOrder(
        orderNumber: 'LAB12347',
        testNames: ['Thyroid Function Test'], // Single test name as a list
        labName: 'SRL Diagnostics',
        date: 'Feb 25, 2024',
        status: 'Ongoing',
        total: '\₹600.00',
        imageUrls: [
          'https://example.com/report3.jpg',
        ],
      ),
    ];
  }
}
