import 'package:flutter/material.dart';
import '../utilities/constants.dart';

class IconTextButton extends StatelessWidget {
  final String title;
  final String subTitle;
  final String icon;
  final VoidCallback onPressed;
  const IconTextButton(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 25,
            height: 25,
            color: kLoginRegisterBtnColour,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            subTitle,
            style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }
}
