import 'package:flutter/material.dart';

class CustomGradientContainerFull extends StatelessWidget {
  final Widget child;

  const CustomGradientContainerFull({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6E2D51),
            const Color(0xFFE97462),
            Theme.of(context).primaryColor.withOpacity(0.94),
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
