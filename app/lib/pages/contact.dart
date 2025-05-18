import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/components/input_text_field.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/dropdown_choice.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String _subject = '';
  String _message = '';
  String? selectedValue;
  final _dropdownFormKey = GlobalKey<FormState>();

  // each thread of help messages will have the same UUID number, so that they can be easily
  // fetched for Admin, and turned their status to 'resolved' when case is closed
  late String _threadNumber;

  // list of topics for help
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(
        value: 'General Inquiry',
        child: Text(
          'General Inquiry',
          style: kSimpleTextPurple,
        ),
      ),
      DropdownMenuItem(
          value: 'Technical Support',
          child: Text(
            'Technical Support',
            style: kSimpleTextPurple,
          )),
      DropdownMenuItem(
          value: 'Billing Issue',
          child: Text(
            'Billing Issue',
            style: kSimpleTextPurple,
          )),
      DropdownMenuItem(
          value: 'Other',
          child: Text(
            'Other',
            style: kSimpleTextPurple,
          )),
    ];
    return menuItems;
  }

  // validate fields
  bool validateFields() {
    List<String> errorMessages = [];
    // separate error msg for each field so that the user would know what to amend
    if (_subject.isEmpty) {
      errorMessages.add('Please provide a subject.');
    }
    if (_message.isEmpty) {
      errorMessages.add('Please write a message.');
    }
    if (selectedValue == null) {
      errorMessages.add('Please choose a topic.');
    }
    // if any errors are present, combine the final error msg
    if (errorMessages.isNotEmpty) {
      String errorMessage = errorMessages.join('\n');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Missing Information'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return false; // Validation failed
    }
    return true; // Validation passed
  }

  @override
  void initState() {
    super.initState();
    _threadNumber = generateUniqueId();
  }

  String generateUniqueId() {
    var uuid = Uuid();
    return uuid.v4();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Contact Us',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                  child: Center(
                    child: Text("Fill out the form to get in contact",
                        style: kSimpleTextWhite),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Form(
                    key: _dropdownFormKey,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: InputTextField(
                        buttonText: 'Subject',
                        onChangedDo: (value) {
                          setState(() {
                            _subject = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: DropdownChoice(
                    onChange: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: dropdownItems,
                    selectedValue: selectedValue,
                    helperText: 'Choose topic',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Container(
                    child: InputTextField(
                      buttonText: 'Message',
                      height: 200,
                      onChangedDo: (value) {
                        setState(() {
                          _message = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50),
                BottomButton(
                  onTap: () {
                    if (validateFields()) {
                      sendContactUsForm();
                      Navigator.of(context).pop();
                    }
                  },
                  buttonText: 'Send',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Send a POST request to Django
  void sendContactUsForm() async {
    // get current user data (we need email)
    UserDetails? userDetails =
        Provider.of<UserDataProvider>(context, listen: false).userDetails;
    if (userDetails == null) {
      // TODO: Handle error or show message that user details are not available
      print("User ID is not provided. Cannot proceed.");
      return;
    }

    // retrieve the base URL from the environment variables
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];

    if (baseURL != null) {
      String apiUrl = '$baseURL/messages/';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          // the rest of the values from Django model are either nullable or have default values set;
          // UUID generated in Flutter; each thread of messages (case)should have one, same UUID
          'thread_number': _threadNumber,
          'email': userDetails.email,
          'subject': _subject,
          'topic': selectedValue,
          'message_body': _message,
          'timestamp_sent': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (mounted) {
        // make sure we send the msg first, then dispose of widget
        if (response.statusCode == 201) {
          print('Message sent successfully');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Message Sent'),
              content: Text('Message sent successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          print('Error sending message');
        }
      }
    } else {
      print('BASE_URL is not defined in .env file');
    }
  }
}
