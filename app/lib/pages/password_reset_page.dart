import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/reset_password_session.dart';
import 'package:phone_app/pages/password_reset_otp_validate_page.dart';
import 'login.dart';
import 'signup.dart';
import '../components/login_signup_background.dart';
import '../components/bottom_button.dart';
import '../components/text_tap_button.dart';
import '../utilities/constants.dart';

class PasswordResetPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final cache = ResetPasswordSession(); // Access the singleton instance

  PasswordResetPage({super.key});

  Future<void> requestPasswordReset(BuildContext context) async {
    showLoader(context);

    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    final apiUrl = '$baseURL/user/password_reset/';
    const csrfToken = 'your-csrf-token';
    String email = emailController.text;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 200) {
      cache.email = email;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reset Email Sent'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Check your email to get the OTP to reset the password'),
                SizedBox(height: 10),
                Text('You will receive an email within the next couple of minutes. \n The OTP will be valid for 4 minutes Only.'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => PasswordResetOtpValidatePagePage())
                  );
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
            content: const Text('Failed to send reset email. Please try again later.'),
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
                  const Text(
                    "Reset Password",
                    style: kRedbackTextMain,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BottomButton(
                    onTap: () => requestPasswordReset(context),
                    buttonText: 'Send',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You will receive an email within the next couple of minutes.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
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
                          Navigator.push(
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
}
