// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AddCourseDialog.dart';
import 'Kn01L002LsnBean.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Kn01L002LsnBean> studentLsns = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentLsn(_focusedDay);
  }

  Future<void> _fetchStudentLsn(DateTime date) async {
    try {
      String schedualDate = DateFormat('yyyy-MM-dd').format(date);
      final String apilsnInfoByDayUrl = '${KnConfig.apiBaseUrl}${Constants.lsnInfoByDay}/$schedualDate';
      final response = await http.get(Uri.parse(apilsnInfoByDayUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> responseStuLsnsJson = json.decode(decodedBody);
        setState(() {
          studentLsns = responseStuLsnsJson.map((json) => Kn01L002LsnBean.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load archived lessons of the day');
      }
    } catch (e) {
      print('Error fetching current-day\'s lessons data: $e');
    }
  }

  List<Kn01L002LsnBean> getSchedualLessonForTime(String time) {
    return studentLsns.where((event) => event.time == time).toList();
  }

  void _handleTimeSelection(BuildContext context, String time) {
    DateTime dateToUse = _selectedDay ?? DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateToUse);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Date: $formattedDate, Time: $time')),
    );

    // 点击时间轴上的时间或时间线弹出子对话框窗体 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCourseDialog(scheduleDate: formattedDate, scheduleTime: time);
      },
    ).then((result) {
      if (result == true) {
        setState(() {
          // 排完课后刷新课程表页面
          _fetchStudentLsn(DateTime.parse(formattedDate));
        });
      }
    });

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
              _fetchStudentLsn(selectedDay);
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
                for (var i = 8; i <= 22; i++)
                  for (var j = 0; j < 60; j += 15) ...[
                    TimeTile(
                      time: '${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}',
                      events: getSchedualLessonForTime('${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}'),
                      onTap: () => _handleTimeSelection(context, '${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}'),
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

class TimeTile extends StatelessWidget {
  final String time;
  final List<Kn01L002LsnBean> events;
  final VoidCallback onTap;

  const TimeTile({
    super.key,
    required this.time,
    this.events = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 20,
          child: _buildTimeLine(),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeLine(),
            ...events.map((event) => _buildEventTile(event)),
          ],
        ),
      ),
    );
  }

  // 构建时间轴上的时间线
  Widget _buildTimeLine() {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 0, //左边距
              right:0
              ),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildTimeText(),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

Widget _buildEventTile(Kn01L002LsnBean event) {
  return Padding(
    padding: const EdgeInsets.only(left: 56, top: 4, bottom: 4),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            event.stuName,
            style: const TextStyle(fontSize: 13, 
            // fontWeight: FontWeight.bold
            ), // 设置字体大小和粗细
          ),
          const SizedBox(width: 8),
          Text(
            event.subjectName ,
            style: const TextStyle(fontSize: 12), // 设置字体大小
          ),
          const SizedBox(width: 4),
          Text(
            event.subjectSubName ,
            style: const TextStyle(fontSize: 9), // 设置字体大小
          ),
          const SizedBox(width: 8),
          Text(
            '${event.classDuration}分钟' ,
            style: const TextStyle(fontSize: 12), // 设置字体大小
          ),
          const SizedBox(width: 8),
          Text(
            event.lessonType == 0 ? '课结算' : event.lessonType == 1 ? '月计划' : '月加课',
            style: const TextStyle(fontSize: 12), // 设置字体大小
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTimeText() {
    final isFullHour = time.endsWith(':00');
    const backgroundColor = Colors.white;

    // 整点时间的字体大小设置（如 08:00，09:00，12:00等）
    if (isFullHour) {
      return Text(
        time,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: time.substring(0, 3),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: backgroundColor,
              ),
            ),
            TextSpan(
              text: time.substring(3),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
  }
}