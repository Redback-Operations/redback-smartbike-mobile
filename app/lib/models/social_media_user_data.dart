import 'package:phone_app/services/social_media_authentication.dart';

class SocialMediaUserData {
  String id;
  String name;
  String email;
  String imagePath;
  String password;
  SocialMediaType type;

  SocialMediaUserData({
    required this.id,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.password,
    required this.type,
  });
}