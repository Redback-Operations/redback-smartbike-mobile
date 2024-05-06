import 'package:flutter/material.dart';
import 'package:phone_app/provider/wrk_type_provider.dart';
import 'pages/login.dart';
// for passing user data throughout the app:
import 'package:provider/provider.dart';
import 'provider/user_data_provider.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // the multiprovider allows to access current data
    // it is loaded first upon logging in -> taken from backend
    // then when editing profile and saving to backend, it is saved too
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutTypeProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: LoginPage(), // Set LoginPage as the initial page
      ),
    );
  }
}
