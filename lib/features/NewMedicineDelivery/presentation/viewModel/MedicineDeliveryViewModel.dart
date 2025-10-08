import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/NewMedicineDelivery/data/services/MedicineDeliveryService.dart';

class MedicineDeliveryViewModel extends ChangeNotifier {
  final MedicineDeliveryService _service = MedicineDeliveryService();
  
  // State variables
  List<VendorMedicalStoreProfile> _medicalStores = [];
  List<VendorMedicalStoreProfile> _filteredStores = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  
  // Getters
  List<VendorMedicalStoreProfile> get medicalStores => _filteredStores;
  List<VendorMedicalStoreProfile> get allMedicalStores => _medicalStores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  
  // Initialize with real API data
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Load data from real API
      await _loadMedicalStores();
      
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load medical stores from API
  Future<void> _loadMedicalStores() async {
    try {
      _medicalStores = await _service.getMedicalStores();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load medical stores: $e');
    }
  }

  // Search medical stores
  Future<void> searchStores(String query) async {
    _searchQuery = query;
    _applyFilters();
    
    if (query.isNotEmpty) {
      try {
        _setLoading(true);
        _clearError();
        
        // Filter from loaded data
        _filteredStores = _medicalStores.where((store) {
          return store.name.toLowerCase().contains(query.toLowerCase()) ||
                 store.address.toLowerCase().contains(query.toLowerCase()) ||
                 _checkAvailableMedicines(store, query);
        }).toList();
        
      } catch (e) {
        _setError('Search failed: $e');
      } finally {
        _setLoading(false);
      }
    } else {
      _applyFilters();
    }
  }

  // Filter stores based on current criteria
  void _applyFilters() {
    _filteredStores = _medicalStores.where((store) {
      bool matchesSearch = _searchQuery.isEmpty ||
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.address.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesSearch;
    }).toList();
    
    // Sort by name for now
    _filteredStores.sort((a, b) => a.name.compareTo(b.name));
    
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  // Get store details
  Future<VendorMedicalStoreProfile?> getStoreDetails(String vendorId) async {
    try {
      // Find from loaded data
      return _medicalStores.firstWhere((store) => store.vendorId == vendorId);
    } catch (e) {
      _setError('Failed to get store details: $e');
      return null;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to check available medicines
  bool _checkAvailableMedicines(VendorMedicalStoreProfile store, String query) {
    if (store.availableMedicines.isEmpty) return false;
    
    return store.availableMedicines.any((medicine) => 
      medicine.toLowerCase().contains(query.toLowerCase())
    );
  }
}
