import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/components/input_text_field.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/dropdown_choice.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'home_page.dart';

class WorkoutSummary extends StatefulWidget {
  @override
  _WorkoutSummaryState createState() => _WorkoutSummaryState();
}

class _WorkoutSummaryState extends State<WorkoutSummary> {
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
      ),
      body: Stack(
        children: [
          CustomGradientContainerSoft(
            child: Container(), // Empty container to fill the background
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 100, // Adjust this height as needed
                    color: kLoginRegisterBtnColour.withOpacity(0.2),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'some summary here',
                      style: kSubTitleOfPage,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 150, // Adjust this height as needed
                    color: kLoginRegisterBtnColour.withOpacity(0.2),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'some more stats',
                      style: kSubTitleOfPage,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          // Adjust this height as needed
                          color: kLoginRegisterBtnColour.withOpacity(0.2),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'other',
                            style: kSubTitleOfPage,
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              10), // Add SizedBox for spacing between containers
                      Expanded(
                        child: Container(
                          height: 70,
                          // Adjust this height as needed
                          color: kLoginRegisterBtnColour.withOpacity(0.2),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'other',
                            style: kSubTitleOfPage,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                      height:
                          30), // Add some spacing between the colored container and the input fields

                  SizedBox(height: 10),

                  SizedBox(height: 10),

                  SizedBox(height: 10),

                  SizedBox(
                    height: 20,
                  ),
                  BottomButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(title: 'Home Page'),
                          ),
                        );
                      },
                      buttonText: 'Back to Home Page'),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
