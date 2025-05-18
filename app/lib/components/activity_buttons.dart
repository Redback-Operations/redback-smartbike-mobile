import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class ActivityButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final double? width;

  const ActivityButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 10.0),
        width: width ?? 180,
        height: kBottomContainerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.0),
          color: kHomeBtnColoursOpaQue,
        ),
        child: InkWell(
          onTap: () async {
            await Future.delayed(Duration(seconds: 1));
            onTap();
          },
          borderRadius: BorderRadius.circular(40.0),
          splashColor: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 85, vertical: 16),
            child: Text(
              buttonText,
              style: kBottomButtonText,
            ),
          ),
        ),
      ),
    );
  }
}
