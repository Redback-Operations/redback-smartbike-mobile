import 'package:flutter/material.dart';

import '../utilities/constants.dart';

class PasswordToggle extends StatefulWidget {
  final Function(bool) onToggle;

  const PasswordToggle({required this.onToggle});

  @override
  _PasswordToggleState createState() => _PasswordToggleState();
}

class _PasswordToggleState extends State<PasswordToggle> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _obscureText = !_obscureText;
          widget.onToggle(_obscureText); // Call the callback with the new value
        });
      },
      child: Icon(
        _obscureText ? Icons.visibility : Icons.visibility_off,
        color: kLoginRegisterBtnColour,
      ),
    );
  }
}
