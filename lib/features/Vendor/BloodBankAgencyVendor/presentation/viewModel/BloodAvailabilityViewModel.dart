import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodInventory.dart';

class BloodAvailabilityViewModel extends ChangeNotifier {
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

  Future<void> submitBloodType({BloodInventory? existingBloodType}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (existingBloodType != null) {
        // Update existing blood type
        final index = _bloodInventory.indexWhere(
          (item) => item.bloodType == existingBloodType.bloodType,
        );
        if (index != -1) {
          _bloodInventory[index] = BloodInventory(
            bloodType: _selectedBloodType!,
            unitsAvailable: int.parse(_unitsController.text),
            isAvailable: int.parse(_unitsController.text) > 0,
            vendorId: 'vendor123', // This should come from user session
          );
        }
      } else {
        // Add new blood type
        _bloodInventory.add(
          BloodInventory(
            bloodType: _selectedBloodType!,
            unitsAvailable: int.parse(_unitsController.text),
            isAvailable: int.parse(_unitsController.text) > 0,
            vendorId: 'vendor123', // This should come from user session
          ),
        );
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to ${existingBloodType != null ? 'update' : 'add'} blood type';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBloodType(BloodInventory bloodType) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      _bloodInventory.removeWhere((item) => item.bloodType == bloodType.bloodType);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete blood type';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBloodInventory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Sample data
      _bloodInventory = [
        BloodInventory(
          bloodType: 'A+',
          unitsAvailable: 5,
          isAvailable: true,
          vendorId: 'current_vendor_id',
        ),
        BloodInventory(
          bloodType: 'B+',
          unitsAvailable: 3,
          isAvailable: true,
          vendorId: 'current_vendor_id',
        ),
        BloodInventory(
          bloodType: 'O+',
          unitsAvailable: 0,
          isAvailable: false,
          vendorId: 'current_vendor_id',
        ),
      ];
    } catch (e) {
      _error = 'Failed to load blood inventory';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }
} 