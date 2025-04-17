import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final String email;
  const CalendarPage({required this.email});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<String>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final String apiBaseUrl = 'http://10.0.2.2:8000/api';



  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDay = _focusedDay;
    _fetchSchedules();
  }

  void _fetchSchedules() async {
    final url = Uri.parse('$apiBaseUrl/get_schedules/${widget.email}/');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      final Map<DateTime, List<String>> loadedEvents = {};
      for (var item in data) {
        DateTime date = DateTime.parse(item['date']);
        TimeOfDay time = TimeOfDay(
          hour: int.parse(item['time'].split(":")[0]),
          minute: int.parse(item['time'].split(":")[1]),
        );

        String formatted = 'Workout at ${time.format(context)}';
        if (loadedEvents.containsKey(date)) {
          loadedEvents[date]!.add(formatted);
        } else {
          loadedEvents[date] = [formatted];
        }
      }

      setState(() {
        _events = loadedEvents;
      });
    } else {
      print('Error fetching schedules: ${response.statusCode}');
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Schedule')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map((event) => ListTile(title: Text(event)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
