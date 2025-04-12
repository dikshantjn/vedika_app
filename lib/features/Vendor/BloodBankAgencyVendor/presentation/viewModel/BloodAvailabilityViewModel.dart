import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodInventoryService.dart';
import '../../data/model/BloodInventory.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;

class BloodAvailabilityViewModel extends ChangeNotifier {
  final BloodInventoryService _service = BloodInventoryService();
  final _logger = Logger();
  
  List<BloodInventory> _bloodInventory = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _unitsController = TextEditingController();
  String? _selectedBloodType;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // Getters
  List<BloodInventory> get bloodInventory => _bloodInventory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TextEditingController get unitsController => _unitsController;
  String? get selectedBloodType => _selectedBloodType;
  bool get isInitialized => _isInitialized;

  // Blood types for dropdown
  final List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Initialize the view model
  BloodAvailabilityViewModel() {
    developer.log('BloodAvailabilityViewModel: Constructor called', name: 'BloodAvailability');
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
    if (_isDisposed) return;
    
    if (_isLoading) {
      developer.log('BloodAvailabilityViewModel: Already loading inventory, skipping', name: 'BloodAvailability');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    developer.log('BloodAvailabilityViewModel: Loading blood inventory...', name: 'BloodAvailability');

    try {
      final inventory = await _service.getBloodInventory();
      if (_isDisposed) return;
      
      _bloodInventory.clear();
      _bloodInventory.addAll(inventory);
      _isInitialized = true;
      developer.log('BloodAvailabilityViewModel: Blood inventory loaded successfully: ${_bloodInventory.length} items', name: 'BloodAvailability');
    } catch (e, stackTrace) {
      if (_isDisposed) return;
      
      _error = 'Failed to load blood inventory: ${e.toString()}';
      developer.log('BloodAvailabilityViewModel: Error loading blood inventory', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Add a new blood type
  Future<bool> addBloodType(BloodInventory bloodType) async {
    if (_isDisposed) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    developer.log('BloodAvailabilityViewModel: Adding blood type: ${bloodType.bloodType}', name: 'BloodAvailability');

    try {
      await _service.upsertBloodInventory(bloodType);
      if (_isDisposed) return false;
      
      developer.log('BloodAvailabilityViewModel: Blood type added successfully', name: 'BloodAvailability');
      return true;
    } catch (e, stackTrace) {
      if (_isDisposed) return false;
      
      _error = 'Failed to add blood type: ${e.toString()}';
      developer.log('BloodAvailabilityViewModel: Error adding blood type', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Update an existing blood type
  Future<bool> updateBloodType(BloodInventory bloodType) async {
    if (_isDisposed) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.upsertBloodInventory(bloodType);
      if (_isDisposed) return false;
      
      return true;
    } catch (e, stackTrace) {
      if (_isDisposed) return false;
      
      _error = 'Failed to update blood type: ${e.toString()}';
      developer.log('BloodAvailabilityViewModel: Error updating blood type', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Delete a blood type
  Future<bool> deleteBloodType(String bloodType) async {
    if (_isDisposed) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteBloodInventory(bloodType);
      if (_isDisposed) return false;
      
      return true;
    } catch (e, stackTrace) {
      if (_isDisposed) return false;
      
      _error = 'Failed to delete blood type: ${e.toString()}';
      developer.log('BloodAvailabilityViewModel: Error deleting blood type', name: 'BloodAvailability', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    developer.log('BloodAvailabilityViewModel: dispose called', name: 'BloodAvailability');
    _isDisposed = true;
    _unitsController.dispose();
    super.dispose();
  }
} 