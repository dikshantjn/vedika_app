import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class AmbulanceAgencyProfileViewModel extends ChangeNotifier {
  final AmbulanceAgencyService _service = AmbulanceAgencyService();
  final VendorLoginService _loginService = VendorLoginService();

  AmbulanceAgency? _agency;
  bool _isLoading = false;
  String? _error;

  AmbulanceAgency? get agency => _agency;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAgencyProfile() async {
    String? vendorId = await _loginService.getVendorId();
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedAgency = await _service.getAgencyProfile(vendorId!);
      _agency = fetchedAgency;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _agency = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
