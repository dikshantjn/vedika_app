import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'fall_detection_service.dart';

void main() {
  late FallDetectionService fallDetectionService;

  setUp(() {
    fallDetectionService = FallDetectionService();
  });

  tearDown(() {
    fallDetectionService.dispose();
  });

  test('Fall detection service is singleton', () {
    final instance1 = FallDetectionService();
    final instance2 = FallDetectionService();
    expect(instance1, equals(instance2));
  });

  test('Fall detection threshold constants', () {
    expect(FallDetectionService.FALL_THRESHOLD, 25.0);
    expect(FallDetectionService.STILLNESS_DURATION, 5);
    expect(FallDetectionService.CANCEL_TIMER, 5);
  });

  test('Fall detection stream emits events', () async {
    bool? lastEvent;
    fallDetectionService.fallDetectedStream.listen((event) {
      lastEvent = event;
    });

    // Start monitoring to initialize the service
    await fallDetectionService.startMonitoring();
    
    // Simulate fall detection by directly adding to stream
    fallDetectionService.fallDetectedStream.add(true);
    expect(lastEvent, isTrue);

    // Test cancel alert
    fallDetectionService.cancelAlert();
    expect(lastEvent, isFalse);
  });

  test('Service can be started and stopped', () async {
    await fallDetectionService.startMonitoring();
    fallDetectionService.stopMonitoring();
    // No assertion needed as we're just testing the methods don't throw
  });
} 