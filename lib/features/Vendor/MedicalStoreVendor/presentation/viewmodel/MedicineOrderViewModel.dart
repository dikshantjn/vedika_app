import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/PrescriptionRequestModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/PrescriptionRequestService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/OrderService.dart'; // Assuming you have this service
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class MedicineOrderViewModel extends ChangeNotifier {
  final PrescriptionRequestService _prescriptionService = PrescriptionRequestService();
  final OrderService _orderService = OrderService(); // Order service to fetch orders
  final VendorLoginService _loginService = VendorLoginService();

  List<MedicineOrderModel> _orders = [];
  List<PrescriptionRequestModel> _prescriptionRequests = [];

  List<MedicineOrderModel> get orders => _orders;
  List<PrescriptionRequestModel> get prescriptionRequests => _prescriptionRequests;

  void setOrders(List<MedicineOrderModel> orders) {
    _orders = orders;
    notifyListeners();
  }

  void setPrescriptionRequests(List<PrescriptionRequestModel> prescriptionRequests) {
    _prescriptionRequests = prescriptionRequests;
    notifyListeners();
  }

  Future<void> fetchPrescriptionRequests() async {
    try {
      String? vendorId = await _loginService.getVendorId();
      print("Vendor ID: $vendorId");

      if (vendorId == null || vendorId.isEmpty) {
        throw Exception("Vendor ID not found");
      }

      List<PrescriptionRequestModel> requests = await _prescriptionService.fetchPrescriptionRequests(vendorId);
      setPrescriptionRequests(requests);
    } catch (e) {
      print("Error fetching prescription requests: $e");
    }
  }

  Future<void> fetchOrders() async {
    try {
      // Retrieve vendor ID (Make sure to await)
      String? vendorId = await _loginService.getVendorId();
      print("Vendor ID: $vendorId");

      if (vendorId == null || vendorId.isEmpty) {
        throw Exception("Vendor ID not found");
      }

      // Fetch orders using vendor ID
      List<MedicineOrderModel> orders = await _orderService.getOrders();

      // Update ViewModel state
      setOrders(orders);
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  Future<void> acceptPrescription(String prescriptionId) async {
    String? vendorId = await _loginService.getVendorId();

    try {
      bool success = await _prescriptionService.acceptPrescription(prescriptionId, vendorId!);

      if (success) {
        int index = _prescriptionRequests.indexWhere((p) => p.prescriptionId == prescriptionId);
        if (index != -1) {
          _prescriptionRequests[index] = _prescriptionRequests[index].copyWith(requestAcceptedStatus: true);
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error accepting prescription: $e");
    }
  }
}
