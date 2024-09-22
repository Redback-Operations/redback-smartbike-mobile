import 'package:flutter/material.dart';

class CustomGradientContainerFull extends StatelessWidget {
  final Widget child;

  const CustomGradientContainerFull({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6E2D51),
            Color(0xFFE97462),
            Color.fromRGBO(55, 14, 74, 0.94), // Color(0xFF370E4A)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
