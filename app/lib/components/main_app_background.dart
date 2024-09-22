import 'package:flutter/material.dart';

class CustomGradientContainerSoft extends StatelessWidget {
  final Widget child;

  const CustomGradientContainerSoft({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(110, 45, 81, 0.6), // 50% opacity
            Color.fromRGBO(233, 116, 98, 0.9), // 50% opacity
            Color.fromRGBO(55, 14, 74, 0.6), // 47% opacity
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
