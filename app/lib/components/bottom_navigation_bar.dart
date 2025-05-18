import 'package:flutter/material.dart';
import 'package:phone_app/pages/message_center.dart';
import 'package:phone_app/utilities/constants.dart';
import '../pages/Friends.dart';
import '../pages/home_page.dart';
import '../pages/my_stats.dart';
import '../pages/settings.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  BottomNavBar({required this.initialIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      //backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          switch (_currentIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(title: "Home Page"),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageCenter(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyFriendScreen(title: ''),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Setting(title: "Settings"),
                ),
              );
              break;
          }
        });
      },
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
    );
  }
}
