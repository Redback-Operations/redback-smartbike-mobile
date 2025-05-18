import 'package:flutter/material.dart';
import 'package:phone_app/pages/set_workout_page.dart';
import 'package:phone_app/pages/set_workout_page_2.dart';
import 'package:phone_app/pages/set_workout_page_3.dart';
import 'package:phone_app/pages/set_workout_page_4.dart';
import 'package:phone_app/pages/set_workout_page_5.dart';
import 'package:phone_app/pages/set_workout_page_6.dart';
import 'package:phone_app/pages/set_workout_page_7.dart';
import 'package:provider/provider.dart';
import '../components/main_app_background.dart';
import '../components/activity_buttons.dart';
import '../provider/wrk_type_provider.dart'; // save current workout settings

class MyWorkout extends StatefulWidget {
  const MyWorkout({super.key, required this.title});
  final String title;

  @override
  State<MyWorkout> createState() => _MyWorkoutState();
}

class _MyWorkoutState extends State<MyWorkout> {
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomGradientContainerSoft(
        child: Stack(
          children: [
            SingleChildScrollView(
              // scroll the screen with finger - up & down
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'VR Game');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'VR Game',
                          width: 300,
                        ),
                        SizedBox(height: 10),
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'Cycling');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout2(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'Cycling',
                          width: 300,
                        ),
                        SizedBox(height: 10),
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'Running');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout3(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'Running',
                          width: 300,
                        ),
                        SizedBox(height: 10), // Yoga button
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'Yoga');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout4(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'Yoga',
                          width: 300,
                        ),
                        SizedBox(height: 10), // Sports button
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'Pilates');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout5(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'Pilates',
                          width: 300,
                        ),
                        SizedBox(height: 10), // Aerobic button
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'Aerobic');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout6(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'Aerobic',
                          width: 300,
                        ),
                        SizedBox(height: 10),
                        ActivityButton(
                          onTap: () {
                            Provider.of<WorkoutTypeProvider>(context,
                                    listen: false)
                                .updateWorkoutType(name: 'High Intensity');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetWorkout7(
                                        title: '',
                                      )),
                            );
                          },
                          buttonText: 'High Intensity',
                          width: 300,
                        ),
                        SizedBox(height: 60),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
