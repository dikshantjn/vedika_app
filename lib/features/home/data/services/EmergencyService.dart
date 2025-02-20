import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_number/mobile_number.dart';

class EmergencyService {
  final Telephony telephony = Telephony.instance;
  final String emergencyNumber = "+919370320066"; // Emergency contact
  String senderNumber = "Unknown"; // Mobile number of the device
  Position? lastKnownPosition; // Store location in advance

  // ✅ Initialize on App Startup
  Future<void> initialize() async {
    print("🔄 Initializing EmergencyService...");
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      print("❌ Permissions not granted. Some features may not work.");
      return;
    }
    await _getMobileNumber();  // Fetch device number
    await _fetchLocation();  // Get location in advance
    print("✅ EmergencyService is ready!");
  }

  // ✅ Request All Permissions in Advance
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.sms,
      Permission.location,
      Permission.contacts,  // Ensure permission for getting the mobile number
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

  // ✅ Fetch Mobile Number
  Future<void> _getMobileNumber() async {
    try {
      List<SimCard>? simCards = await MobileNumber.getSimCards; // Nullable
      if (simCards != null && simCards.isNotEmpty) {
        senderNumber = simCards.first.number ?? "Unknown";
      }
      print("📞 Device Mobile Number: $senderNumber");
    } catch (e) {
      print("❌ Error fetching mobile number: $e");
    }
  }

  // ✅ Fetch Location in Advance
  Future<void> _fetchLocation() async {
    try {
      print("📍 Fetching initial location...");
      lastKnownPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("✅ Location fetched: ${lastKnownPosition?.latitude}, ${lastKnownPosition?.longitude}");
    } catch (e) {
      print("❌ Error fetching location: $e");
    }
  }

  // ✅ Make Emergency Call
  Future<void> _makeEmergencyCall() async {
    try {
      print("📞 Initiating emergency call...");
      await telephony.dialPhoneNumber(emergencyNumber);
      print("✅ Calling emergency number: $emergencyNumber");
    } catch (e) {
      print("❌ Error making call: $e");
    }
  }

  // ✅ Send Emergency SMS
  Future<void> _sendEmergencySMS() async {
    if (lastKnownPosition == null) {
      print("❌ Location not available. Trying to fetch again...");
      await _fetchLocation(); // Try fetching again if needed
    }

    String message = "Emergency! Need immediate help.\n"
        "Location: https://maps.google.com/?q=${lastKnownPosition?.latitude},${lastKnownPosition?.longitude}\n"
        "Caller: $senderNumber";

    print("📨 Checking SMS permission...");
    bool canSendSms = (await telephony.requestSmsPermissions) ?? false;
    if (!canSendSms) {
      print("❌ SMS permission denied!");
      return;
    }

    print("📨 Sending Emergency SMS...");
    await telephony.sendSms(
      to: emergencyNumber,
      message: message,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
          print("✅ Emergency SMS sent successfully!");
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  // ✅ Trigger Emergency (FAST Execution)
  Future<void> triggerEmergency() async {
    print("🚨 Emergency button clicked!");
    _sendEmergencySMS();  // ✅ Send SMS immediately
    _makeEmergencyCall(); // ✅ Make call immediately
  }
}
