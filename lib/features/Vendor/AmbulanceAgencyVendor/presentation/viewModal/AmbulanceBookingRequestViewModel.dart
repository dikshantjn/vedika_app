import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/web.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceBookingRequestViewModel extends ChangeNotifier {
  final AmbulanceBookingService _bookingService = AmbulanceBookingService();
  final VendorLoginService _loginService = VendorLoginService();

  List<AmbulanceBooking> bookingRequests = [];
  bool isLoading = false;
  String errorMessage = '';

  final Logger _logger = Logger();

  // 👇 For toast status
  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;

  // ----------------------------
  // 👇 Service Details Fields
  // ----------------------------

  final TextEditingController pickupLocationController = TextEditingController();
  final TextEditingController dropLocationController = TextEditingController();
  final TextEditingController totalDistanceController = TextEditingController();
  final TextEditingController costPerKmController = TextEditingController();
  final TextEditingController baseChargeController = TextEditingController();

  List<String> vehicleTypes = ['Mini', 'Van', 'AC', 'ICU', 'Oxygen'];
  String? selectedVehicleType;

  void setSelectedVehicleType(String type) {
    selectedVehicleType = type;
    notifyListeners();
  }


  void prefillServiceDetails({
    required String pickup,
    required String drop,
    required double distance,
    required double costPerKm,
    required double baseCharge,
    required String vehicleType,
  }) {
    pickupLocationController.text = pickup;
    dropLocationController.text = drop;
    totalDistanceController.text = distance.toString();
    costPerKmController.text = costPerKm.toString();
    baseChargeController.text = baseCharge.toString();
    selectedVehicleType = vehicleType;
    notifyListeners();
  }

  // ----------------------------
  // 👇 Booking Requests
  // ----------------------------

  Future<void> fetchPendingBookings() async {
    String? vendorId = await _loginService.getVendorId();

    isLoading = true;
    notifyListeners();

    _logger.i("Fetching pending bookings for vendorId: $vendorId");

    try {
      bookingRequests = await _bookingService.getPendingBookings(vendorId!);
      _logger.d("Fetched bookings: ${bookingRequests.map((b) => b.toJson()).toList()}");
      errorMessage = '';
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      _logger.e("Error fetching bookings", error: e, stackTrace: stackTrace);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleRequestStatus(String requestId) async {
    try {
      isLoading = true;
      notifyListeners();

      final updatedStatus = await _bookingService.acceptBookingRequest(requestId);

      final index = bookingRequests.indexWhere((b) => b.requestId == requestId);
      if (index != -1) {
        bookingRequests[index] = bookingRequests[index].copyWith(status: updatedStatus);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchVehicleTypes() async {
    try {
      isLoading = true;
      notifyListeners();

      final types = await _bookingService.getVehicleTypes();
      vehicleTypes = types;

      if (!vehicleTypes.contains(selectedVehicleType)) {
        selectedVehicleType = vehicleTypes.isNotEmpty ? vehicleTypes.first : '';
      }

      _logger.i("Fetched vehicle types: $vehicleTypes");
      errorMessage = '';
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      _logger.e("Error fetching vehicle types", error: e, stackTrace: stackTrace);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateServiceDetails(String requestId, BuildContext context) async {
    final pickup = pickupLocationController.text;
    final drop = dropLocationController.text;
    final distance = double.tryParse(totalDistanceController.text) ?? 0.0;
    final costPerKm = double.tryParse(costPerKmController.text) ?? 0.0;
    final baseCharge = double.tryParse(baseChargeController.text) ?? 0.0;
    final vehicleType = selectedVehicleType ?? '';

    final totalAmount = (distance * costPerKm) + baseCharge;

    _logger.i("Sending updated service details for requestId: $requestId");

    try {
      await _bookingService.updateServiceDetails(
        requestId: requestId,
        pickupLocation: pickup,
        dropLocation: drop,
        totalDistance: distance,
        costPerKm: costPerKm,
        baseCharge: baseCharge,
        vehicleType: vehicleType,
        totalAmount: totalAmount,
      );

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success!',
          message: 'Service details updated successfully!',
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } catch (e, stackTrace) {
      _logger.e("Failed to update service details", error: e, stackTrace: stackTrace);

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: 'Failed to update service details',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }



  @override
  void dispose() {
    pickupLocationController.dispose();
    dropLocationController.dispose();
    totalDistanceController.dispose();
    costPerKmController.dispose();
    baseChargeController.dispose();
    super.dispose();
  }
}
