import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/main_app_background.dart';
import '../models/user_details.dart';
import '../utilities/constants.dart';
import 'home_page.dart';
import 'my_stats.dart';
import 'settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyFriendScreen extends StatefulWidget {
  const MyFriendScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyFriendScreen> createState() => _MyFriendScreenState();
}

// TODO: for this you need to be able to browse all names except for yours from backend acc_details table
// TODO: you also need to construct a new table in backend to store the usernames and emails for current user's friends and your email for reference
// TODO: then when you send a GET request and other, you can filter that table with current_user's email (from flutter provider) and get the list of friends

class Friend {
  final String name;
  final String mutualFriends;

  Friend({
    required this.name,
    required this.mutualFriends,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['name'],
      mutualFriends: "2",
    );
  }
}

class _MyFriendScreenState extends State<MyFriendScreen> {
  int _currentIndex = 2;
  List<Friend> friends = [];
  int number_friends = 6;
  String _sortByValue = "Ascending";

  Future<void> fetchFriends() async {
    // Load the .env file
    await dotenv.load(fileName: ".env");

    // Retrieve the base URL from the environment variables
    String? baseURL = dotenv.env['API_URL_BASE'];

    // Check if the base URL is defined
    if (baseURL != null) {
      try {
        // Construct the complete URL by concatenating with the endpoint
        String apiUrl = '$baseURL/api/data';

        // Send the GET request
        final response = await http.get(Uri.parse(apiUrl));

        // Handle the response
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          final List<dynamic> friendsData = data['friends'];

          final List<Friend> parsedFriends = friendsData.map((friendData) {
            return Friend.fromJson(friendData);
          }).toList();

          setState(() {
            friends = parsedFriends;
          });
          print(friends);
        } else {
          // Handle HTTP error responses
          throw Exception('Failed to load friends: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network errors
        print('Error: $e');
      }
    } else {
      // Print a message if BASE_URL is not defined in .env
      print('BASE_URL is not defined in .env file');
    }
  }

  @override
  void initState() {
    super.initState();
    //fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour
              .withOpacity(0.9), // Set the background color
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    title: 'Home Page',
                  ),
                ),
              );
            },
          ),
          title: Text(
            'My Friends',
            style: kSubSubTitleOfPage,
          ),
          centerTitle: true,
        ),
        body: CustomGradientContainerSoft(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                  child: Row(
                    children: [
                      Text("Total Friends: ${friends.length}",
                          style: kSubSubTitleOfPage),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              // Set the fill color here
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              elevation: 10,
                              iconSize: 30.0,
                              iconDisabledColor:
                                  kLoginRegisterBtnColour.withOpacity(0.5),
                              iconEnabledColor: kLoginRegisterBtnColour,
                              value: _sortByValue,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sortByValue = newValue!;
                                });
                              },
                              dropdownColor: Color.fromRGBO(110, 45, 81, 0.8),
                              items: ['Ascending', 'Recently Met']
                                  .map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: kSimpleTextWhite, // Set text color
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: friends.map((friend) {
                    return TransparentProfileButton(
                      name: friend.name,
                      mutualFriends: friend.mutualFriends,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(initialIndex: _currentIndex));
  }
}

class TransparentProfileButton extends StatelessWidget {
  final String name;
  final String mutualFriends;

  TransparentProfileButton({
    required this.name,
    required this.mutualFriends,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.94,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3), // Transparent white
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/profile_image.jpg'),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  mutualFriends,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text("Unfriend"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
