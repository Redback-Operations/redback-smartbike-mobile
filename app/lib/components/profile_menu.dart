import 'package:flutter/material.dart';

import '../utilities/constants.dart';

class MenuRow extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onPressed;
  const MenuRow(
      {super.key,
      required this.title,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 25,
              height: 25,
              fit: BoxFit.fitWidth,
              color: kLoginRegisterBtnColour,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Icon(
              Icons.navigate_next_outlined,
              color: Colors.white70,
              size: 25,
            )
          ],
        ),
      ),
    );
  }
}
