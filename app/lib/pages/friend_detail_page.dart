import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/friend_model.dart'; // Ensure correct path
import '../utilities/constants.dart'; // Assuming this exists for theme data
import '../components/main_app_background.dart'; // Ensure correct path

class FriendDetailPage extends StatelessWidget {
  final FriendModel friend;

  const FriendDetailPage({super.key, required this.friend});

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
      throw 'Could not launch $url';
    }
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
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'User Details',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(
                        friend.imagePath.isNotEmpty
                            ? friend.imagePath
                            : '${dotenv.env['API_URL_BASE']}/media/images/default.jpeg',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${friend.name} ${friend.surname}',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '@${friend.username}',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    _buildDetailItem('Email:', friend.email),
                    _buildDetailItem('Date of Birth:', friend.dob),
                    _buildDetailItem('Phone:', friend.phoneNumber),
                    SizedBox(height: 32), // Space before the buttons
                    _buildSocialButton(
                      label: 'Add on Facebook',
                      icon: Icons.facebook,
                      color: Colors.blue[800],
                      onPressed: () {
                        final url =
                            'https://www.facebook.com/${friend.username}';
                        print('Attempting to launch $url');
                        _launchURL(url);
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSocialButton(
                      label: 'Add on Instagram',
                      icon: Icons.camera_alt,
                      color: Colors.purple,
                      onPressed: () {
                        final url =
                            'https://www.instagram.com/${friend.username}';
                        print('Attempting to launch $url');
                        _launchURL(url);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      {required String label,
      required IconData icon,
      required Color? color,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
