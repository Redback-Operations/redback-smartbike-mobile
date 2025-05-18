import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/pages/signup.dart';
import 'package:provider/provider.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:phone_app/components/bottom_navigation_bar.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/provider/user_data_provider.dart';
import 'package:phone_app/models/user_details.dart';
import '../components/bottom_button.dart';
import '../components/dropdown_choice.dart';
import '../components/input_text_field.dart'; // Ensure you have UserDetails class correctly set up
import 'dart:convert';

class Terminate extends StatefulWidget {
  const Terminate({super.key});

  @override
  TerminateState createState() => TerminateState();
}

class TerminateState extends State<Terminate> {
  final int _currentIndex = 1;
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedReason;
  final TextEditingController _additionalReasonController =
      TextEditingController();
  final List<String> _reasons = [
    // those need to match the options in views in Django
    'Poor Service',
    'Found a Better Service',
    'Privacy Concerns',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserDataProvider>(context).userDetails?.id ??
        "No ID Provided";

    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Terminate Account',
            style: kSubSubTitleOfPage,
          ),
          centerTitle: true,
        ),
        body: CustomGradientContainerSoft(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 80),
                DropdownChoice(
                  onChange: (String? newValue) {
                    setState(() {
                      _selectedReason = newValue!;
                    });
                  },
                  items: _reasons
                      .map((reason) => DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason, style: kSimpleTextPurple),
                          ))
                      .toList(),
                  selectedValue: _selectedReason,
                  helperText: 'Reason for Termination',
                ),
                SizedBox(height: 20),
                InputTextField(
                  buttonText: 'Additional Details',
                  fieldController: _additionalReasonController,
                  height: 200,
                ),
                SizedBox(height: 50),
                BottomButton(
                  onTap: _showConfirmDialog,
                  buttonText: 'Terminate',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Termination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Please enter your password to confirm termination:'),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _terminateAccount(_passwordController.text);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _terminateAccount(String password) async {
    // get network details from .env file
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];

    // Fetch user ID from UserDataProvider - UPDATED to find ID instead of email
    final userId =
        Provider.of<UserDataProvider>(context, listen: false).userDetails?.id ??
            "Cannot fetch the user details";
    print(userId);
    if (userId == "Cannot fetch the user details") {
      print("User detail is not provided. Cannot terminate account.");
      return; // Exit the function if no user ID is provided
    }
    final enteredPassword = _passwordController.text;
    print('pass: $password');

    final apiUrl =
        '$baseURL/user/authenticate/'; // Correct endpoint to terminate - UPDATED TO USE BODY INSTEAD OF URL

    // 1. check the password against database
    final authResponse = await http.post(
      Uri.parse(apiUrl),
      body: {
        'userId': userId,
        'password': _passwordController.text,
        'user_created': DateTime.now().toIso8601String(),
      },
    );

    // 2. if password matches save the contents of the terminate page fields
    if (authResponse.statusCode == 200) {
      // 200 OK should match the backend views
      final messageUrl = '$baseURL/save_ta_message/';
      final messageResponse = await http.post(
        Uri.parse(messageUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reason': _selectedReason,
          'message_body': _additionalReasonController.text,
          'submitted_at': DateTime.now().toIso8601String(),
          'reviewed': false,
        }),
      );

      // 3. after the msg is saved (received status 201), delete the account: - UPDATED to target ID instead of email
      if (messageResponse.statusCode == 201) {
        final deleteUrl = '$baseURL/user/delete/$userId/';
        final deleteResponse = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            'Content-Type': 'application/json',
            //'Authorization': 'Bearer ${_passwordController.text}', // Use proper authorization
          },
        );

        // 4. if we deleted successfully, we should get 204
        if (deleteResponse.statusCode == 204) {
          // Assuming 204 No Content for successful deletion
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpPage(),
            ),
          );
          _showSuccessPopup();
        } else {
          _showErrorPopup(
              "Failed to terminate account: Incorrect password. Cannot delete account. Please try again.");
        }
      } else {
        _showErrorPopup("Failed to save message. Please try again.");
      }
    } else if (authResponse.statusCode == 403) {
      // Forbidden or Unauthorized
      _showErrorPopup(
          "Incorrect password. Cannot delete account. Please try again.");
    } else {
      _showErrorPopup(
          "Failed to authenticate password. Please try again later.");
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your account has been successfully deleted.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
