import 'package:flutter/material.dart';

import '../components/account_containers.dart';
import '../components/main_app_background.dart';
import '../utilities/constants.dart';
import 'home_page.dart';

class ScheduleWorkoutScreen extends StatefulWidget {
  @override
  _ScheduleWorkoutScreenState createState() => _ScheduleWorkoutScreenState();
}

class _ScheduleWorkoutScreenState extends State<ScheduleWorkoutScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedReminder = 0; // 0 for no reminder, 1 for 24 hours, 2 for 1 hour

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour
            .withOpacity(0.9), // Set the background color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(title: 'Home Page'),
              ),
            );
          },
        ),
        title: Text(
          'Schedule Workout',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AccountContainer(
                  fieldName: 'Select Date',
                  typeIcon: Icons.calendar_today,
                  onPressed: () => _selectDate(context),
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 16.0),
                if (_selectedDate != null)
                  Text('Selected Date: ${_selectedDate!.toString()}'),
                SizedBox(height: 16.0),
                AccountContainer(
                  fieldName: 'Select Time',
                  typeIcon: Icons.timer,
                  onPressed: () => _selectTime(context),
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 16.0),
                if (_selectedTime != null)
                  Text('Selected Time: ${_selectedTime!.format(context)}'),
                SizedBox(height: 16.0),
                // TODO : use dropdown_choice.dart component for that, just like in set workout page
                Text('Set Reminder:'),
                DropdownButton<int>(
                  value: _selectedReminder,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedReminder = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('No Reminder'),
                    ),
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('24 Hours Before'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('1 Hour Before'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
