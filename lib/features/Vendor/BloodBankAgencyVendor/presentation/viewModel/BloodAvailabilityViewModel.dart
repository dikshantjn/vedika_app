import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodInventoryService.dart';
import '../../data/model/BloodInventory.dart';
import 'package:logger/logger.dart';

class BloodAvailabilityViewModel extends ChangeNotifier {
  final BloodInventoryService _service = BloodInventoryService();
  final _logger = Logger();
  
  List<BloodInventory> _bloodInventory = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _unitsController = TextEditingController();
  String? _selectedBloodType;
  String? _vendorId;

  // Getters
  List<BloodInventory> get bloodInventory => _bloodInventory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TextEditingController get unitsController => _unitsController;
  String? get selectedBloodType => _selectedBloodType;
  String? get vendorId => _vendorId;

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

  Future<void> loadVendorId() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _vendorId = await _service.getVendorId();
      if (_vendorId == null) {
        _error = 'Vendor ID not found';
      }
    } catch (e) {
      _logger.e('Error loading vendor ID: $e');
      _error = 'Error loading vendor ID: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> handleSave(BloodInventory bloodType) async {
    try {
      if (_vendorId == null) {
        _error = 'Vendor ID not found';
        notifyListeners();
        return false;
      }

      if (bloodType.bloodType.isEmpty) {
        _error = 'Please enter a blood type';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create a new blood type with all required fields
      final updatedBloodType = BloodInventory(
        bloodInventoryId: bloodType.bloodInventoryId, // This will be null for new items
        vendorId: _vendorId!,
        bloodType: bloodType.bloodType,
        unitsAvailable: bloodType.unitsAvailable,
        isAvailable: bloodType.isAvailable,
      );

      _logger.i('Saving blood type: ${updatedBloodType.toJson()}');
      await _service.upsertBloodInventory(updatedBloodType);
      await loadBloodInventory(); // Reload the list after saving
      return true;
    } catch (e) {
      _logger.e('Error saving blood type: $e');
      _error = 'Error saving blood type: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  Future<void> deleteBloodType(String bloodInventoryId) async {
    try {
      await _service.deleteBloodInventory(bloodInventoryId);
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