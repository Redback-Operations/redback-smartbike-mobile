import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/friend_model.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/main_app_background.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import '../utilities/constants.dart';
import 'friend_detail_page.dart';
import 'home_page.dart';

class MyFriendScreen extends StatefulWidget {
  const MyFriendScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyFriendScreen> createState() => _MyFriendScreenState();
}

class _MyFriendScreenState extends State<MyFriendScreen> {
  List<FriendModel> allFriends = [];
  List<FriendModel> filteredFriends = [];
  TextEditingController _searchController = TextEditingController();

  // fetch all friends first
  Future<void> fetchFriends() async {
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];

    if (baseURL != null) {
      String apiUrl = '$baseURL/users/';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          // get username of current user from Provider; we don't want to include ourselves in the list
          UserDetails? userDetails =
              Provider.of<UserDataProvider>(context, listen: false).userDetails;
          String currentUsername = userDetails!.username;

          allFriends = (json.decode(response.body) as List)
              .map((data) => FriendModel.fromJson(data, baseURL))
              .where((friend) =>
                  friend.username != currentUsername) // Filter out yourself
              .toList();
          filteredFriends = allFriends; // Initialize with all friends
        });
      } else {
        throw Exception('Failed to load friends: ${response.statusCode}');
      }
    } else {
      print('BASE_URL is not defined in .env file');
    }
  }

  // then react to every key that the user inputs or deletes in the search bar
  void filterFriends(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredFriends =
            allFriends; // Reset to all friends when search is cleared
      });
    } else {
      setState(() {
        filteredFriends = allFriends
            .where((friend) => (friend.name + ' ' + friend.surname)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFriends();
    // listener for the search controller, instead of onChanged; it listens to every character input
    _searchController.addListener(() {
      filterFriends(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        title: Text(
          'My Friends',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Friends',
                  hintText: 'Type a name or surname',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: kLoginRegisterBtnColour.withOpacity(0.9)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: friend.imagePath.isNotEmpty
                          ? NetworkImage(friend.imagePath)
                          : AssetImage('assets/profile_default.png')
                              as ImageProvider,
                    ),
                    title: Text('${friend.name} ${friend.surname}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FriendDetailPage(friend: friend),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
