import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class BookingsViewModel extends ChangeNotifier {
  final LabTestService _labTestService = LabTestService();
  final Logger _logger = Logger();
  final VendorLoginService _loginService = VendorLoginService();

  List<LabTestBooking> _upcomingBookings = [];
  List<LabTestBooking> _todayBookings = [];
  List<LabTestBooking> _pastBookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Tab-specific error messages
  String? _upcomingErrorMessage;
  String? _todayErrorMessage;
  String? _pastErrorMessage;

  // Getters
  List<LabTestBooking> get upcomingBookings => _upcomingBookings;
  List<LabTestBooking> get todayBookings => _todayBookings;
  List<LabTestBooking> get pastBookings => _pastBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Tab-specific error getters
  String? get upcomingErrorMessage => _upcomingErrorMessage;
  String? get todayErrorMessage => _todayErrorMessage;
  String? get pastErrorMessage => _pastErrorMessage;

  // Initialize and fetch data
  Future<void> init() async {
    await fetchBookings();
  }

  // Fetch all bookings and categorize them
  Future<void> fetchBookings() async {
    _setLoading(true);
    
    // Clear previous errors
    _errorMessage = null;
    _upcomingErrorMessage = null;
    _todayErrorMessage = null;
    _pastErrorMessage = null;
    
    // Get current vendor ID
    String? vendorId = await _loginService.getVendorId();
    
    if (vendorId == null || vendorId.isEmpty) {
      _errorMessage = "Vendor ID is not available";
      _setLoading(false);
      return;
    }
    
    // Use a boolean to track if at least one API call succeeded
    bool anyTabSucceeded = false;
    
    // Fetch pending bookings for upcoming tab
    try {
      final List<LabTestBooking> pendingBookings = await _labTestService.getPendingBookingsByVendorId(vendorId);
      _logger.i('Fetched ${pendingBookings.length} pending bookings');
      _upcomingBookings = pendingBookings;
      anyTabSucceeded = true;
    } catch (e) {
      _logger.e('Error fetching pending bookings: $e');
      // We'll continue and try to fetch the other tabs
    }
    
    // Fetch accepted bookings for today tab
    try {
      final List<LabTestBooking> acceptedBookings = await _labTestService.getAcceptedBookingsByVendorId(vendorId);
      _logger.i('Fetched ${acceptedBookings.length} accepted bookings');
      _todayBookings = acceptedBookings;
      anyTabSucceeded = true;
    } catch (e) {
      _logger.e('Error fetching accepted bookings: $e');
      // We'll continue and try to fetch the other tabs
    }
    
    // Fetch completed bookings for past tab
    try {
      final List<LabTestBooking> completedBookings = await _labTestService.getCompletedBookingsByVendorId(vendorId);
      _logger.i('Fetched ${completedBookings.length} completed bookings');
      _pastBookings = completedBookings;
      anyTabSucceeded = true;
    } catch (e) {
      _logger.e('Error fetching completed bookings: $e');
      // We'll continue with the other tabs
    }
    
    // Set global error only if all API calls failed
    if (!anyTabSucceeded) {
      _errorMessage = "Failed to load any bookings. Please check your connection and try again.";
    }
    
    _setLoading(false);
  }

  // Process a specific booking
  Future<void> processBooking(String bookingId) async {
    _setLoading(true);
    try {
      // In a real app, this would be an API call to your backend
      // For now, we're just simulating a delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update the booking status
      final index = _todayBookings.indexWhere((booking) => booking.bookingId == bookingId);
      if (index != -1) {
        final updatedBooking = _todayBookings[index].copyWith(
          bookingStatus: "Processing"
        );
        _todayBookings[index] = updatedBooking;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to process booking: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Accept a specific booking
  Future<void> acceptBooking(String bookingId) async {
    _setLoading(true);
    try {
      // Call the API to accept the booking
      final result = await _labTestService.acceptBooking(bookingId);
      
      if (result['success']) {
        // If successful, find and update the booking status
        final index = _upcomingBookings.indexWhere((booking) => booking.bookingId == bookingId);
        if (index != -1) {
          final updatedBooking = _upcomingBookings[index].copyWith(
            bookingStatus: "Accepted"
          );
          
          // Remove from upcoming and add to today
          _upcomingBookings.removeAt(index);
          _todayBookings.add(updatedBooking);
          notifyListeners();
        }
        
        // Clear any previous error
        _errorMessage = null;
      } else {
        // Handle error
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = "Failed to accept booking: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Helper method to get initial mock data
  List<LabTestBooking> _getMockBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    return [
      LabTestBooking(
        bookingId: "BK003",
        userId: "U003",
        vendorId: "V002",
        user: UserModel(
          userId: "U003",
          name: "Rajesh Kumar",
          phoneNumber: "9876543212",
          emailId: "rajesh@example.com",
          gender: "Male",
          bloodGroup: "A+",
          dateOfBirth: DateTime(1985, 8, 10),
          city: "Mumbai",
          createdAt: DateTime.now(),
          status: true,
        ),
        bookingDate: yesterday.toString().substring(0, 10),
        bookingTime: "11:00 AM",
        selectedTests: ["MRI Scan", "Blood Culture"],
        totalAmount: 3500,
        testFees: 3300,
        reportDeliveryFees: 200,
        discount: 0,
        gst: 0,
        bookingStatus: "Completed",
        paymentStatus: "Paid",
        homeCollectionRequired: true,
        reportDeliveryAtHome: true,
        userAddress: "789, Lake View, Mumbai",
        diagnosticCenter: DiagnosticCenter(
          name: "Advanced Diagnostics",
          gstNumber: "GST345678",
          panNumber: "PAN34567",
          ownerName: "Dr. Mehta",
          regulatoryComplianceUrl: {"NABL": "https://example.com/nabl"},
          qualityAssuranceUrl: {"ISO": "https://example.com/iso"},
          sampleCollectionMethod: "Both",
          testTypes: ["MRI", "CT Scan", "Blood Tests", "Ultrasound"],
          businessTimings: "24 hours",
          businessDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
          homeCollectionGeoLimit: "15 km",
          emergencyHandlingFastTrack: true,
          address: "101, Medical Complex, Powai",
          state: "Maharashtra",
          city: "Mumbai",
          pincode: "400076",
          nearbyLandmark: "Near Powai Lake",
          floor: "Ground Floor",
          parkingAvailable: true,
          wheelchairAccess: true,
          liftAccess: true,
          ambulanceServiceAvailable: true,
          mainContactNumber: "022-34567890",
          emergencyContactNumber: "9876543233",
          email: "advanced@example.com",
          website: "www.advanceddiagnostics.com",
          languagesSpoken: ["English", "Hindi", "Marathi", "Gujarati"],
          centerPhotosUrl: "https://example.com/photos",
          googleMapsLocationUrl: "https://maps.google.com/location",
          password: "password789",
          filesAndImages: [],
          location: "19.1176, 72.9060",
        ),
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];
  }
}

// Extension to add copyWith to LabTestBooking
extension LabTestBookingExtension on LabTestBooking {
  LabTestBooking copyWith({
    String? bookingId,
    String? vendorId,
    String? userId,
    List<String>? selectedTests,
    String? bookingDate,
    String? bookingTime,
    bool? homeCollectionRequired,
    bool? reportDeliveryAtHome,
    String? prescriptionUrl,
    double? testFees,
    double? reportDeliveryFees,
    double? discount,
    double? gst,
    double? totalAmount,
    String? bookingStatus,
    String? paymentStatus,
    String? userAddress,
    String? userLocation,
    String? centerLocationUrl,
    UserModel? user,
    DiagnosticCenter? diagnosticCenter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LabTestBooking(
      bookingId: bookingId ?? this.bookingId,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      selectedTests: selectedTests ?? this.selectedTests,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      homeCollectionRequired: homeCollectionRequired ?? this.homeCollectionRequired,
      reportDeliveryAtHome: reportDeliveryAtHome ?? this.reportDeliveryAtHome,
      prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      testFees: testFees ?? this.testFees,
      reportDeliveryFees: reportDeliveryFees ?? this.reportDeliveryFees,
      discount: discount ?? this.discount,
      gst: gst ?? this.gst,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      userAddress: userAddress ?? this.userAddress,
      userLocation: userLocation ?? this.userLocation,
      centerLocationUrl: centerLocationUrl ?? this.centerLocationUrl,
      user: user ?? this.user,
      diagnosticCenter: diagnosticCenter ?? this.diagnosticCenter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 