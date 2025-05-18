import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/pages/pilates_workout.dart';
import 'package:phone_app/pages/running_workout.dart';
import 'package:phone_app/pages/vr_workout.dart';
import 'package:phone_app/pages/yoga_workout.dart';
import 'package:phone_app/utilities/constants.dart';
import '../components/dropdown_choice.dart';
import '../components/main_app_background.dart';
import 'package:provider/provider.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import '../provider/wrk_type_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'cycling_workout.dart';

class SetWorkout6 extends StatefulWidget {
  const SetWorkout6({super.key, required this.title});
  final String title;

  @override
  State<SetWorkout6> createState() => _SetWorkoutState();
}

class _SetWorkoutState extends State<SetWorkout6> {
  final int _currentIndex = 0;
  late String wrkName;
  int? selectedDuration; // duration
  String? selectedIntensity; // intensity
  String? selectedType;

  // validate fields
  bool validateFields() {
    List<String> errorMessages = [];
    // separate error msg for each field so that the user would know what to amend
    if (selectedDuration == null) {
      errorMessages.add('Please select workout duration');
    }
    if (selectedIntensity == null) {
      errorMessages.add('Please select workout intensity');
    }
    if (selectedType == null) {
      errorMessages.add('Please select workout type');
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
  }

  @override
  Widget build(BuildContext context) {
    // get the current workout name
    wrkName = Provider.of<WorkoutTypeProvider>(context).workoutType?.name ?? '';
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
          wrkName,
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomGradientContainerSoft(
            child: Container(), // Empty container to fill the background
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 200, // Adjust this height as needed
                    color: kLoginRegisterBtnColour.withOpacity(0.2),
                    padding: EdgeInsets.all(10),
                    child: Image.asset(
                      'lib/assets/img/aerobic.jpg', // Replace 'your_image_asset.png' with your actual asset path
                      fit: BoxFit.cover, // Adjust the fit property as needed
                    ),
                  ),
                  SizedBox(
                      height:
                          80), // Add some spacing between the colored container and the input fields

                  DropdownChoice(
                    onChange: (int? newValue) {
                      setState(() {
                        selectedDuration = newValue!;
                      });
                    },
                    items: dropdownItemsDuration,
                    selectedValue: selectedDuration,
                    helperText: 'Duration',
                  ),
                  SizedBox(height: 10),
                  DropdownChoice(
                    onChange: (String? newValue) {
                      setState(() {
                        selectedIntensity = newValue!;
                      });
                    },
                    items: dropdownItemsIntensity,
                    selectedValue: selectedIntensity,
                    helperText: 'Intensity',
                  ),
                  SizedBox(height: 10),
                  DropdownChoice(
                    onChange: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: dropdownItemsType,
                    selectedValue: selectedType,
                    helperText: 'Type',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  BottomButton(
                      onTap: () {
                        if (validateFields()) {
                          // save to provider + send to Django
                          sendWorkoutSettings();
                          // navigate to actual workout screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Workout5(title: 'Workout'),
                            ),
                          );
                        }
                      },
                      buttonText: 'START'),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // those choice values have to match the choices in Django models EXACTLY (the names)
  // 2. duration options
  List<DropdownMenuItem<int>> get dropdownItemsDuration {
    List<DropdownMenuItem<int>> menuItems = [
      DropdownMenuItem(
        value: 15,
        child: Text(
          '15 minutes',
          style: kSimpleTextPurple,
        ),
      ),
      DropdownMenuItem(
          value: 30,
          child: Text(
            '30 minutes',
            style: kSimpleTextPurple,
          )),
      DropdownMenuItem(
          value: 45,
          child: Text(
            '45 minutes',
            style: kSimpleTextPurple,
          )),
      DropdownMenuItem(
          value: 60,
          child: Text(
            '60 minutes',
            style: kSimpleTextPurple,
          )),
    ];
    return menuItems;
  }

  // 3. intensity options
  List<DropdownMenuItem<String>> get dropdownItemsIntensity {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(
        value: 'Beginner',
        child: Text(
          'Beginner',
          style: kSimpleTextPurple,
        ),
      ),
      DropdownMenuItem(
          value: 'Intermediate',
          child: Text(
            'Intermediate',
            style: kSimpleTextPurple,
          )),
      DropdownMenuItem(
          value: 'Advanced',
          child: Text(
            'Advanced',
            style: kSimpleTextPurple,
          )),
    ];
    return menuItems;
  }

  // 4.
  List<DropdownMenuItem<String>> get dropdownItemsType {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(
        value: 'Interval',
        child: Text(
          'Interval',
          style: kSimpleTextPurple,
        ),
      ),
      DropdownMenuItem(
          value: 'Continuous',
          child: Text(
            'Continuous',
            style: kSimpleTextPurple,
          )),
    ];
    return menuItems;
  }

  // Send a POST request to Django
  void sendWorkoutSettings() async {
    // generate session_id
    var uuid = Uuid();
    String newSessionId = uuid.v4();
    // get current user's email
    UserDetails? userDetails =
        Provider.of<UserDataProvider>(context, listen: false).userDetails;
    // retrieve the base URL from the environment variables
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];

    // 1. Send the workout settings to Django
    if (baseURL != null) {
      String apiUrl = '$baseURL/setworkout/';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          // there is a session_id that will be generated in Django
          'name': wrkName,
          'session_duration': selectedDuration,
          'level': selectedIntensity,
          'type': selectedType,
          'session_id': newSessionId,
          'email': userDetails!.email,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (mounted) {
        // make sure we send the msg first, then dispose of widget
        if (response.statusCode == 201) {
          // 1. save workout settings to a provider (name was already saved in my_workout.dart):
          Provider.of<WorkoutTypeProvider>(context, listen: false)
              .updateWorkoutType(duration: selectedDuration);
          Provider.of<WorkoutTypeProvider>(context, listen: false)
              .updateWorkoutType(level: selectedIntensity);
          Provider.of<WorkoutTypeProvider>(context, listen: false)
              .updateWorkoutType(type: selectedType);
          Provider.of<WorkoutTypeProvider>(context, listen: false)
              .updateWorkoutType(sessionId: newSessionId);
          // notify listeners after updating
          Provider.of<WorkoutTypeProvider>(context, listen: false)
              .notifyListeners();
          print('this sess id: $newSessionId');

          print('Workout settings sent successfully');
        } else {
          print(
              'Error sending message: ${response.body} ${response.statusCode} ');
        }
      }
    } else {
      print('BASE_URL is not defined in .env file');
    }
  }
}
