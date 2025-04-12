import 'package:flutter/material.dart';
import '../../data/model/BloodInventory.dart';

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

  // Add new blood type
  Future<void> addBloodType(BloodInventory bloodType) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Add new blood type
      _bloodInventory.add(
        BloodInventory(
          bloodType: bloodType.bloodType,
          unitsAvailable: bloodType.unitsAvailable,
          isAvailable: bloodType.isAvailable,
          vendorId: 'vendor123', // This should come from user session
        ),
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to add blood type';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing blood type
  Future<void> updateBloodType(BloodInventory bloodType) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _bloodInventory.indexWhere(
        (item) => item.bloodType == bloodType.bloodType,
      );
      if (index != -1) {
        _bloodInventory[index] = BloodInventory(
          bloodType: bloodType.bloodType,
          unitsAvailable: bloodType.unitsAvailable,
          isAvailable: bloodType.isAvailable,
          vendorId: 'vendor123', // This should come from user session
        );
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to update blood type';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete blood type by blood type string
  Future<void> deleteBloodType(String bloodType) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      _bloodInventory.removeWhere((item) => item.bloodType == bloodType);
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