import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/pages/settings.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/home_page_containers.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:analog_clock/analog_clock.dart';

class MyActivity extends StatefulWidget {
  const MyActivity({super.key, required this.title});
  final String title;
  @override
  MyActivityState createState() => MyActivityState();
}

class MyActivityState extends State<MyActivity> {
  final int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    // get current username
    UserDetails? userDetails =
        Provider.of<UserDataProvider>(context, listen: false).userDetails;
    String currentUsername = userDetails!.username;
    // TODO: get the current timezone to display correct tie in the analog clock -> line 121
    initializeDateFormatting('en_EN');
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM yyyy', 'en_EN').format(now);

    return CustomGradientContainerSoft(
        child: Scaffold(
      body: CustomGradientContainerSoft(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedGreyContainer(
                        width: 180,
                        height: 300,
                        children: [
                          Text("Hi,$currentUsername",
                              style: kSubSubTitleOfPage),
                          Text(
                            'Let\'s check your activity',
                            style: kSimpleTextWhite,
                          ),

                          //Image.asset('assets/image.png', width: 100, height: 100),
                          // Add more widgets as needed
                        ],
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // image
                            RoundedGreyContainer(
                                width: 140,
                                height: 140,
                                imagePath: userDetails.imagePath != null &&
                                        userDetails.imagePath.isNotEmpty
                                    ? '${dotenv.env['API_URL_BASE']}${userDetails.imagePath}'
                                    : '${dotenv.env['API_URL_BASE']}/media/images/default.jpeg',
                                defaultImagePath:
                                    '${dotenv.env['API_URL_BASE']}/media/images/default.jpeg',
                                children: [
                                  Text(
                                    'two',
                                    style: kSimpleTextWhite,
                                  )
                                ]),
                            SizedBox(
                              height: 10.0,
                            ),
                            // date + clock
                            RoundedGreyContainer(
                                width: 140,
                                height: 140,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: kSimpleTextWhite,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  SizedBox(
                                    width: 80, // Adjust width as needed
                                    height: 80, // Adjust height as needed
                                    child: AnalogClock(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2.0, color: Colors.black),
                                          color: kLoginRegisterBtnColour,
                                          shape: BoxShape.circle), // decoration
                                      width: 40.0,
                                      isLive: true,
                                      hourHandColor: Colors.white,
                                      minuteHandColor: Colors.white,
                                      showSecondHand: true,
                                      numberColor: Colors.white,
                                      showNumbers: true,
                                      textScaleFactor: 1.5,
                                      showTicks: true,
                                      showDigitalClock: true,
                                      digitalClockColor: Colors.white,
                                      datetime: DateTime.now(),
                                    ),
                                  ),
                                  // add the clock here!!
                                ]),
                          ]),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
