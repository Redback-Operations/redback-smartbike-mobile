import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class AccountContainer extends StatelessWidget {
  // custom constructor
  AccountContainer({
    required this.fieldName,
    required this.typeIcon,
    required this.onPressed,
    required this.arrowOptional,
  });

  // use VoidCallback instead of Function

  final IconData typeIcon;
  final IconData? arrowOptional;
  final String fieldName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kHomeBtnColoursOpaQue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  typeIcon,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  fieldName,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            Icon(
              arrowOptional,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
