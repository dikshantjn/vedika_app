import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class EmergencyService {
  final Telephony telephony = Telephony.instance;


  String senderNumber = "Unknown"; // Mobile number of the device
  late LocationProvider locationProvider; // Use existing LocationProvider

  EmergencyService(this.locationProvider);

  // ✅ Initialize on App Startup
  Future<void> initialize() async {
    print("🔄 Initializing EmergencyService...");

    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      print("❌ Permissions not granted. Some features may not work.");
      return;
    }

    await _getMobileNumber();  // Fetch device number
    await locationProvider.initializeLocation(); // Ensure location is available

    print("✅ EmergencyService is ready!");
  }

  // ✅ Request All Permissions in Advance
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
  Future<void> _getMobileNumber() async {
    try {
      bool hasPermission = await MobileNumber.hasPhonePermission;
      if (!hasPermission) {
        await MobileNumber.requestPhonePermission;
      }

      List<SimCard>? simCards = await MobileNumber.getSimCards;
      if (simCards != null && simCards.isNotEmpty) {
        senderNumber = simCards.first.number ?? "Unknown";
      }

      print("📞 Device Mobile Number: $senderNumber");
    } catch (e) {
      print("❌ Error fetching mobile number: $e");
    }
  }

  // ✅ Make Emergency Call for Doctor
  Future<void> _makeDoctorEmergencyCall(String mobileNumber) async {
    try {
      print("📞 Initiating emergency call for Doctor...");
      await telephony.dialPhoneNumber(mobileNumber);
      print("✅ Calling Doctor emergency number: $mobileNumber");
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

    print("📨 Checking SMS permission...");
    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    print("📨 Sending Doctor Emergency SMS...");
    await telephony.sendSms(
      to: mobileNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
          print("✅ Doctor Emergency SMS sent successfully!");
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Doctor Emergency
  Future<void> triggerDoctorEmergency(String mobileNumber) async {
    print("🚨 Doctor Emergency button clicked!");
    await _sendDoctorEmergencySMS(mobileNumber);  // ✅ Send SMS immediately
    _makeDoctorEmergencyCall(mobileNumber); // ✅ Make call immediately
  }

  // ✅ Make Emergency Call for Ambulance
  Future<void> _makeAmbulanceEmergencyCall(String mobileNumber) async {
    try {
      print("📞 Initiating emergency call for Ambulance...");
      await telephony.dialPhoneNumber(mobileNumber);
      print("✅ Calling Ambulance emergency number: $mobileNumber");
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

    print("📨 Checking SMS permission...");
    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    print("📨 Sending Ambulance Emergency SMS...");
    await telephony.sendSms(
      to: mobileNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
          print("✅ Ambulance Emergency SMS sent successfully!");
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Ambulance Emergency
  Future<void> triggerAmbulanceEmergency(String mobileNumber) async {
    print("🚨 Ambulance Emergency button clicked!");
    await _sendAmbulanceEmergencySMS(mobileNumber);  // ✅ Send SMS immediately
    _makeAmbulanceEmergencyCall(mobileNumber); // ✅ Make call immediately
  }

  // ✅ Make Emergency Call for Blood Bank
  Future<void> _makeBloodBankEmergencyCall(String mobileNumber) async {
    try {
      print("📞 Initiating emergency call for Blood Bank...");
      await telephony.dialPhoneNumber(mobileNumber);
      print("✅ Calling Blood Bank emergency number: $mobileNumber");
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

    print("📨 Checking SMS permission...");
    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    print("📨 Sending Blood Bank Emergency SMS...");
    await telephony.sendSms(
      to: mobileNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
          print("✅ Blood Bank Emergency SMS sent successfully!");
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Blood Bank Emergency
  Future<void> triggerBloodBankEmergency(String mobileNumber) async {
    print("🚨 Blood Bank Emergency button clicked!");
    await _sendBloodBankEmergencySMS(mobileNumber);  // ✅ Send SMS immediately
    _makeBloodBankEmergencyCall(mobileNumber); // ✅ Make call immediately
  }
}
