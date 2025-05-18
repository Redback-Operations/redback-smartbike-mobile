import 'package:flutter/material.dart';
import 'package:phone_app/pages/my_activity.dart';
import 'package:phone_app/pages/my_workout.dart';
import 'package:phone_app/utilities/constants.dart';

import '../components/bottom_navigation_bar.dart';
import 'my_stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(title: "Home Page"),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, this.initialIndex = 0});
  final String title;
  final int initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      //initialIndex: 10,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
            automaticallyImplyLeading: false,
            flexibleSpace: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  tabs: [
                    Tab(
                      text: 'My Activity',
                    ),
                    Tab(
                      text: 'Workout',
                    ),
                    Tab(
                      text: 'Stats',
                    ),
                  ],
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              MyActivity(title: 'My Activity'),
              MyWorkout(title: ''),
              MyStats(title: 'My Stats')
            ],
          )),
    );
  }
}
