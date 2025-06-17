import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../fall_detection_service.dart';
import 'sensor_simulator.dart';

void main() {
  late FallDetectionService fallDetectionService;

  setUp(() {
    fallDetectionService = FallDetectionService();
  });

  tearDown(() {
    fallDetectionService.dispose();
  });

  testWidgets('Fall detection integration test', (WidgetTester tester) async {
    // Start monitoring
    await fallDetectionService.startMonitoring();

    // Listen for fall detection events
    bool fallDetected = false;
    fallDetectionService.fallDetectedStream.listen((event) {
      fallDetected = event;
    });

    // Simulate a fall
    await for (final event in SensorSimulator.simulateFall()) {
      // Inject the simulated sensor event
      // Note: This is a simplified test. In a real app, you'd need to mock the sensors_plus package
      // or use a platform channel to inject sensor data
      if (event.x * event.x + event.y * event.y + event.z * event.z > 
          FallDetectionService.FALL_THRESHOLD * FallDetectionService.FALL_THRESHOLD) {
        // Simulate the fall detection logic by calling the service's methods
        await fallDetectionService.startMonitoring();
      }
    }

    // Wait for the stillness period
    await Future.delayed(const Duration(seconds: 6));

    // Verify fall was detected
    expect(fallDetected, isTrue);

    // Test cancel alert
    fallDetectionService.cancelAlert();
    expect(fallDetected, isFalse);
  });

  testWidgets('Normal movement should not trigger fall detection', 
    (WidgetTester tester) async {
    // Start monitoring
    await fallDetectionService.startMonitoring();

    // Listen for fall detection events
    bool fallDetected = false;
    fallDetectionService.fallDetectedStream.listen((event) {
      fallDetected = event;
    });

    // Simulate normal movement
    await for (final event in SensorSimulator.simulateNormalMovement()) {
      // Inject the simulated sensor event
      if (event.x * event.x + event.y * event.y + event.z * event.z > 
          FallDetectionService.FALL_THRESHOLD * FallDetectionService.FALL_THRESHOLD) {
        await fallDetectionService.startMonitoring();
      }
    }

    // Verify no fall was detected
    expect(fallDetected, isFalse);
  });
} 