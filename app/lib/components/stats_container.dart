import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';

class StatContainerBox extends StatelessWidget {
  // custom constructor
  StatContainerBox({required this.valueToText, required this.fieldName});

  // use VoidCallback instead of Function

  final String valueToText; // it is nullable and optional
  final String fieldName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 110,
      color: kHomeBtnColoursOpaQue,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              valueToText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            fieldName,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// '$heartRate.0'
