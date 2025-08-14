import 'dart:async';
import 'package:flutter/services.dart';

class NativeSpeech {
  static const MethodChannel _control = MethodChannel('native_speech/control');
  static const EventChannel _events = EventChannel('native_speech/events');

  static Stream<Map<dynamic, dynamic>>? _stream;

  static Future<void> start() async {
    try {
      await _control.invokeMethod('start');
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _control.invokeMethod('stop');
    } catch (_) {}
  }

  static Stream<Map<dynamic, dynamic>> events() {
    _stream ??= _events.receiveBroadcastStream().map((e) => e as Map<dynamic, dynamic>);
    return _stream!;
  }
}


