import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:phone_app/pages/password_reset_create_new_password_page.dart';

import '../components/bottom_button.dart';
import '../components/login_signup_background.dart';
import '../components/reset_password_session.dart';
import '../components/text_tap_button.dart';
import '../utilities/constants.dart';
import 'login.dart';
import 'signup.dart';

class PasswordResetOtpValidatePagePage extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final cache = ResetPasswordSession(); // Access the singleton instance

  PasswordResetOtpValidatePagePage({super.key});

  Future<void> validateOTP(BuildContext context) async {
    showLoader(context);
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    final apiUrl = '$baseURL/user/password_reset/otp_validate';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otp': otpController.text,
        'email': cache.email,
      }),
    );

    Navigator.pop(context);

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      cache.otpToken = responseData['otp_token'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordResetCreateNewPasswordPage(),
        ),
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

  Future<void> requestPasswordReset(BuildContext context) async {
    showLoader(context);
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    final apiUrl = '$baseURL/user/password_reset/';
    const csrfToken = 'your-csrf-token';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: jsonEncode({
        'email': cache.email,
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reset Email Sent'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Check your email to reset your password.'),
                SizedBox(height: 10),
                Text(
                    'You will receive an email within the next couple of minutes.'),
              ],
            ),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to send reset email. Please try again later.'),
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
                  const Text(
                    "Validate OTP",
                    style: kRedbackTextMain,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter the OTP from Your Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BottomButton(
                    onTap: () => validateOTP(context),
                    buttonText: 'Validate',
                  ),
                  const SizedBox(height: 20),
                  TextTapButton(
                      onTap: () => requestPasswordReset(context),
                      buttonTextStatic: "Didn't receive the OTP? ",
                      buttonTextActive: 'Resend OTP'),
                  const Spacer(),
                  TextTapButton(
                      onTap: () => {
                            cache.clearCache(),
                            Navigator.pop(context)
                          },
                      buttonTextStatic: "Change the ",
                      buttonTextActive: 'Email'),
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
