import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class EmergencyService {
  static EmergencyService? _instance;
  static bool _isInitialized = false;
  
  final Telephony telephony = Telephony.instance;
  String senderNumber = "Unknown"; // Mobile number of the device
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

    // await _instance!._getMobileNumber();  // Fetch device number
    await _instance!.locationProvider.initializeLocation(); // Ensure location is available
    
    _isInitialized = true;
  }

  // Check if service is initialized
  static bool get isInitialized => _isInitialized;

  // Request All Permissions in Advance
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.sms,
      Permission.location,
      Permission.contacts,
    ].request();

    if (statuses[Permission.phone] != PermissionStatus.granted ||
        statuses[Permission.sms] != PermissionStatus.granted ||
        statuses[Permission.location] != PermissionStatus.granted ||
        statuses[Permission.contacts] != PermissionStatus.granted) {
      print("❌ Some permissions are not granted.");
      return false;
    }
    return true;
  }

  // ✅ Get Device Mobile Number
  // Future<void> _getMobileNumber() async {
  //   try {
  //     bool hasPermission = await MobileNumber.hasPhonePermission;
  //     if (!hasPermission) {
  //       await MobileNumber.requestPhonePermission;
  //     }
  //
  //     List<SimCard>? simCards = await MobileNumber.getSimCards;
  //     if (simCards != null && simCards.isNotEmpty) {
  //       senderNumber = simCards.first.number ?? "Unknown";
  //     }
  //
  //     print("📞 Device Mobile Number: $senderNumber");
  //   } catch (e) {
  //     print("❌ Error fetching mobile number: $e");
  //   }
  // }

  // ✅ Make Emergency Call for Doctor
  Future<void> _makeDoctorEmergencyCall(String mobileNumber) async {
    try {
      await telephony.dialPhoneNumber(mobileNumber);
    } catch (e) {
      print("❌ Error making call: $e");
    }
  }

  // ✅ Send Emergency SMS for Doctor
  Future<void> _sendDoctorEmergencySMS(String mobileNumber) async {
    if (!locationProvider.isLocationLoaded) {
      print("❌ Location not available. Trying to fetch again...");
      await locationProvider.loadSavedLocation();
    }

    String message = "Doctor Emergency! Immediate assistance required.\n"
        "Location: https://maps.google.com/?q=${locationProvider.latitude},${locationProvider.longitude}\n"
        "Caller: $mobileNumber";

    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    await telephony.sendSms(
      to: mobileNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Doctor Emergency
  Future<void> triggerDoctorEmergency(String mobileNumber) async {
    await _sendDoctorEmergencySMS(mobileNumber);  // ✅ Send SMS immediately
    _makeDoctorEmergencyCall(mobileNumber); // ✅ Make call immediately
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

  // ✅ Send Emergency SMS for Ambulance
  Future<void> _sendAmbulanceEmergencySMS(String mobileNumber) async {
    if (!locationProvider.isLocationLoaded) {
      print("❌ Location not available. Trying to fetch again...");
      await locationProvider.loadSavedLocation();
    }

    String message = "Ambulance Emergency! Immediate help required.\n"
        "Location: https://maps.google.com/?q=${locationProvider.latitude},${locationProvider.longitude}\n"
        "Caller: $mobileNumber";

    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    await telephony.sendSms(
      to: mobileNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Ambulance Emergency
  Future<void> triggerAmbulanceEmergency(String mobileNumber) async {
    await _sendAmbulanceEmergencySMS(mobileNumber);  // ✅ Send SMS immediately
    _makeAmbulanceEmergencyCall(mobileNumber); // ✅ Make call immediately
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

  // ✅ Send Emergency SMS for Blood Bank
  Future<void> _sendBloodBankEmergencySMS(String mobileNumber) async {
    if (!locationProvider.isLocationLoaded) {
      print("❌ Location not available. Trying to fetch again...");
      await locationProvider.loadSavedLocation();
    }

    String message = "Blood Bank Emergency! Urgent blood required.\n"
        "Location: https://maps.google.com/?q=${locationProvider.latitude},${locationProvider.longitude}\n"
        "Caller: $mobileNumber";

    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    await telephony.sendSms(
      to: mobileNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Blood Bank Emergency
  Future<void> triggerBloodBankEmergency(String mobileNumber) async {
    await _sendBloodBankEmergencySMS(mobileNumber);  // ✅ Send SMS immediately
    _makeBloodBankEmergencyCall(mobileNumber); // ✅ Make call immediately
  }
}
