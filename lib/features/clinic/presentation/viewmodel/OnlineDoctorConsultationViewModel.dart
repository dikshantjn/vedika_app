import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class OnlineDoctorConsultationViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
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
    _isLoading = true;
    notifyListeners();

    try {
      // Simulated API call - replace with actual API integration
      await Future.delayed(const Duration(seconds: 1));
      
      // Sample data for demonstration
      _allDoctors = [
        DoctorClinicProfile(
          doctorName: 'Dr. Rajesh Kumar',
          gender: 'Male',
          email: 'rajesh.kumar@example.com',
          password: '',
          confirmPassword: '',
          phoneNumber: '+91 9876543210',
          profilePicture: 'https://randomuser.me/api/portraits/men/75.jpg',
          medicalLicenseFile: [],
          licenseNumber: 'MED123456',
          educationalQualifications: ['MBBS', 'MD - General Medicine'],
          specializations: ['Cardiology', 'Internal Medicine'],
          experienceYears: 15,
          languageProficiency: ['English', 'Hindi', 'Tamil'],
          hasTelemedicineExperience: true,
          consultationFeesRange: '500-800',
          consultationTimeSlots: [
            {'start': '09:00', 'end': '10:00'},
            {'start': '10:00', 'end': '11:00'},
            {'start': '11:00', 'end': '12:00'},
          ],
          consultationDays: ['Monday', 'Wednesday', 'Friday'],
          consultationTypes: ['Online', 'Offline'],
          insurancePartners: ['Apollo Insurance', 'HDFC ERGO'],
          address: '123 Main Street',
          state: 'Tamil Nadu',
          city: 'Chennai',
          pincode: '600001',
          nearbyLandmark: 'Near City Hospital',
          floor: '3rd Floor',
          hasLiftAccess: true,
          hasWheelchairAccess: true,
          hasParking: true,
          otherFacilities: ['Pharmacy', 'Laboratory'],
          clinicPhotos: [
            {'url': 'https://example.com/clinic1.jpg', 'caption': 'Reception'},
            {'url': 'https://example.com/clinic2.jpg', 'caption': 'Waiting Room'},
          ],
          location: '13.0827,80.2707',
        ),
        DoctorClinicProfile(
          doctorName: 'Dr. Priya Sharma',
          gender: 'Female',
          email: 'priya.sharma@example.com',
          password: '',
          confirmPassword: '',
          phoneNumber: '+91 9876543211',
          profilePicture: 'https://randomuser.me/api/portraits/men/75.jpg',
          medicalLicenseFile: [],
          licenseNumber: 'MED123457',
          educationalQualifications: ['MBBS', 'MD - Pediatrics'],
          specializations: ['Pediatrics', 'Neonatology'],
          experienceYears: 10,
          languageProficiency: ['English', 'Hindi', 'Gujarati'],
          hasTelemedicineExperience: true,
          consultationFeesRange: '600-900',
          consultationTimeSlots: [
            {'start': '14:00', 'end': '15:00'},
            {'start': '15:00', 'end': '16:00'},
            {'start': '16:00', 'end': '17:00'},
          ],
          consultationDays: ['Tuesday', 'Thursday', 'Saturday'],
          consultationTypes: ['Online', 'Offline'],
          insurancePartners: ['Star Health', 'LIC Health'],
          address: '456 Park Avenue',
          state: 'Maharashtra',
          city: 'Mumbai',
          pincode: '400001',
          nearbyLandmark: 'Near Central Park',
          floor: '2nd Floor',
          hasLiftAccess: true,
          hasWheelchairAccess: true,
          hasParking: true,
          otherFacilities: ['Pharmacy', 'Cafeteria'],
          clinicPhotos: [
            {'url': 'https://example.com/clinic3.jpg', 'caption': 'Reception'},
            {'url': 'https://example.com/clinic4.jpg', 'caption': 'Consultation Room'},
          ],
          location: '19.0760,72.8777',
        ),
        DoctorClinicProfile(
          doctorName: 'Dr. Anand Verma',
          gender: 'Male',
          email: 'anand.verma@example.com',
          password: '',
          confirmPassword: '',
          phoneNumber: '+91 9876543212',
          profilePicture: 'https://randomuser.me/api/portraits/men/75.jpg',
          medicalLicenseFile: [],
          licenseNumber: 'MED123458',
          educationalQualifications: ['MBBS', 'MS - Orthopedics'],
          specializations: ['Orthopedics', 'Sports Medicine'],
          experienceYears: 12,
          languageProficiency: ['English', 'Hindi', 'Punjabi'],
          hasTelemedicineExperience: true,
          consultationFeesRange: '700-1000',
          consultationTimeSlots: [
            {'start': '10:00', 'end': '11:00'},
            {'start': '11:00', 'end': '12:00'},
            {'start': '17:00', 'end': '18:00'},
          ],
          consultationDays: ['Monday', 'Tuesday', 'Thursday', 'Saturday'],
          consultationTypes: ['Online', 'Offline'],
          insurancePartners: ['Bajaj Allianz', 'ICICI Lombard'],
          address: '789 Hospital Road',
          state: 'Delhi',
          city: 'New Delhi',
          pincode: '110001',
          nearbyLandmark: 'Near Metro Station',
          floor: '5th Floor',
          hasLiftAccess: true,
          hasWheelchairAccess: true,
          hasParking: true,
          otherFacilities: ['Physical Therapy', 'X-Ray'],
          clinicPhotos: [
            {'url': 'https://example.com/clinic5.jpg', 'caption': 'Waiting Area'},
            {'url': 'https://example.com/clinic6.jpg', 'caption': 'Treatment Room'},
          ],
          location: '28.7041,77.1025',
        ),
      ];
      
      // Only include doctors who offer online consultation
      _allDoctors = _allDoctors.where((doctor) => 
        doctor.consultationTypes.contains('Online')).toList();
      
      _filteredDoctors = List.from(_allDoctors);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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