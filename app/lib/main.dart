import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/provider/user_session_provider.dart';
import 'package:phone_app/provider/wrk_type_provider.dart';

// for passing user data throughout the app:
import 'package:provider/provider.dart';

import 'components/auth_wrapper.dart';
import 'provider/user_data_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const AuthWrapper()),
    );
  }
}
