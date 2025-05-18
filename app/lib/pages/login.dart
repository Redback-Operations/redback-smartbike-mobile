import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:phone_app/components/input_text_field.dart';
import 'package:phone_app/pages/password_reset_page.dart';
import 'package:phone_app/pages/tab_layout.dart';
import 'package:phone_app/services/social_media_authentication.dart';
import 'package:provider/provider.dart';
import '../provider/user_data_provider.dart';
import '../utilities/http_interceptor.dart';
import 'home_page.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/components/text_tap_button.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:phone_app/pages/signup.dart';
import '../components/login_signup_background.dart';
import 'package:http/http.dart' as http;
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
      ],
      child: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController idController = TextEditingController();
  String errorMessage = '';
  late GoogleSignIn _googleSignIn;
  bool _isLoading = false; // Added to handle loading state

  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  @override
  void initState() {
    super.initState();

    _googleSignIn = GoogleSignIn(
      scopes: scopes,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    idController.dispose();
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    final apiUrl = '$baseURL/login/';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
        'id': idController.text,
      },
    );

    await handleLoginResponse(response);
    setState(() {
      _isLoading = false; // Stop loading after response is handled
    });
  }

  Future<void> handleLoginResponse(Response response) async {
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      // ID is generated in Django: models.py -> MyUser
      String id = responseData['id'].toString(); // Convert int to String here

      print('$responseData');
      // see Django views 'login_view' Response
      var accountDetails = responseData['account_details'][0];
      // save all to the Provider, so that we have all details for current user. Also Provider distributes data across the widgets
      Provider.of<UserDataProvider>(context, listen: false).updateUserDetails(
        context,
        email: accountDetails['email'],
        username: accountDetails['username'],
        name: accountDetails['name'],
        surname: accountDetails['surname'],
        dob: accountDetails['dob'],
        phoneNumber: accountDetails['phone_number'],
        imagePath: accountDetails['image'],
        id: id,
      );

      // broadcast those changes
      Provider.of<UserDataProvider>(context, listen: false).notifyListeners();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TabLayout()),
      );
    } else {
      String message;
      // All the responses should be in sync with the ones from Django views.py
      if (response.statusCode == 202) {
        message = 'Incorrect password. Please try again.';
      } else if (response.statusCode == 404) {
        message = 'Email not found. Please check your email.';
      } else if (response.statusCode == 203) {
        message = 'This username does not exist in the warehouse records.';
      } else {
        message =
        'An error occurred. Please try again later. Details: ${response.body} ${response.statusCode} ';
        print('${response.body} ${response.statusCode} ');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: CustomGradientContainerFull(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30.0),
                const Image(
                  image: AssetImage('lib/assets/redbacklogo.png'),
                  height: 150,
                ),
                const Text(
                  "Redback Smart Bike",
                  style: kRedbackTextMain,
                ),
                SizedBox(height: 70),
                InputTextField(
                  buttonText: 'email',
                  fieldController: emailController,
                ),
                SizedBox(height: 15),
                InputTextField(
                  buttonText: 'password',
                  fieldController: passwordController,
                  enableToggle: true,
                ),
                SizedBox(height: 15),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PasswordResetPage()),
                    );
                  },
                  child:
                  Text('Forgotten Password?', style: kSubTitleLoginStatic),
                ),
                _isLoading
                    ? CircularProgressIndicator() // Show loading indicator while processing
                    : BottomButton(
                  onTap: () {
                    login(context);
                  },
                  buttonText: 'Log In',
                ),
                SizedBox(height: 10),
                SocialLoginButton(
                  height: 50,
                  buttonType: SocialLoginButtonType.google,
                  onPressed: () async {
                    await _handleGoogleSignIn();
                    var response = await socialMediaLogin();
                    await handleLoginResponse(response);
                  },
                ),
                SizedBox(height: 10),
                SocialLoginButton(
                  height: 50,
                  buttonType: SocialLoginButtonType.facebook,
                  onPressed: () async {
                    await handleFacebookSignIn();
                    var response = await socialMediaLogin();
                    await handleLoginResponse(response);
                  },
                ),
                SizedBox(height: 25),
                TextTapButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
                  buttonTextStatic: 'Don\'t have an account?  ',
                  buttonTextActive: 'Sign up',
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signOut(); // Ensure previous session is cleared
      var account = await _googleSignIn.signIn();
      await SocialMediaAuthentication().handleGoogleSignIn(account);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> handleFacebookSignIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final account = await FacebookAuth.instance.getUserData();
        await SocialMediaAuthentication().handleFacebookSignIn(account);
      } else {
        print(result.status);
        print(result.message);
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<Response> socialMediaLogin() async {
    if (SocialMediaAuthentication.userData == null) {
      return Future(() => Response("message: 'User data Not Found!'", 400));
    }

    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE']; // only the partial, network specific to each team member
    final apiUrl = '$baseURL/login-sm/';

    final interceptor = MyHttpInterceptor(http.Client());

    final response = await interceptor.post(
      Uri.parse(apiUrl),
      {
        'email': SocialMediaAuthentication.userData?.email,
        'username': SocialMediaAuthentication.userData?.name,
        'login_id': SocialMediaAuthentication.userData?.id,
        'login_type': SocialMediaAuthentication.userData?.type.name,
        'user_created': DateTime.now().toIso8601String(), // record exact d&t
      },
    );

    print(response);
    return response;
  }
}
