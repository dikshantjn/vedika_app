import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PipPlatform {
  static const MethodChannel _channel = MethodChannel('pip_channel');
  static final ValueNotifier<bool> isInAndroidPip = ValueNotifier<bool>(false);
  static bool _initialized = _init();
  static bool _inScreenShareFlow = false;
  static bool get inScreenShareFlow => _inScreenShareFlow;

  static bool _init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPipChanged') {
        final bool value = (call.arguments as bool?) ?? false;
        isInAndroidPip.value = value;
      } else if (call.method == 'onPipAction') {
        final String action = (call.arguments as String?) ?? '';
        switch (action) {
          case 'mic':
            _onMic?.call();
            break;
          case 'cam':
            _onCam?.call();
            break;
          case 'end':
            _onEnd?.call();
            break;
          case 'expand':
            _onExpand?.call();
            break;
        }
      }
      return null;
    });
    return true;
  }

  static Future<void> setMeetingScreen(bool isInMeeting) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _channel.invokeMethod('setMeetingScreen', isInMeeting);
      } catch (_) {}
    }
  }

  static Future<void> enterPiPMode() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _channel.invokeMethod('enterPiPMode');
      } catch (_) {}
    }
  }

  static Future<void> setScreenShareFlow(bool inFlow) async {
    _inScreenShareFlow = inFlow;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _channel.invokeMethod('setScreenShareFlow', inFlow);
      } catch (_) {}
    }
  }

  static VoidCallback? _onMic;
  static VoidCallback? _onCam;
  static VoidCallback? _onEnd;
  static VoidCallback? _onExpand;
  static void setActionHandlers({
    VoidCallback? onMic,
    VoidCallback? onCam,
    VoidCallback? onEnd,
    VoidCallback? onExpand,
  }) {
    _onMic = onMic;
    _onCam = onCam;
    _onEnd = onEnd;
    _onExpand = onExpand;
  }
}


