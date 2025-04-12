import '../model/BloodBankRequest.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankRequestService {
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
      prescriptionUrls: [
        'https://example.com/prescriptions/p1.pdf',
        'https://example.com/prescriptions/p2.pdf'
      ],
      requestedVendors: ['vendor1', 'vendor2'],
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
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
      units: 3,
      prescriptionUrls: [
        'https://example.com/prescriptions/p3.pdf'
      ],
      requestedVendors: ['vendor1'],
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
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
      units: 1,
      prescriptionUrls: [
        'https://example.com/prescriptions/p4.pdf'
      ],
      requestedVendors: ['vendor1', 'vendor3'],
      status: 'expired',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Get requests for a specific vendor
  Future<List<BloodBankRequest>> getRequests(String vendorId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return _mockRequests
        .where((request) => request.requestedVendors.contains(vendorId))
        .toList();
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockRequests.indexWhere((request) => request.requestId == requestId);
    if (index != -1) {
      final updatedRequest = _mockRequests[index].copyWith(status: status);
      _mockRequests[index] = updatedRequest;
    }
  }
} 