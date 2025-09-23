import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_number/mobile_number.dart';

class AmbulanceService {
  final Telephony telephony = Telephony.instance;
  String emergencyNumber = ""; // Dynamic ambulance contact
  String senderNumber = "Unknown"; // Device's mobile number
  Position? lastKnownPosition; // Store location in advance

  // ✅ Initialize Service on App Startup
  Future<void> initialize() async {
    print("🔄 Initializing AmbulanceService...");
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      print("❌ Permissions not granted. Some features may not work.");
      return;
    }
    // await _getMobileNumber(); // Fetch device number
    await _fetchLocation(); // Get location in advance
  }

  // ✅ Request All Necessary Permissions
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

  // // ✅ Fetch Device Mobile Number
  // Future<void> _getMobileNumber() async {
  //   try {
  //     bool hasPermission = await MobileNumber.hasPhonePermission;
  //     if (!hasPermission) {
  //       await MobileNumber.requestPhonePermission;
  //     }
  //
  //     List<SimCard>? simCards = await MobileNumber.getSimCards;
  //
  //     if (simCards != null && simCards.isNotEmpty) {
  //       senderNumber = simCards.first.number ?? "Unknown";
  //     }
  //
  //     print("📞 Device Mobile Number: $senderNumber");
  //   } catch (e) {
  //     print("❌ Error fetching mobile number: $e");
  //   }
  // }

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

  // ✅ Make Direct Call to Ambulance
  Future<void> callAmbulance(String providerNumber) async {
    try {
      emergencyNumber = providerNumber; // Set dynamic number
      print("📞 Calling Ambulance: $emergencyNumber...");
      await telephony.dialPhoneNumber(emergencyNumber);
      print("✅ Calling initiated to: $emergencyNumber");
    } catch (e) {
      print("❌ Error making call: $e");
    }
  }

  // ✅ Send Emergency SMS to Ambulance
  Future<void> sendEmergencySMS(String providerNumber) async {
    emergencyNumber = providerNumber; // Set dynamic number

    if (lastKnownPosition == null) {
      print("❌ Location not available. Trying to fetch again...");
      await _fetchLocation();
    }

    String message = "Emergency! Need an ambulance urgently.\n"
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
        } else {
          print("❌ Failed to send SMS.");
        }
      },
    );
  }

  Future<bool> triggerAmbulanceEmergency(String providerNumber) async {
    print("🚨 Ambulance Emergency button clicked!");

    try {
      // await _getMobileNumber();
      sendEmergencySMS(providerNumber); // ✅ Send SMS
      callAmbulance(providerNumber);    // ✅ Call immediately

      // ✅ Simulating request acceptance (Replace with real API response)
      await Future.delayed(Duration(seconds: 2)); // Simulate processing time
      bool isAccepted = true; // Simulated response (change based on real logic)

      return isAccepted;
    } catch (e) {
      print("Error triggering ambulance emergency: $e");
      return false;
    }
  }
}
