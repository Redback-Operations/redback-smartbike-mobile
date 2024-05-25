import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/pages/workout_summary.dart' as WrkSummary;
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/main_app_background.dart';
import '../components/workout_metric_box.dart';
import '../services/workout_values_generator.dart';
import 'package:http/http.dart' as http;
import '../provider/wrk_type_provider.dart';

// TODO: in Django models change the user, workout_type to not be null

class Workout extends StatefulWidget {
  const Workout({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  late Timer _timer = Timer(Duration.zero, () {});
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _continueSendingData =
      true; // need to control for when we finish workout, so no data is sent beyond that point
  late String? _sessionId;

  // random values declared
  late double speedVal;
  late int rpmVal;
  late double distanceVal;
  late int heartRateVal;
  late double temperatureVal;
  late int inclineVal;

  void _startTimer() {
    _timer.cancel(); // Cancel the existing timer if it's active
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_isRunning) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
    _isRunning = true;
  }

  void _pauseTimer() {
    _isRunning = false;
  }

  void _rewindTimer() {
    setState(() {
      if (_elapsedSeconds >= 10) {
        _elapsedSeconds -= 10;
      } else {
        _elapsedSeconds = 0;
      }
    });
  }

  void _forwardTimer() {
    setState(() {
      _elapsedSeconds += 10;
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    // called every second
    speedVal = WorkoutValues.generateSpeed(1);
    rpmVal = WorkoutValues.generateRPM(speedVal);
    distanceVal = WorkoutValues.generateDistance(speedVal, 1);
    heartRateVal = WorkoutValues.generateHeartRate(speedVal);
    temperatureVal = WorkoutValues.generateTemperature(speedVal, 1);
    inclineVal = WorkoutValues.generateIncline(1);

    // send the data to backend every second
    if (_continueSendingData) {
      sendWorkoutData();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            // reset values
            setState(() {
              WorkoutValues.resetValues();
            });
            Navigator.of(context).pop();
          },
        ),
      ),
      body: CustomGradientContainerSoft(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40),
                    Container(
                      height: 200, // Adjust this height as needed
                      color: kLoginRegisterBtnColour.withOpacity(0.2),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'workout VIDEO here',
                        style: kSubTitleOfPage,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: kSubSubTitleOfPage,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _rewindTimer,
                              icon: Icon(Icons.fast_rewind),
                              iconSize: 40,
                              color: Colors.white,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isRunning = !_isRunning;
                                  if (_isRunning) {
                                    _startTimer();
                                  } else {
                                    _pauseTimer();
                                  }
                                });
                              },
                              icon: Icon(
                                  _isRunning ? Icons.pause : Icons.play_arrow),
                              iconSize: 40,
                              color: Colors.white,
                            ),
                            IconButton(
                              onPressed: _forwardTimer,
                              icon: Icon(Icons.fast_forward),
                              iconSize: 40,
                              color: Colors.white,
                            ),
                            IconButton(
                              // New IconButton for starting from beginning
                              onPressed: () {
                                setState(() {
                                  _elapsedSeconds = 0;
                                });
                              },
                              icon: Icon(Icons.replay),
                              iconSize: 40,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Speed",
                                value: speedVal.toStringAsFixed(2) + " km/h",
                              ),
                            ),
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "RPM",
                                value: rpmVal.toString() + " RPM",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          // Second Row
                          children: [
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Distance",
                                value: distanceVal.toStringAsFixed(2) + " km",
                              ),
                            ),
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Incline",
                                value: "$inclineVal%",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          // Third Row
                          children: [
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Heart Rate",
                                value: heartRateVal.toString() + " BPM",
                              ),
                            ),
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Temperature",
                                value: temperatureVal.toStringAsFixed(2) + "°C",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              width: 300,
                              child: BottomButton(
                                  onTap: () async {
                                    _pauseTimer();
                                    // TODO: make sure values were being saved to backend, we need them for summary
                                    // mmark as wrkout finished in backend
                                    await updateWrkFinished();

                                    // reset values
                                    setState(() {
                                      WorkoutValues.resetValues();
                                    });

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            WrkSummary.WorkoutSummary(),
                                      ),
                                    );
                                  },
                                  buttonText: 'Finish'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ensure to retrieve the sess id first
  Future<String?> getSessionId() async {
    return Provider.of<WorkoutTypeProvider>(context, listen: false)
        .workoutType
        ?.sessionId;
  }

  // send a POST request to Django, once we have current session_id from the provider
  void sendWorkoutData() async {
    try {
      // Load the base URL from the environment variables
      await dotenv.load(fileName: ".env");
      String? baseURL = dotenv.env['API_URL_BASE'];

      // Retrieve the current session_id generated in the last page
      _sessionId = await getSessionId();

      if (_sessionId == null) {
        print('Error: session_id is null');
        return;
      }

      if (baseURL != null && _sessionId != null) {
        String apiUrl = '$baseURL/workoutdata/';
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode({
            'speed': double.parse(speedVal.toStringAsFixed(2)),
            'rpm': rpmVal,
            'distance': double.parse(distanceVal.toStringAsFixed(2)),
            'heart_rate': heartRateVal,
            'temperature': double.parse(temperatureVal.toStringAsFixed(2)),
            'incline': inclineVal,
            'timestamp': DateTime.now().toIso8601String(),
            'session_id': _sessionId,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (mounted) {
          if (response.statusCode == 201) {
            print('Workout settings sent successfully');
          } else {
            print(
                'Error sending message: ${response.body} ${response.statusCode}');
          }
        }
      } else {
        print('BASE_URL is not defined in .env file');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // update the 'processed' value in WorkoutType in backend, which will trigger the start of data clean & analysis work
  Future<void> updateWrkFinished() async {
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    _sessionId = await getSessionId();

    String apiUrl = '$baseURL/finish_workout/';
    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'session_id': _sessionId,
        'finished':
            true, // change value to true from the previous, default value false; it will trigger data clean & analysis in backend (see django views: wrk_finished)
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _continueSendingData =
            false; // stop sending workout data; need this as there might still be some left in backlog
      });
      // If the server returns a successful response
      print('Successfully recorded the end of this workout');
    } else {
      // If the server did not return a successful response
      throw Exception('Failed to update');
    }
  }
}
