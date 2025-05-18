import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:phone_app/models/social_media_user_data.dart';

class SocialMediaAuthentication {
  static final SocialMediaAuthentication _socialMediaAuthentication =
      SocialMediaAuthentication._internal();

  factory SocialMediaAuthentication() {
    return _socialMediaAuthentication;
  }

  SocialMediaAuthentication._internal();

  static SocialMediaUserData? userData;

  Future<void> handleGoogleSignIn(GoogleSignInAccount? account) async {
    try {
      if (account != null) {
        userData = SocialMediaUserData(
            id: account.id ?? "",
            name: account.displayName ?? "",
            email: account.email,
            imagePath: account.photoUrl ?? "",
            type: SocialMediaType.google,
            password: "");
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

    }
  }

  Future<void> handleFacebookSignIn(Map<String, dynamic>? account) async {
    try {
      if (account != null) {
        userData = SocialMediaUserData(
            id: account["id"] ?? "",
            name: account["name"] ?? "",
            email: account["email"],
            imagePath: account["picture"]["data"]["url"] ?? "",
            type: SocialMediaType.facebook,
            password: "");
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<SocialMediaType> isSocialMediaLoggedIn() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      return SocialMediaType.facebook;
    }

    if (userData?.type == SocialMediaType.google) {
      return SocialMediaType.google;
    }

    return SocialMediaType.none;
  }

  Future<SocialMediaUserData?> getSocialMediaUser() async {
    return userData;
  }

  Future<Response> socialMediaLogin() async {
    if (userData == null) {
      return Future(() => Response("message: 'User data Not Found!'", 400));
    }

    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env[
        'API_URL_BASE']; // only the partial, network specific to each team member
    final apiUrl = '$baseURL/login-sm/';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': userData?.email,
        'username': userData?.name,
        'login_id': userData?.id,
        'image': userData?.imagePath,
        'login_type': userData?.type,
        'user_created': DateTime.now().toIso8601String(), // record exact d&t
      },
    );
    return response;
  }
}

enum SocialMediaType { facebook, google, none }
