import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class ActivityButton extends StatelessWidget {
  // custom constructor
  ActivityButton({required this.onTap, required this.buttonText, this.width});

  // use VoidCallback instead of Function
  final VoidCallback onTap;
  final String buttonText;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10.0),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          width: width ?? 180, // 180 by default if not provided
          height: kBottomContainerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: Theme.of(context).primaryColor.withOpacity(0.4), // Adjust border radius as needed
          ),
          child: Text(
            buttonText,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}
