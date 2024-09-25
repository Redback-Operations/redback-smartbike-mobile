import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Schedule a notification at a specific time
  static Future<void> scheduleNotification(DateTime scheduledDateTime) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iosDetails = IOSNotificationDetails();
    var platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      'This is your scheduled notification!',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Optional: Function to clear all pending notifications
  static Future<void> clearPendingNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
