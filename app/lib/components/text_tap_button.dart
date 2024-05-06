import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class TextTapButton extends StatelessWidget {
  // custom constructor
  TextTapButton(
      {required this.onTap,
      this.buttonTextStatic,
      required this.buttonTextActive});

  // use VoidCallback instead of Function
  final VoidCallback onTap;
  final String? buttonTextStatic; // it is nullable and optional
  final String buttonTextActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: RichText(
          text: TextSpan(
              text: buttonTextStatic,
              style: kSubTitleLoginStatic,
              children: <TextSpan>[
                TextSpan(text: buttonTextActive, style: kSubTitleLoginActive)
              ]),
        ),
      ),
    );
  }
}
