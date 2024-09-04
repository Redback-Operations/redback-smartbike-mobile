import 'package:flutter/material.dart';
import 'package:phone_app/pages/settings.dart';
import 'package:phone_app/pages/terminate_account.dart';
import '../components/account_containers.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/main_app_background.dart';
import 'Friends.dart';
import 'home_page.dart';
import 'about_us.dart';
import 'contact.dart';
import 'email.dart';
import 'login.dart';
import 'my_stats.dart';
import 'privacy.dart';
import 'my_profile.dart';
import '../utilities/constants.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key, required this.title});
  final String title;

  @override
  State<MyAccount> createState() => _MyAccount();
}

class _MyAccount extends State<MyAccount> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: CustomGradientContainerSoft(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                AccountContainer(
                  fieldName: 'Profile',
                  typeIcon: Icons.account_circle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileActivity(),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                const SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Privacy',
                  typeIcon: Icons.privacy_tip,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Privacy(),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                const SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Email Address',
                  typeIcon: Icons.email,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailScreen(),
                      ),
                    );
                  },
                  arrowOptional: Icons.arrow_forward,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                AccountContainer(
                  fieldName: 'Contact Us',
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
                const SizedBox(height: 10),
                AccountContainer(
                  fieldName: "TERMINATE ACCOUNT",
                  typeIcon: Icons.cancel,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Terminate(),
                      ),
                    );
                  },
                  arrowOptional: null,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ));
  }
}
