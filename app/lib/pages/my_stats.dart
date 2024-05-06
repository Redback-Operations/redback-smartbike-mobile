import 'package:flutter/material.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/pages/settings.dart';
import 'package:phone_app/utilities/constants.dart';

import '../components/bottom_navigation_bar.dart';
import 'Friends.dart';
import 'home_page.dart';

class MyStats extends StatefulWidget {
  const MyStats({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyStatsState createState() => _MyStatsState();
}

class _MyStatsState extends State<MyStats> {
  int _currentIndex = 3;
  @override
  Widget build(BuildContext context) {
    return CustomGradientContainerSoft(
        child: Scaffold(
      body: CustomGradientContainerSoft(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                child: Row(
                  children: [
                    Text("My Stats", style: kSubSubTitleOfPage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
