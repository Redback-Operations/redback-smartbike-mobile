import 'package:flutter/material.dart';
import 'package:phone_app/pages/settings.dart';

import '../utilities/constants.dart';
import 'Friends.dart';
import 'home_page.dart';
import 'message_center.dart';

class TabLayout extends StatefulWidget {
  const TabLayout({super.key});

  @override
  TabLayoutState createState() => TabLayoutState();
}

class TabLayoutState extends State<TabLayout> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          const HomePage(title: "Home Page"),
          MessageCenter(),
          const MyFriendScreen(title: ''),
          const Setting(title: "Settings")
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: 'Messages',
            backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
            backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          ),
        ],
      ),
    );
  }
}