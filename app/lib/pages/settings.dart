import 'package:flutter/material.dart';
import 'package:phone_app/pages/login.dart';
import 'package:phone_app/pages/message_center.dart';
import 'package:phone_app/pages/schedule_workout_screen.dart';
import 'package:phone_app/provider/user_session_provider.dart';
import 'package:phone_app/utilities/constants.dart';
import '../components/account_containers.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/main_app_background.dart';
import '../provider/user_data_provider.dart';
import 'my_account.dart';
import 'home_page.dart';
import 'contact.dart';
import 'about_us.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class Setting extends StatefulWidget {
  const Setting({super.key, required this.title});
  final String title;

  @override
  State<Setting> createState() => _Setting();
}

class _Setting extends State<Setting> {
  // functions for signing out, depending on how he signed in. Clear the data
  Future<void> _handleLogout(BuildContext context) async {
    if (_googleSignIn.currentUser != null) {
      // if Google user is signed in
      await _handleGoogleSignOut();
      await Provider.of<UserDataProvider>(context, listen: false).clearSession(
          Provider.of<UserSessionProvider>(context, listen: false));
    } else {
      // clear manual sign in data
      await Provider.of<UserDataProvider>(context, listen: false).clearSession(
          Provider.of<UserSessionProvider>(context, listen: false));
    }

    // go back to the login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // Clear all routes except the new login page.
    );
  }

  Future<void> _handleGoogleSignOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      print('User signed out and disconnected.');
    } catch (error) {
      if (kDebugMode) {
        print('Sign out error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour
              .withOpacity(0.9), // Set the background color
          title: Text(
            'Settings',
            style: kSubSubTitleOfPage,
          ),
          centerTitle: true,
        ),
        body: CustomGradientContainerSoft(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                AccountContainer(
                  fieldName: 'Account',
                  typeIcon: Icons.account_circle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyAccount(title: 'My Account'),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Message Center',
                  typeIcon: Icons.message_sharp,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageCenter(),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'About Us',
                  typeIcon: Icons.info,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformationScreen(),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Help',
                  typeIcon: Icons.contact_support,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactUsScreen(),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Logout',
                  typeIcon: Icons.exit_to_app,
                  onPressed: () async {
                    // Perform logout actions here, such as clearing authentication tokens.
                    // Navigate to the login screen or any other desired screen.
                    await _handleLogout(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) =>
                          false, // Clear all routes except the new login page.
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'My workout history',
                  typeIcon: Icons.exit_to_app,
                  onPressed: () {
                    // this function check if we signed in by using google or by providing details manually
                    _handleLogout(context);
                  },
                  arrowOptional: Icons.gradient,
                ),
                SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Schedule workout',
                  typeIcon: Icons.exit_to_app,
                  onPressed: () {
                    // Perform logout actions here, such as clearing authentication tokens.
                    // Navigate to the login screen or any other desired screen.
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScheduleWorkoutScreen()),
                      (route) =>
                          false, // Clear all routes except the new login page.
                    );
                  },
                  arrowOptional: Icons.gradient,
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ));
  }
}
