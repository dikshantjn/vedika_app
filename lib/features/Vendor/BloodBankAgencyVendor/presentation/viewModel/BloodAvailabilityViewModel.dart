import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodInventoryService.dart';
import '../../data/model/BloodInventory.dart';

class BloodAvailabilityViewModel extends ChangeNotifier {
  final BloodInventoryService _service = BloodInventoryService();
  
  List<BloodInventory> _bloodInventory = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _unitsController = TextEditingController();
  String? _selectedBloodType;

  // Getters
  List<BloodInventory> get bloodInventory => _bloodInventory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TextEditingController get unitsController => _unitsController;
  String? get selectedBloodType => _selectedBloodType;

  // Blood types for dropdown
  final List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Initialize the view model
  BloodAvailabilityViewModel() {
    _unitsController.addListener(_updateAvailability);
  }

  void _updateAvailability() {
    notifyListeners();
  }

  void setSelectedBloodType(String? value) {
    _selectedBloodType = value;
    notifyListeners();
  }

  void resetDialogFields() {
    _selectedBloodType = null;
    _unitsController.clear();
  }

  bool validateDialogFields() {
    return _selectedBloodType != null && 
           _unitsController.text.isNotEmpty &&
           int.tryParse(_unitsController.text) != null;
  }

  // Load blood inventory from the API
  Future<void> loadBloodInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bloodInventory = await _service.getBloodInventory();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new blood type
  Future<void> addBloodType(BloodInventory bloodType) async {
    try {
      await _service.upsertBloodInventory(bloodType);
      await loadBloodInventory(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing blood type
  Future<void> updateBloodType(BloodInventory bloodType) async {
    try {
      await _service.upsertBloodInventory(bloodType);
      await loadBloodInventory(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a blood type
  Future<void> deleteBloodType(String bloodType) async {
    try {
      await _service.deleteBloodInventory(bloodType);
      await loadBloodInventory(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }
} 