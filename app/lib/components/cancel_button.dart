import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class CancelButton extends StatelessWidget {
  // custom constructor
  const CancelButton(
      {super.key, required this.onTap, required this.buttonText, this.width});

  // use VoidCallback instead of Function
  final VoidCallback onTap;
  final String buttonText;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 10.0, bottom: 40),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        width: width ?? 180, // 180 by default if not provided
        height: kBottomContainerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: kLoginRegisterBtnColour, width: 3.0),
          color: kLoginRegisterBtnColour.withOpacity(0.4),
        ),
        child: Text(
          buttonText,
          style: kBottomButtonText,
        ),
      ),
    );
  }
}
