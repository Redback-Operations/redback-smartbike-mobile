import 'package:flutter/material.dart';
import 'package:phone_app/pages/login.dart';
import 'package:phone_app/pages/message_center.dart';
import 'package:phone_app/pages/privacy.dart';
import 'package:phone_app/pages/terminate_account.dart';
import 'package:phone_app/utilities/constants.dart';
import '../components/account_containers.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/main_app_background.dart';
import 'email.dart';
import 'my_account.dart';
import 'message_center.dart';
import 'Friends.dart';
import 'home_page.dart';
import 'contact.dart';
import 'about_us.dart';
import 'my_stats.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Setting> createState() => _Setting();
}

class _Setting extends State<Setting> {
  int _currentIndex = 3; // Set the current index to 2 for Settings page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour
              .withOpacity(0.9), // Set the background color
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(title: 'Home Page'),
                ),
              );
            },
          ),
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
                  onPressed: () {
                    // Perform logout actions here, such as clearing authentication tokens.
                    // Navigate to the login screen or any other desired screen.
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) =>
                          false, // Clear all routes except the new login page.
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(initialIndex: _currentIndex));
  }
}
