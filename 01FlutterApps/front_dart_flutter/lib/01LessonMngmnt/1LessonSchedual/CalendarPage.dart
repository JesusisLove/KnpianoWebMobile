import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'AddCourseDialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week; // 设置画面初期的默认显示模式
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 定义一个列表来存储学生的课程信息
  final List<StudentLsn> studentLsns = [
    StudentLsn(stuName: 'John', subjectName: 'English', time: '09:00'),
    StudentLsn(stuName: 'Tom', subjectName: 'English', time: '11:00'),
    StudentLsn(stuName: 'Ben', subjectName: 'English', time: '13:00'),
  ];

  // 根据时间获取特定时间段的事件
  List<StudentLsn> getEventsForTime(String time) {
    return studentLsns.where((event) => event.time == time).toList();
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
            onDaySelected: (selectedDay, focusedDay) {
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
                  TimeTile(time: '${i.toString().padLeft(2, '0')}:00', events: getEventsForTime('${i.toString().padLeft(2, '0')}:00')),
                  TimeTile(time: '${i.toString().padLeft(2, '0')}:15', events: getEventsForTime('${i.toString().padLeft(2, '0')}:15')),
                  TimeTile(time: '${i.toString().padLeft(2, '0')}:30', events: getEventsForTime('${i.toString().padLeft(2, '0')}:30')),
                  TimeTile(time: '${i.toString().padLeft(2, '0')}:45', events: getEventsForTime('${i.toString().padLeft(2, '0')}:45')),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // 如果没有选中日期，就使用当前日期
          DateTime dateToUse = _selectedDay ?? DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(dateToUse);
          
          print('Date: $formattedDate');
          
          // 如果你想在UI上显示这个日期，可以使用SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Date: $formattedDate')),
          );
          
          // 显示AddCourseDialog

          showDialog(
            context: context,
            builder: (BuildContext context) => AddCourseDialog(scheduleDate: formattedDate),
          );
        },
      ),
    );
  }
}

// 定义 StudentLsn 类
class StudentLsn {
  final String stuName;
  final String subjectName;
  final String time;

  StudentLsn({required this.stuName, required this.subjectName, required this.time});
}

class TimeTile extends StatelessWidget {
  final String time;
  final List<StudentLsn> events;

  const TimeTile({super.key, required this.time, this.events = const []});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 添加这个来确保内容左对齐
        children: [
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(
                    fontSize: 12, // 减小字体大小
                    fontWeight: FontWeight.w300, // 使用更细的字体粗细
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 0.5,//调整时间轴灰色线的粗细
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
                        fontSize: 12, // 减小字体大小
                        fontWeight: FontWeight.w300, // 使用更细的字体粗细
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(8),// 意思是创建一个具有均匀边距的 EdgeInsets 对象，所有方向（上、下、左、右）的填充都是 8 个逻辑像素（在设备上可能不同）。这样的 EdgeInsets 对象将会在容器的所有边缘周围添加相同的填充空间。
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100, // 可以根据需求更改颜色
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
    );
  }
}
