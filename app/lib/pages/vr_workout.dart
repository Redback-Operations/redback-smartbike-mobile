import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/pages/SmartBikeSummary.dart';
import 'package:phone_app/pages/workout_summary.dart' as WrkSummary;
import 'package:phone_app/utilities/alert.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/main_app_background.dart';
import '../components/workout_metric_box.dart';
import '../services/workout_values_generator.dart';
import 'package:http/http.dart' as http;
import '../provider/wrk_type_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// TODO: in Django models change the user, workout_type to not be null

List<String> topics = [
  'bike/000001/cadence',
  'bike/000001/speed',
  'bike/000001/incline/report',
  'bike/000001/heartrate',
  'bike/000001/resistance/report',
];

class Workout extends StatefulWidget {
  const Workout({super.key, required this.title});
  final String title;

  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  OverlayEntry? _overlayEntry;
  late MqttServerClient _client;
  bool isConnected = false;
  bool _isDisposed = false;
  late Timer _timer = Timer(Duration.zero, () {});
  int _elapsedSeconds = 0;
  int _prevSpeedCalcElapsedSeconds = 0;
  bool _isRunning = false;
  bool _continueSendingData =
      true; // need to control for when we finish workout, so no data is sent beyond that point
  late String? _sessionId;

  // random values declared
  double rpmVal = 0;
  double speedVal = 0;
  double distanceVal = 0;
  double heartRateVal = 0;
  int inclineEvents = 0;
  double avgInclineVal = 0;
  int resistanceEvents = 0;
  double avgResistanceVal = 0;

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
    connectToMqtt();
  }

  Future<void> connectToMqtt() async {
    _client = MqttServerClient.withPort(
        'broker.mqtt.cool', 'q2904387q29038742432r3', 1883);
    // _client.keepAlivePeriod = 5;
    // _client.logging(on: true);

    _client.onConnected = () {
      setState(() {
        isConnected = true;
      });
      _subscribeToTopics();
    };

    _client.onDisconnected = () {
      if (!_isDisposed) {
        // Ensure the widget is still mounted
        setState(() {
          isConnected = true;
        });
      }
    };

    try {
      await _client.connect();
    } catch (e) {
      print('Exception: $e');
      _client.disconnect();
    }
  }

  void _subscribeToTopics() {
    for (var topic in topics) {
      _client.subscribe(topic, MqttQos.atMostOnce);
    }

    // Set up a listener to handle the incoming messages
    _client.updates
        ?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
      final MqttPublishMessage recMess =
          messages![0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      _handleResponse(messages[0].topic, payload);
    });
  }

  void _handleResponse(String topic, String payload) {
    if (!_isRunning) {
      return;
    }
    // Decode the incoming payload as JSON
    var data = jsonDecode(payload);

    if (!_isDisposed) {
      setState(() {
        try {
          switch (topic) {
            case 'bike/000001/cadence':
              rpmVal = data['value'];
              break;
            case 'bike/000001/speed':
              speedVal = data['value'];
              int diffSecs = _elapsedSeconds - _prevSpeedCalcElapsedSeconds;
              _prevSpeedCalcElapsedSeconds = _elapsedSeconds;
              distanceVal = WorkoutValues.generateDistance(speedVal, diffSecs);
              break;
            case 'bike/000001/incline/report':
              double val = data['value'];
              double totalCurrent = (avgInclineVal * inclineEvents) + val;
              inclineEvents++;
              avgInclineVal = totalCurrent / inclineEvents;
              break;
            case 'bike/000001/heartrate':
              heartRateVal = data['value'];
              break;
            case 'bike/000001/resistance/report':
              double val = data['value'];
              double totalCurrent = (avgResistanceVal * resistanceEvents) + val;
              resistanceEvents++;
              avgResistanceVal = totalCurrent / resistanceEvents;
              break;
          }
        } catch (e) {
          print('Error: $e');
        }
      });
    }
  }

  void _unsubscribeFromAll() {
    for (var topic in topics) {
      _client.unsubscribe(topic);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _unsubscribeFromAll();
    _isDisposed = true;
    _client.disconnect();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 16.0), // Aligns the content to the right
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Ensures Row takes up only the space it needs
              children: [
                Icon(
                  Icons.circle,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4), // Small spacing between icon and text
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
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
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Speed",
                                value: "${speedVal.toStringAsFixed(2)} km/h",
                              ),
                            ),
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "RPM",
                                value: "$rpmVal RPM",
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
                                value: "${distanceVal.toStringAsFixed(2)} km",
                              ),
                            ),
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Incline",
                                value: "${avgInclineVal.toStringAsFixed(2)} %",
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
                                value: "$heartRateVal BPM",
                              ),
                            ),
                            Expanded(
                              child: WorkoutMetricBox(
                                label: "Resistance",
                                value: avgResistanceVal.toStringAsFixed(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              width: 300,
                              child: BottomButton(
                                  onTap: () async {
                                    _pauseTimer();
                                    // Mark as wrkout finished in backend
                                    updateWrkFinished();
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
            'resistance': double.parse(avgResistanceVal.toStringAsFixed(2)),
            'incline': avgInclineVal,
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

  // Function to show the loader
  void _showLoader() {
    _overlayEntry = AlertUtils().createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!); // Insert the loader overlay
  }

  // Function to hide the loader
  void _hideLoader() {
    _overlayEntry?.remove(); // Remove the overlay
    _overlayEntry = null;
  }

  // update the 'processed' value in WorkoutType in backend, which will trigger the start of data clean & analysis work
  Future<void> updateWrkFinished() async {
    await dotenv.load(fileName: ".env");
    String? baseURL = dotenv.env['API_URL_BASE'];
    _sessionId = await getSessionId();

    String apiUrl = '$baseURL/finish_workout/';
    _showLoader();
    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'session_id': _sessionId,
        // Finished does not work if redis not setup properly
        'finished':
            false, // change value to true from the previous, default value false; it will trigger data clean & analysis in backend (see django views: wrk_finished)
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _continueSendingData =
            false; // stop sending workout data; need this as there might still be some left in backlog
      });
      // If the server returns a successful response
      // reset values
      setState(() {
        WorkoutValues.resetValues();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SmartBikeSummary(
            speed: speedVal.toStringAsFixed(2),
            rpm: rpmVal.toString(),
            distance: distanceVal.toStringAsFixed(2),
            heartRate: heartRateVal.toStringAsFixed(2),
            resistance: avgResistanceVal.toStringAsFixed(2),
            incline: avgInclineVal.toStringAsFixed(2),
          ),
        ),
      );
    } else {
      // If the server did not return a successful response
      AlertUtils.showAlert(
        context: context,
        title: 'Error',
        message: 'Failed to record the end of this workout.',
      );
    }

    _hideLoader();
  }
}
