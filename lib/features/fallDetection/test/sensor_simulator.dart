import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorSimulator {
  static Stream<AccelerometerEvent> simulateFall() async* {
    final now = DateTime.now();
    // Normal movement
    yield AccelerometerEvent(0.0, 0.0, 9.8, now.millisecondsSinceEpoch); // Normal gravity
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Sudden acceleration (fall)
    yield AccelerometerEvent(15.0, 15.0, 15.0, now.millisecondsSinceEpoch + 100); // High acceleration
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Impact
    yield AccelerometerEvent(25.0, 25.0, 25.0, now.millisecondsSinceEpoch + 200); // Impact acceleration
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Stillness after fall
    yield AccelerometerEvent(0.0, 0.0, 9.8, now.millisecondsSinceEpoch + 300); // Back to normal
    await Future.delayed(const Duration(seconds: 6)); // Wait for stillness period
  }

  static Stream<AccelerometerEvent> simulateNormalMovement() async* {
    final now = DateTime.now();
    // Simulate walking
    for (int i = 0; i < 10; i++) {
      yield AccelerometerEvent(
        sin(i * 0.5) * 2.0, // x-axis movement
        cos(i * 0.5) * 2.0, // y-axis movement
        9.8, // z-axis (gravity)
        now.millisecondsSinceEpoch + (i * 100),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
} 