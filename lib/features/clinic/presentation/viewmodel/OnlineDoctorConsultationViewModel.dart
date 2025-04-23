import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicService.dart';

class OnlineDoctorConsultationViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final ClinicService _clinicService = ClinicService();
  
  List<DoctorClinicProfile> _allDoctors = [];
  List<DoctorClinicProfile> _filteredDoctors = [];
  bool _isLoading = true;
  String? _error;
  List<String> _selectedSpecializations = [];
  String _sortBy = 'Experience'; // Default sort

  // Getters
  List<DoctorClinicProfile> get doctors => _filteredDoctors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get selectedSpecializations => _selectedSpecializations;
  String get sortBy => _sortBy;

  // Constructor
  OnlineDoctorConsultationViewModel() {
    searchController.addListener(_filterDoctors);
    fetchDoctors();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch doctors who offer online consultation
  Future<void> fetchDoctors() async {
    print('🚀 Starting fetchDoctors in OnlineDoctorConsultationViewModel');
    _isLoading = true;
    notifyListeners();

    try {
      // Call the API service to get active online clinics
      print('📡 Calling API service getActiveOnlineClinics');
      _allDoctors = await _clinicService.getActiveOnlineClinics();
      print('📋 Received ${_allDoctors.length} doctors from API');
      
      if (_allDoctors.isEmpty) {
        print('⚠️ No doctors returned from API, falling back to sample data');
        return;
      }
      
      // Log consultation types for debugging
      for (var doctor in _allDoctors) {
        print('🩺 Doctor ${doctor.doctorName} consultation types: ${doctor.consultationTypes}');
      }
      
      // Enhanced check for doctors who offer online consultation
      _allDoctors = _allDoctors.where((doctor) => 
        doctor.consultationTypes.any((type) => 
          type.toLowerCase().contains('online') || 
          type.toLowerCase().contains('tele') || 
          type.toLowerCase().contains('video') || 
          type.toLowerCase() == 'remote'
        )).toList();
      print('🎯 Filtered to ${_allDoctors.length} doctors with online consultation');
      
      if (_allDoctors.isEmpty) {
        print('⚠️ No doctors with online consultation found, falling back to sample data');
        return;
      }
      
      _filteredDoctors = List.from(_allDoctors);
      _isLoading = false;
      print('✅ fetchDoctors completed successfully');
      notifyListeners();
    } catch (e) {
      print('❌ Error in fetchDoctors: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      
      // Fallback to sample data if API fails
      print('🔄 Falling back to sample data due to error');
    }
  }
  

  // Filter doctors based on search query and specializations
  void _filterDoctors() {
    final query = searchController.text.toLowerCase();
    
    _filteredDoctors = _allDoctors.where((doctor) {
      // Filter by search query
      final matchesQuery = query.isEmpty || 
          doctor.doctorName.toLowerCase().contains(query) ||
          doctor.specializations.any((s) => s.toLowerCase().contains(query));
      
      // Filter by selected specializations
      final matchesSpecializations = _selectedSpecializations.isEmpty ||
          doctor.specializations.any((s) => _selectedSpecializations.contains(s));
      
      return matchesQuery && matchesSpecializations;
    }).toList();
    
    // Apply sorting
    _applySorting();
    
    notifyListeners();
  }
  
  // Apply sorting based on selected sort option
  void _applySorting() {
    switch (_sortBy) {
      case 'Experience':
        _filteredDoctors.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case 'Fee: Low to High':
        _filteredDoctors.sort((a, b) {
          final aFee = int.parse(a.consultationFeesRange.split('-')[0]);
          final bFee = int.parse(b.consultationFeesRange.split('-')[0]);
          return aFee.compareTo(bFee);
        });
        break;
      case 'Fee: High to Low':
        _filteredDoctors.sort((a, b) {
          final aFee = int.parse(a.consultationFeesRange.split('-')[1]);
          final bFee = int.parse(b.consultationFeesRange.split('-')[1]);
          return bFee.compareTo(aFee);
        });
        break;
      case 'Name A-Z':
        _filteredDoctors.sort((a, b) => a.doctorName.compareTo(b.doctorName));
        break;
      default:
        // Default sorting by experience
        _filteredDoctors.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
    }
  }
  
  // Toggle specialization filter
  void toggleSpecialization(String specialization) {
    if (_selectedSpecializations.contains(specialization)) {
      _selectedSpecializations.remove(specialization);
    } else {
      _selectedSpecializations.add(specialization);
    }
    _filterDoctors();
  }
  
  // Clear all filters
  void clearFilters() {
    _selectedSpecializations.clear();
    searchController.clear();
    _sortBy = 'Experience';
    _filteredDoctors = List.from(_allDoctors);
    notifyListeners();
  }
  
  // Set sort option
  void setSortOption(String sortOption) {
    _sortBy = sortOption;
    _filterDoctors();
  }
  
  // Define the list of available specializations
  List<String> get availableSpecializations {
    // Extract unique specializations from all doctors
    Set<String> specializations = {};
    for (var doctor in _allDoctors) {
      specializations.addAll(doctor.specializations);
    }
    // Sort alphabetically and return as a list
    final sortedSpecializations = specializations.toList()..sort();
    return sortedSpecializations;
  }
} 