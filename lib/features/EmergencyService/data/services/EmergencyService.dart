import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class EmergencyService {
  static EmergencyService? _instance;
  static bool _isInitialized = false;
  
  final Telephony telephony = Telephony.instance;
  late LocationProvider locationProvider; // Use existing LocationProvider

  // Private constructor to prevent external instantiation
  EmergencyService._internal(this.locationProvider);

  // Singleton getter
  static EmergencyService get instance {
    if (_instance == null) {
      throw StateError('EmergencyService has not been initialized. Call EmergencyService.initialize() first.');
    }
    return _instance!;
  }

  // Initialize method that should only be called once
  static Future<void> initialize(LocationProvider locationProvider) async {
    if (_isInitialized) {
      print("⚠️ EmergencyService already initialized, skipping...");
      return;
    }

    print("🔄 Initializing EmergencyService...");
    _instance = EmergencyService._internal(locationProvider);
    
    bool hasPermissions = await _instance!._requestPermissions();
    if (!hasPermissions) {
      print("❌ Permissions not granted. Some features may not work.");
      return;
    }

    await _instance!.locationProvider.initializeLocation(); // Ensure location is available
    
    _isInitialized = true;
  }

  // Check if service is initialized
  static bool get isInitialized => _isInitialized;

  // Request All Permissions in Advance
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();

    if (statuses[Permission.location] != PermissionStatus.granted) {
      print("❌ Some permissions are not granted.");
      return false;
    }
    return true;
  }

  // ✅ Make Emergency Call for Doctor
  Future<void> _makeDoctorEmergencyCall(String mobileNumber) async {
    try {
      await telephony.dialPhoneNumber(mobileNumber);
    } catch (e) {
      print("❌ Error making call: $e");
    }
  }

  // ✅ Trigger Doctor Emergency
  Future<void> triggerDoctorEmergency(String mobileNumber) async {
    _makeDoctorEmergencyCall(mobileNumber); // Call only; SMS removed
  }

  // ✅ Make Emergency Call for Ambulance
  Future<void> _makeAmbulanceEmergencyCall(String mobileNumber) async {
    try {
      print("📞 Initiating emergency call for Ambulance...");
      await telephony.dialPhoneNumber(mobileNumber);
    } catch (e) {
      print("❌ Error making call: $e");
    }
  }

  // ✅ Trigger Ambulance Emergency
  Future<void> triggerAmbulanceEmergency(String mobileNumber) async {
    _makeAmbulanceEmergencyCall(mobileNumber); // Call only; SMS removed
  }

  // ✅ Make Emergency Call for Blood Bank
  Future<void> _makeBloodBankEmergencyCall(String mobileNumber) async {
    try {
      print("📞 Initiating emergency call for Blood Bank...");
      await telephony.dialPhoneNumber(mobileNumber);
    } catch (e) {
      print("❌ Error making call: $e");
    }
  }

  // ✅ Trigger Blood Bank Emergency
  Future<void> triggerBloodBankEmergency(String mobileNumber) async {
    _makeBloodBankEmergencyCall(mobileNumber); // Call only; SMS removed
  }
}
