import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/pages/login.dart';
import 'package:phone_app/pages/schedule_workout_screen.dart';
import 'package:phone_app/pages/set_workout_page.dart';
import 'package:phone_app/pages/signup.dart';
import 'package:phone_app/provider/user_session_provider.dart';
import 'package:phone_app/provider/wrk_type_provider.dart';
import 'package:phone_app/utilities/custom_theme_data.dart';
import 'package:phone_app/utilities/notification.dart'; // Import the NotificationService

// for passing user data throughout the app:
import 'package:provider/provider.dart';
import 'components/auth_wrapper.dart';
import 'provider/user_data_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Initialize the notification service
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          home: SignUpPage()
      ),
    );
  }
}

// Function to schedule notification (This can be used anywhere in the app)
void testNotification() {
  DateTime now = DateTime.now();
  DateTime scheduledTime = now.add(Duration(seconds: 5)); // Schedules notification in 5 seconds
  NotificationService.scheduleNotification(scheduledTime); // Use NotificationService
}
