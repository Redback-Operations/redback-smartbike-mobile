import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/account_containers.dart';
import '../components/bottom_button.dart';
import '../components/main_app_background.dart';
import '../utilities/constants.dart';
import 'calendar_page.dart';
import 'home_page.dart';

class ScheduleWorkoutScreen extends StatefulWidget {
  @override
  _ScheduleWorkoutScreenState createState() => _ScheduleWorkoutScreenState();
}

class _ScheduleWorkoutScreenState extends State<ScheduleWorkoutScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedReminder = 0;
  String _selectedRecurrence = 'None';

  final String userEmail = 'tharukanadeesh99@gmail.com'; // Replace with actual user email if needed
  final String apiBaseUrl = 'http://10.0.2.2:8000/api'; // For Android emulator

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _scheduleWorkout() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    final url = Uri.parse('$apiBaseUrl/create_schedule/');
    final body = {
      "user": userEmail,
      "title": "Workout",
      "description": "Scheduled workout",
      "date": _selectedDate!.toIso8601String().split("T")[0],
      "time": "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
      "reminder_minutes": _selectedReminder == 1 ? 1440 : _selectedReminder == 2 ? 60 : 0,
      "recurrence": _selectedRecurrence,
    };

    print("📤 Sending to: $url");
    print("📦 Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("🔁 Status code: ${response.statusCode}");
      print("📩 Response body: ${response.body}");

      if (response.statusCode == 201) {
        final timeText = _selectedTime!.format(context);
        final dateText = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scheduled for $timeText on $dateText ($_selectedRecurrence)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule workout')),
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while scheduling')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(title: 'Home Page')));
          },
        ),
        title: Text('Schedule Workout'),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AccountContainer(
                  fieldName: 'Select Date',
                  typeIcon: Icons.calendar_today,
                  onPressed: () => _selectDate(context),
                  arrowOptional: Icons.arrow_forward,
                ),
                SizedBox(height: 16.0),
                if (_selectedDate != null)
                  Text('Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
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
                Text('Set Reminder:'),
                DropdownButton<int>(
                  value: _selectedReminder,
                  onChanged: (value) => setState(() => _selectedReminder = value!),
                  style: TextStyle(color: Colors.black),
                  items: [
                    DropdownMenuItem(value: 0, child: Text('No Reminder')),
                    DropdownMenuItem(value: 1, child: Text('24 Hours Before')),
                    DropdownMenuItem(value: 2, child: Text('1 Hour Before')),
                  ],
                ),
                SizedBox(height: 16.0),
                Text('Repeat:'),
                DropdownButton<String>(
                  value: _selectedRecurrence,
                  onChanged: (value) => setState(() => _selectedRecurrence = value!),
                  style: TextStyle(color: Colors.black),
                  items: ['None', 'Daily', 'Weekly', 'Monthly'].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                ),
                SizedBox(height: 32.0),
                BottomButton(
                  onTap: _scheduleWorkout,
                  buttonText: 'Schedule',
                ),
                SizedBox(height: 16.0),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CalendarPage(email: userEmail)),
                    );
                  },
                  icon: Icon(Icons.calendar_month),
                  label: Text("View Calendar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
