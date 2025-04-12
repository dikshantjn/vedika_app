import '../model/BloodBankBooking.dart';
import '../model/BloodBankRequest.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankBookingService {
  // Static list of mock requests
  static final List<BloodBankRequest> _mockRequests = [
    BloodBankRequest(
      requestId: 'REQ001',
      userId: 'user1',
      user: UserModel(
        userId: 'user1',
        name: 'John Doe',
        phoneNumber: '+91 9876543210',
        emailId: 'john.doe@example.com',
        bloodGroup: 'A+',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      customerName: 'John Doe',
      bloodType: 'A+',
      units: 2,
      prescriptionUrls: ['https://example.com/prescription1.jpg'],
      requestedVendors: ['vendor1'],
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BloodBankRequest(
      requestId: 'REQ002',
      userId: 'user2',
      user: UserModel(
        userId: 'user2',
        name: 'Jane Smith',
        phoneNumber: '+91 9876543211',
        emailId: 'jane.smith@example.com',
        bloodGroup: 'B+',
        city: 'Delhi',
        createdAt: DateTime.now(),
        status: true,
      ),
      customerName: 'Jane Smith',
      bloodType: 'B+',
      units: 1,
      prescriptionUrls: ['https://example.com/prescription2.jpg'],
      requestedVendors: ['vendor1'],
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BloodBankRequest(
      requestId: 'REQ003',
      userId: 'user3',
      user: UserModel(
        userId: 'user3',
        name: 'Raj Kumar',
        phoneNumber: '+91 9876543212',
        emailId: 'raj.kumar@example.com',
        bloodGroup: 'O+',
        city: 'Bangalore',
        createdAt: DateTime.now(),
        status: true,
      ),
      customerName: 'Raj Kumar',
      bloodType: 'O+',
      units: 3,
      prescriptionUrls: ['https://example.com/prescription3.jpg'],
      requestedVendors: ['vendor1'],
      status: 'confirmed',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Static list of mock bookings
  static final List<BloodBankBooking> _mockBookings = [
    BloodBankBooking(
      bookingId: 'BK001',
      requestId: 'REQ001',
      vendorId: 'vendor1',
      userId: 'user1',
      user: UserModel(
        userId: 'user1',
        name: 'John Doe',
        phoneNumber: '+91 9876543210',
        emailId: 'john.doe@example.com',
        bloodGroup: 'A+',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      deliveryFees: 100.0,
      gst: 18.0,
      discount: 50.0,
      totalAmount: 1068.0,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BloodBankBooking(
      bookingId: 'BK002',
      requestId: 'REQ002',
      vendorId: 'vendor1',
      userId: 'user2',
      user: UserModel(
        userId: 'user2',
        name: 'Jane Smith',
        phoneNumber: '+91 9876543211',
        emailId: 'jane.smith@example.com',
        bloodGroup: 'B+',
        city: 'Delhi',
        createdAt: DateTime.now(),
        status: true,
      ),
      deliveryFees: 100.0,
      gst: 18.0,
      discount: 0.0,
      totalAmount: 1180.0,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BloodBankBooking(
      bookingId: 'BK003',
      requestId: 'REQ003',
      vendorId: 'vendor1',
      userId: 'user3',
      user: UserModel(
        userId: 'user3',
        name: 'Raj Kumar',
        phoneNumber: '+91 9876543212',
        emailId: 'raj.kumar@example.com',
        bloodGroup: 'O+',
        city: 'Bangalore',
        createdAt: DateTime.now(),
        status: true,
      ),
      deliveryFees: 100.0,
      gst: 18.0,
      discount: 100.0,
      totalAmount: 1000.0,
      status: 'confirmed',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Get bookings for a specific vendor
  Future<List<BloodBankBooking>> getBookings(String vendorId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return _mockBookings.where((booking) => booking.vendorId == vendorId).toList();
  }

  // Get request by ID
  Future<BloodBankRequest?> getRequestById(String requestId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRequests.firstWhere((request) => request.requestId == requestId);
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockBookings.indexWhere((booking) => booking.bookingId == bookingId);
    if (index != -1) {
      final updatedBooking = _mockBookings[index].copyWith(status: status);
      _mockBookings[index] = updatedBooking;
    }
  }
} 