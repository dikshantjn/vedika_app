# Fall Detection Feature

This feature provides automatic fall detection using the device's accelerometer and gyroscope sensors. It's designed to help elderly users or those at risk of falls by automatically alerting emergency contacts when a fall is detected.

## Features

- Continuous motion monitoring using device sensors
- Fall detection based on acceleration threshold and stillness period
- Automatic SMS alerts to emergency contacts
- Location sharing with emergency alerts
- In-app notifications
- Cancel alert functionality for false positives
- Background service support

## Implementation Details

### Components

1. `FallDetectionService`: Core service that handles sensor monitoring and fall detection logic
2. `SmsService`: Handles sending emergency SMS messages
3. `FallDetectionWidget`: UI component for displaying status and controls
4. Unit tests for fall detection logic

### Dependencies

- `sensors_plus`: For accessing device sensors
- `geolocator`: For location services
- `permission_handler`: For handling runtime permissions

### Required Permissions

- `SEND_SMS`: For sending emergency messages
- `ACCESS_FINE_LOCATION`: For sharing location with emergency contacts
- `ACTIVITY_RECOGNITION`: For better fall detection accuracy

## Usage

1. Add the `FallDetectionWidget` to your app's UI:
```dart
FallDetectionWidget()
```

2. Configure emergency contacts in your app's settings

3. The feature will automatically handle:
   - Permission requests
   - Sensor monitoring
   - Fall detection
   - Emergency alerts

## Testing

Run the unit tests:
```bash
flutter test lib/features/fallDetection/fall_detection_service_test.dart
```

## Notes

- The fall detection threshold is set to 25 m/s²
- Stillness period is set to 5 seconds
- Cancel alert timer is set to 5 seconds
- These values can be adjusted based on testing and user feedback 