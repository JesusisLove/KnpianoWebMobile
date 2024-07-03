// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AddCourseDialog.dart';
import 'EditCourseDialog.dart';
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
    
    // 这个不重要，它会在手机屏幕底下显示一黑色的条，上面显示点击的日期
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Date: $formattedDate, Time: $time')),
    );

    List<Kn01L002LsnBean> eventsForTime = getSchedualLessonForTime(time);
    if (eventsForTime.isEmpty) {
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
  }
  
  // 迁移到排课的编辑画面
  void _handleEditCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCourseDialog(lessonId: event.lessonId);
      },
    ).then((result) {
      if (result == true) {
        setState(() {
          _fetchStudentLsn(DateTime.parse(event.schedualDate));
        });
      }
    });
  }

  // 执行指定学生的课程删除操作
void _handleDeleteCourse(Kn01L002LsnBean event) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要删除【${event.subjectName}】这节课吗？'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
          ),

          TextButton(
            child: const Text('确定'),
            onPressed: () async {
              final String deleteUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnDelete}/${event.lessonId}';
              try {
                final response = await http.delete(
                  Uri.parse(deleteUrl),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                );
                if (response.statusCode == 200) {
                  // 请求成功，更新界面
                  setState(() {
                    _fetchStudentLsn(DateTime.parse(event.schedualDate));
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(true); // 关闭对话框并传递成功结果
                } else {
                  throw Exception('Failed to delete lesson');
                }
              } catch (e) {
                print('Error deleting lesson: $e');
                // 处理删除失败情况
                // 可以添加错误提示或其他处理
              }
            },
          ),
        ],
      );
    },
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
              // 点击课程表日期，获取该日期的当日上课的学生课程信息
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
            // 当日的学生上课信息排列在ListView控件上
            child: ListView(
              children: [
                for (var i = 8; i <= 22; i++)
                  for (var j = 0; j < 60; j += 15) ...[
                    TimeTile(
                      time        : '${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}',
                      events      : getSchedualLessonForTime('${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}'),
                      onTap       : () => _handleTimeSelection(context, '${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}'),
                      onEdit      : _handleEditCourse,
                      onDelete    : _handleDeleteCourse,
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
  final Function(Kn01L002LsnBean) onEdit;
  final Function(Kn01L002LsnBean) onDelete;

  const TimeTile({
    super.key,
    required this.time,
    this.events = const [],
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
            ...events.map((event) => _buildEventTile(context, event)),
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
            padding: const EdgeInsets.only(left: 0, right:0),
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

  Widget _buildEventTile(BuildContext context, Kn01L002LsnBean event) {
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
          Expanded(
            child: Row(
              children: [
                Text(
                  event.stuName,
                  style: const TextStyle(fontSize: 13),
                  // fontWeight: FontWeight.bold
                ),
                const SizedBox(width: 8),
                Text(
                  event.subjectName,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  event.subjectSubName,
                  style: const TextStyle(fontSize: 9),
                ),
                const SizedBox(width: 8),
                Text(
                  '${event.classDuration}分钟',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  event.lessonType == 0 ? '课结算' : event.lessonType == 1 ? '月计划' : '月加课',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              switch (result) {
                case '签到':
                  print('点击了签到按钮');
                  break;
                case '撤销':
                  print('点击了撤销按钮');
                  break;
                case '修改':
                  onEdit(event);
                  break;
                case '调课':
                  print('点击了调课按钮');
                  break;
                case '删除':
                  onDelete(event);
                  break;
                case '备注':
                  print('点击了备注按钮');
                  break;
                default:
                  print('未知按钮被点击');
              }
            },
            itemBuilder: (BuildContext context) {
              // 根据 scanQrDate 的值决定显示哪些菜单项
              if ((event.scanQrDate != null) &&(event.scanQrDate.length > 0)) {
                // 如果是当日误操作了“「签到」，可以做「撤销」操作，过了当日就「撤销」不可了。
                if (DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()) == event.scanQrDate) {
                  return[
                    const PopupMenuItem<String>(
                      value: '撤销',
                      height: 36,
                      child: Text('撤销', style: TextStyle(fontSize: 11.5)),
                    ),
                    const PopupMenuItem<String>(
                      value: '备注',
                      height: 36,
                      child: Text('备注', style: TextStyle(fontSize: 11.5)),
                    ),
                  ];
                } else {
                  // 过了当日，只显示备注按钮
                  return [
                    const PopupMenuItem<String>(
                      value: '备注',
                      height: 36,
                      child: Text('备注', style: TextStyle(fontSize: 11.5)),
                    ),
                  ];
                }
              } else {
                // 显示所有按钮
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: '签到',
                    height: 36, // 减小高度以适应更小的字体
                    child: Text('签到', style: TextStyle(fontSize: 11.5)),
                  ),
                  const PopupMenuDivider(height: 1),
                  const PopupMenuItem<String>(
                    value: '修改',
                    height: 36,
                    child: Text('修改', style: TextStyle(fontSize: 11.5)),
                  ),
                  const PopupMenuItem<String>(
                    value: '调课',
                    height: 36,
                    child: Text('调课', style: TextStyle(fontSize: 11.5)),
                  ),
                  const PopupMenuItem<String>(
                    value: '删除',
                    height: 36,
                    child: Text('删除', style: TextStyle(fontSize: 11.5)),
                  ),
                  const PopupMenuDivider(height: 1),// 减小分隔线高度
                  const PopupMenuItem<String>(
                    value: '备注',
                    height: 36,
                    child: Text('备注', style: TextStyle(fontSize: 11.5)),
                  ),
                ];
              }
            },
            // 设置菜单的宽度，并添加圆角
            constraints: const BoxConstraints(
              minWidth: 50, // 设置最小宽度
              maxWidth: 60, // 设置最大宽度
            ),
            position: PopupMenuPosition.under,// 确保菜单在按钮下方打开
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 添加圆角
            ),
            padding: EdgeInsets.zero,// 移除内边距以使菜单更紧凑
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