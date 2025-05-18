import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class RadioBtnChoice extends StatelessWidget {
  // custom constructor
  RadioBtnChoice(
      {required this.buttonText,
      required this.notificationValue,
      required this.radioValue,
      required this.changeState});

  // use VoidCallback instead of Function

  final String buttonText;
  final Object notificationValue; // optional
  final Function(Object?)? changeState;
  final Object radioValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        buttonText,
        style: kSimpleTextWhite, // Set text color
      ),
      leading: Radio(
        value: radioValue,
        groupValue: notificationValue,
        onChanged: changeState,
        activeColor: kLoginRegisterBtnColour,
        focusColor: kLoginRegisterBtnColour,
      ),
    );
  }
}
