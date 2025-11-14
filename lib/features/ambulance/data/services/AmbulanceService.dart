import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class AmbulanceService {
  final Telephony telephony = Telephony.instance;
  String emergencyNumber = ""; // Dynamic ambulance contact
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
      Permission.location,
    ].request();

    if (statuses[Permission.location] != PermissionStatus.granted) {
      print("❌ Some permissions are not granted.");
      return false;
    }
    return true;
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

  Future<bool> triggerAmbulanceEmergency(String providerNumber) async {
    print("🚨 Ambulance Emergency button clicked!");

    try {
      callAmbulance(providerNumber);    // Call only; SMS removed

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
