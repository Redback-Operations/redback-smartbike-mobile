import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/components/input_text_field.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/pages/settings.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/account_containers.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/dropdown_choice.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'home_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => Setting(
                          title: 'Settings',
                        )),
                (route) => false, // Clear all routes except the new login page.
              );
            },
          ),
          title: Text(
            'My past workouts',
            style: kSubSubTitleOfPage,
          ),
          centerTitle: true,
        ),
        body: CustomGradientContainerSoft(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AccountContainer(
                    fieldName: 'clean1',
                    typeIcon: Icons.gradient,
                    onPressed: () {
                      // do stuff
                    },
                    arrowOptional: Icons.arrow_forward,
                  ),
                  AccountContainer(
                    fieldName: 'analyze1',
                    typeIcon: Icons.gradient,
                    onPressed: () {
                      // do stuff
                    },
                    arrowOptional: Icons.arrow_forward,
                  ),
                  AccountContainer(
                    fieldName: 'analyze2',
                    typeIcon: Icons.gradient,
                    onPressed: () {
                      // do stuff
                    },
                    arrowOptional: Icons.arrow_forward,
                  ),
                  AccountContainer(
                    fieldName: 'analyze3',
                    typeIcon: Icons.gradient,
                    onPressed: () {
                      // do stuff
                    },
                    arrowOptional: Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
