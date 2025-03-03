import 'package:vedika_healthcare/features/notifications/data/models/NotificationModel.dart';

class NotificationRepository {
  // Simulate fetching data from a local database or API
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay for fetching data

    // Return a list of sample notifications
    return [
      NotificationModel(
        id: '1',
        title: 'Ambulance Request Accepted',
        message: 'Your ambulance request has been accepted.',
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      ),
      NotificationModel(
        id: '2',
        title: 'Appointment Reminder',
        message: 'Your appointment is tomorrow at 3:00 PM.',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }
}
