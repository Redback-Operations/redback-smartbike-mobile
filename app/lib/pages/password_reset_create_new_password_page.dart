import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../components/bottom_button.dart';
import '../components/input_text_field.dart';
import '../components/login_signup_background.dart';
import '../components/reset_password_session.dart';
import '../components/text_tap_button.dart';
import '../utilities/constants.dart';
import 'login.dart';
import 'signup.dart';

class PasswordResetCreateNewPasswordPage extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  final cache = ResetPasswordSession();

  PasswordResetCreateNewPasswordPage({super.key});

  Future<void> submitPassword(BuildContext context) async {
    showLoader(context);
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    final apiUrl = '$baseURL/user/password_reset/new_password';
    const csrfToken = 'your-csrf-token';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: jsonEncode({
        'email': cache.email,
        'otp_token': cache.otpToken,
        'password': passwordController.text,
        're_password': rePasswordController.text,
      }),
    );

    Navigator.pop(context);

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Password updated Successfully!'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please login with your new password')
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(responseData['error']),
            actions: <Widget>[
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
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  const Image(
                    image: AssetImage('lib/assets/redbacklogo.png'),
                    height: 150,
                  ),
                  const SizedBox(height: 30),
                  InputTextField(
                    buttonText: 'New Password',
                    fieldController: passwordController,
                    enableToggle: true,
                  ),
                  SizedBox(height: 15),
                  InputTextField(
                    buttonText: 'Re-Enter New Password',
                    fieldController: rePasswordController,
                    enableToggle: true,
                  ),
                  const SizedBox(height: 20),
                  BottomButton(
                    width: 250,
                    onTap: () => submitPassword(context),
                    buttonText: 'Submit Password',
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextTapButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        buttonTextStatic: 'Back to ',
                        buttonTextActive: 'Login',
                      ),
                      const SizedBox(width: 10),
                      TextTapButton(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        buttonTextStatic: ' or ',
                        buttonTextActive: 'Sign Up',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }

}
