import 'package:flutter/material.dart';
import 'package:phone_app/pages/tab_layout.dart';
import 'package:phone_app/provider/user_data_provider.dart';
import 'package:provider/provider.dart';
import '../pages/login.dart';
import '../provider/user_session_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final sessionProvider = Provider.of<UserSessionProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    await sessionProvider.loadUserSession();

    if (sessionProvider.isLoggedIn) {
      // If user is logged in, load user details into UserDataProvider
      await userDataProvider.loadUserDetails(sessionProvider);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Navigate based on session state
      final sessionProvider = Provider.of<UserSessionProvider>(context, listen: false);
      if (sessionProvider.isLoggedIn) {
        return const TabLayout();
      } else {
        return LoginPage();
      }
    }
  }
}