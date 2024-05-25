import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_app/pages/login.dart';
import 'package:phone_app/pages/message_center.dart';
import 'package:phone_app/pages/my_activity.dart';
import 'package:phone_app/pages/my_workout.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../components/bottom_navigation_bar.dart';
import '../components/main_app_background.dart';
import '../components/stats_container.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import 'Friends.dart';
import 'my_workout.dart';
import 'package:phone_app/pages/settings.dart';
import 'my_account.dart';
import '../models/user_details.dart';
import '../services/get_current_user_details.dart';
import 'my_stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(title: "Home Page"),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title, this.initialIndex = 0})
      : super(key: key);
  final String title;
  final int initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
          body: TabBarView(
            children: [
              MyActivity(title: 'My Activity'),
              MyWorkout(
                title: '',
              ),
              MyStats(title: 'My Stats')
            ],
          ),
          bottomNavigationBar: BottomNavBar(initialIndex: _currentIndex)),
    );
  }
}
