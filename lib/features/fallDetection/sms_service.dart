import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static const platform = MethodChannel('com.vedika.app/sms');

  Future<bool> sendEmergencySms({
    required List<String> phoneNumbers,
    required String message,
    String? location,
  }) async {
    try {
      if (!await Permission.sms.isGranted) {
        final status = await Permission.sms.request();
        if (!status.isGranted) {
          return false;
        }
      }

      final Map<String, dynamic> arguments = {
        'phoneNumbers': phoneNumbers,
        'message': message,
        'location': location,
      };

      final bool result = await platform.invokeMethod('sendEmergencySms', arguments);
      return result;
    } on PlatformException catch (e) {
      print('Error sending SMS: ${e.message}');
      return false;
    }
  }
} 