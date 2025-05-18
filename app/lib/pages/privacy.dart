import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

import '../components/bottom_button.dart';
import '../components/main_app_background.dart';
import '../components/radio_btn_privacy.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  PrivacyState createState() => PrivacyState();
}

class PrivacyState extends State<Privacy> {
  String _selectedVisibility = 'Public';
  int _notificationSetting =
      0; // 0 for none, 1 for Disable All, 2 for Disable Follow, 3 for Disable Comment

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
        title: Text(
          'Privacy',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60),
                  Row(
                    children: [
                      Text(
                        'Select Visibility:',
                        style: kSubSubTitleOfPage, // Set text color
                      ),
                      SizedBox(
                          width:
                              50), // Add some space between the text and the dropdown button
                      Container(
                        decoration: BoxDecoration(
                          // Set the fill color here
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          elevation: 10,
                          iconSize: 50.0,
                          iconDisabledColor:
                              kLoginRegisterBtnColour.withOpacity(0.5),
                          iconEnabledColor: kLoginRegisterBtnColour,
                          value: _selectedVisibility,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedVisibility = newValue!;
                            });
                          },
                          dropdownColor: Color.fromRGBO(110, 45, 81, 0.8),
                          items: ['Public', 'Private']
                              .map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: kSimpleTextWhite, // Set text color
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Notification Settings:',
                      style: kSubSubTitleOfPage, // Set text color
                    ),
                  ),
                  RadioBtnChoice(
                    buttonText: 'Disable All Notification',
                    notificationValue: _notificationSetting,
                    radioValue: 1,
                    changeState: (radioValue) {
                      setState(() {
                        _notificationSetting = radioValue as int;
                      });
                    },
                  ),
                  RadioBtnChoice(
                    buttonText: 'Disable Follow Notification',
                    notificationValue: _notificationSetting,
                    radioValue: 2,
                    changeState: (radioValue) {
                      setState(() {
                        _notificationSetting = radioValue as int;
                      });
                    },
                  ),
                  RadioBtnChoice(
                    buttonText: 'Disable Comment Notification',
                    notificationValue: _notificationSetting,
                    radioValue: 3,
                    changeState: (radioValue) {
                      setState(() {
                        _notificationSetting = radioValue as int;
                      });
                    },
                  ),
                  SizedBox(height: 70),
                  BottomButton(
                      onTap: () {
                        //TODO: save the changes in backend logic
                      },
                      buttonText: 'Save'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
