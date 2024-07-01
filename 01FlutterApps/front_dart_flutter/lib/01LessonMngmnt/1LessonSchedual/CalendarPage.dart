// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'AddCourseDialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<StudentLsn> studentLsns = [
    StudentLsn(stuName: 'John', subjectName: 'English', time: '09:00'),
    StudentLsn(stuName: 'Tom', subjectName: 'English', time: '11:00'),
    StudentLsn(stuName: 'Ben', subjectName: 'English', time: '13:00'),
  ];

  List<StudentLsn> getEventsForTime(String time) {
    return studentLsns.where((event) => event.time == time).toList();
  }

  void _handleTimeSelection(BuildContext context, String time) {
    DateTime dateToUse = _selectedDay ?? DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateToUse);
    // print('Date: $formattedDate, Time: $time');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Date: $formattedDate, Time: $time')),
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AddCourseDialog(scheduleDate: formattedDate, scheduleTime: time),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay, ) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                for (var i = 8; i <= 22; i++) ...[
                  TimeTile(
                    time: '${i.toString().padLeft(2, '0')}:00',
                    events: getEventsForTime('${i.toString().padLeft(2, '0')}:00'),
                    onTap: () => _handleTimeSelection(context, '${i.toString().padLeft(2, '0')}:00'),
                  ),
                  TimeTile(
                    time: '${i.toString().padLeft(2, '0')}:15',
                    events: getEventsForTime('${i.toString().padLeft(2, '0')}:15'),
                    onTap: () => _handleTimeSelection(context, '${i.toString().padLeft(2, '0')}:15'),
                  ),
                  TimeTile(
                    time: '${i.toString().padLeft(2, '0')}:30',
                    events: getEventsForTime('${i.toString().padLeft(2, '0')}:30'),
                    onTap: () => _handleTimeSelection(context, '${i.toString().padLeft(2, '0')}:30'),
                  ),
                  TimeTile(
                    time: '${i.toString().padLeft(2, '0')}:45',
                    events: getEventsForTime('${i.toString().padLeft(2, '0')}:45'),
                    onTap: () => _handleTimeSelection(context, '${i.toString().padLeft(2, '0')}:45'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentLsn {
  final String stuName;
  final String subjectName;
  final String time;

  StudentLsn({required this.stuName, required this.subjectName, required this.time});
}

class TimeTile extends StatelessWidget {
  final String time;
  final List<StudentLsn> events;
  final VoidCallback onTap;

  const TimeTile({
    super.key,
    required this.time,
    this.events = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            for (var event in events)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(event.stuName),
                            const SizedBox(width: 8),
                            Text(event.subjectName),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}