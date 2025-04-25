import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';

class DiagnosticCenterService {
  // Mock data for testing
  final DiagnosticCenter _mockProfile = DiagnosticCenter(
    name: 'HealthCare Diagnostics',
    gstNumber: 'GST123456789',
    panNumber: 'PAN123456789',
    ownerName: 'Dr. John Smith',
    regulatoryComplianceUrl: {
      'license': 'https://example.com/license.pdf',
      'certification': 'https://example.com/certification.pdf',
    },
    qualityAssuranceUrl: {
      'iso': 'https://example.com/iso.pdf',
      'accreditation': 'https://example.com/accreditation.pdf',
    },
    sampleCollectionMethod: 'Both',
    testTypes: [
      'Blood Tests',
      'Urine Tests',
      'X-Ray',
      'MRI',
      'CT Scan',
      'Ultrasound',
    ],
    businessTimings: '9:00 AM - 8:00 PM',
    businessDays: [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ],
    homeCollectionGeoLimit: '5 km radius',
    emergencyHandlingFastTrack: true,
    address: '123 Medical Plaza, Health Street',
    state: 'Maharashtra',
    city: 'Mumbai',
    pincode: '400001',
    nearbyLandmark: 'Near City Hospital',
    floor: '2nd Floor',
    parkingAvailable: true,
    wheelchairAccess: true,
    liftAccess: true,
    ambulanceServiceAvailable: true,
    mainContactNumber: '+91 9876543210',
    emergencyContactNumber: '+91 9876543211',
    email: 'contact@healthcare.com',
    website: 'www.healthcare.com',
    languagesSpoken: ['English', 'Hindi', 'Marathi'],
    centerPhotosUrl: 'https://example.com/center-photos',
    googleMapsLocationUrl: 'https://maps.google.com/center-location',
    vendorId: 'VENDOR123',
    generatedId: 'DC123',
    password: 'hashedPassword123',
    filesAndImages: [
      {'name': 'Center Front', 'url': 'https://example.com/front.jpg'},
      {'name': 'Waiting Area', 'url': 'https://example.com/waiting.jpg'},
      {'name': 'Lab Room', 'url': 'https://example.com/lab.jpg'},
    ],
    location: '19.0760° N, 72.8777° E',
  );

  Future<DiagnosticCenter?> getDiagnosticCenterById(String vendorId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data for testing
    return _mockProfile;
  }

  Future<bool> updateDiagnosticCenter(String vendorId, DiagnosticCenter profile) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate successful update
    return true;
  }
} 