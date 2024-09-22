import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/provider/user_session_provider.dart';
import 'package:phone_app/provider/wrk_type_provider.dart';
import 'package:phone_app/utilities/custom_theme_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz; // Import timezone package
import 'package:timezone/timezone.dart' as tz; // Import timezone

// for passing user data throughout the app:
import 'package:provider/provider.dart';
import 'components/auth_wrapper.dart';
import 'provider/user_data_provider.dart';

// Initialize flutterLocalNotificationsPlugin directly
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize the notification plugin
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // the multiprovider allows to access current data
    // it is loaded first upon logging in -> taken from backend
    // then when editing profile and saving to backend, it is saved too
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutTypeProvider()),
        ChangeNotifierProvider(create: (_) => UserSessionProvider())
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: customThemeData(),
          home: const AuthWrapper()),
    );
  }
}

// Function to schedule a notification
Future<void> scheduleNotification(DateTime scheduledDateTime) async {
  var androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
  );

  var iosDetails = IOSNotificationDetails();
  var platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Reminder',
    'This is your scheduled notification!',
    tz.TZDateTime.from(scheduledDateTime, tz.local), // Use timezone package
    platformDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}

// Optional bonus function to clear all pending notifications
Future<void> clearPendingNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}
