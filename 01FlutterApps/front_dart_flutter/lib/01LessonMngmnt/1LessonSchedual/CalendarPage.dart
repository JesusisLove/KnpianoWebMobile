// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../CommonProcess/customUI/KnAppBar.dart';
import 'AddCourseDialog.dart';
import 'EditCourseDialog.dart';
import 'Kn01L002LsnBean.dart';
import 'RescheduleLessonDialog.dart';

class CalendarPage extends StatefulWidget {
  final String focusedDay;
  // [修改] 构造函数参数类型修改为String
  const CalendarPage({Key? key, required this.focusedDay}) : super(key: key);
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  // [新增] 新增 late 变量声明
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  List<Kn01L002LsnBean> studentLsns = [];

  @override
  void initState() {
    super.initState();
    // [新增] 初始化 _focusedDay 和 _selectedDay
    _focusedDay = DateFormat('yyyy-MM-dd').parse(widget.focusedDay);
    _selectedDay = _focusedDay;
    _fetchStudentLsn(widget.focusedDay.trim());
  }

  Future<void> _fetchStudentLsn(String schedualDate) async {
    try {
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
    // [修改] 使用 _selectedDay 替代原来的判断
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    return studentLsns.where((event) {
      // 计划课日期 yyyy/mm/dd 
      String eventScheduleDateStr = event.schedualDate != null && event.schedualDate.length >= 10
          ? event.schedualDate.substring(0, 10)
          : '';
      // 计划课时间 HH:mm
      String eventTime1 = event.schedualDate != null && event.schedualDate.length >= 16
          ? event.schedualDate.substring(11, 16)
          : '';

      // 调课日期 yyyy/mm/dd 
      String eventAdjustedDateStr = event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10
          ? event.lsnAdjustedDate.substring(0, 10)
          : '';
      // 调课时间 HH:mm
      String eventTime2 = event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 16
          ? event.lsnAdjustedDate.substring(11, 16)
          : '';
      
      return (eventScheduleDateStr == selectedDateStr && eventTime1 == time)
           ||(eventAdjustedDateStr == selectedDateStr && eventTime2 == time);

    }).toList();
  }

  // 看一下这个时间轴上也没有空位置可以点击time的时间来排课
  void _handleTimeSelection(BuildContext context, String time) {
    // [修改] 使用 _selectedDay
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    
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
            _fetchStudentLsn(formattedDate);
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
          // [修改] 使用 _selectedDay
          _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
        });
      }
    });
  }

  // 执行上课签到
  void _handleSignCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('执行签到确认'),
          content: Text('签到【${event.subjectName}】这节课，\n当日之内可以撤销，过了今日撤销不可！\n您确定要签到吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () async {
                final String signUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuLsnSign}/${event.lessonId}';
                try {
                  final response = await http.get(
                    Uri.parse(signUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    }, 
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      // [修改] 使用 _selectedDay
                      _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
                    });
                    Navigator.of(context).pop(true);
                  } else {
                    throw Exception('Failed to delete lesson');
                  }
                } catch (e) {
                  print('Error deleting lesson: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 执行撤销
  void _handleRestoreCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('撤销确认'),
          content: Text('确实要撤销【${event.subjectName}】这节课吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () async {
                final String signUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuLsnRestore}/${event.lessonId}';
                try {
                  final response = await http.get(
                    Uri.parse(signUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    }, 
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      // [修改] 使用 _selectedDay
                      _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
                    });
                    Navigator.of(context).pop(true);
                  } else {
                    throw Exception('Failed to delete lesson');
                  }
                } catch (e) {
                  print('Error deleting lesson: $e');
                }
              },
            ),
          ],
        );
      },
);
  }

  // 迁移调课画面
  void _handleReschLsnCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 设置为透明以显示自定义背景
          child: Container(
            width: 300, // 设置宽度
            height: 400,// 设置高度
            decoration: BoxDecoration(
              color: Colors.white, // 设置背景色
              borderRadius: BorderRadius.circular(16), // 设置圆角
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RescheduleLessonDialog(lessonId: event.lessonId),
            ),
          ),
        );
      },
    ).then((result) {
      if (result == true) {
        setState(() {
          // [修改] 使用 _selectedDay
          _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
        });
      }
    });
  }

  // 取消调课操作
  void _handleCancelRescheCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('取消调课确认'),
          content: Text('要取消【${event.subjectName}】这节课的调课吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () async {
                final String deleteUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnRescheCancel}/${event.lessonId}';
                try {
                  final response = await http.post(
                    Uri.parse(deleteUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      // [修改] 使用 _selectedDay
                      _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
                    });
                    Navigator.of(context).pop(true);
                  } else {
                    throw Exception('Failed to delete lesson');
                  }
                } catch (e) {
                  print('Error deleting lesson: $e');
                }
              },
            ),
          ],
        );
      },
    );
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
                Navigator.of(context).pop();
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
                    setState(() {
                      // [修改] 使用 _selectedDay
                      _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
                    });
                    Navigator.of(context).pop(true);
                  } else {
                    throw Exception('Failed to delete lesson');
                  }
                } catch (e) {
                  print('Error deleting lesson: $e');
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
      appBar: KnAppBar(
          title: '课程表',
          subtitle: '学生课程管理 >> 课程表',
          context: context,
          appBarBackgroundColor: Constants.lessonThemeColor, // 自定义AppBar背景颜色
          titleColor: Colors.blue.shade900, // 自定义标题颜色
          subtitleBackgroundColor: Colors.blue.shade700, // 自定义底部文本框背景颜色
          subtitleTextColor: Colors.white, // 自定义底部文本颜色
          titleFontSize: 20.0, // 自定义标题字体大小
          subtitleFontSize: 12.0, // 自定义底部文本字体大小
          actions: [
            // 如果需要，可以在这里添加额外的操作按钮
          ],
        ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            // [修改] 使用 _focusedDay
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            // [修改] 更新 onDaySelected 回调
            onDaySelected: (selectedDay, focusedDay,) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // 点击课程表日期，获取该日期的当日上课的学生课程信息
              _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(selectedDay));
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
                      onSign      : _handleSignCourse,
                      onRestore   : _handleRestoreCourse,
                      onEdit      : _handleEditCourse,
                      onDelete    : _handleDeleteCourse,
                      onReschLsn  : _handleReschLsnCourse,
                      onCancel    : _handleCancelRescheCourse,
                      // [修改] 使用 _selectedDay
                      selectedDay : _selectedDay,
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
  final Function(Kn01L002LsnBean) onSign;
  final Function(Kn01L002LsnBean) onRestore;
  final Function(Kn01L002LsnBean) onEdit;
  final Function(Kn01L002LsnBean) onDelete;
  final Function(Kn01L002LsnBean) onReschLsn;
  final Function(Kn01L002LsnBean) onCancel;
  final DateTime selectedDay;

  const TimeTile({
    super.key,
    required this.time,
    this.events = const [],
    required this.onTap,
    required this.onSign,
    required this.onRestore,
    required this.onEdit,
    required this.onDelete,
    required this.onReschLsn,
    required this.onCancel,
    required this.selectedDay,
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
    final selectedDayStr = DateFormat('yyyy-MM-dd').format(selectedDay);

    // 计划上课日期的yyyy/mm/dd格式
    final eventScheduleDateStr = event.schedualDate != null && event.schedualDate.length >= 10 
        ? event.schedualDate.substring(0, 10) 
        : '';
    // 调课日期的yyyy/mm/dd格式
    final eventAdjustedDateStr = event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10 
        ? event.lsnAdjustedDate.substring(0, 10) 
        : '';

    // 调课日期有值，表示已经调课了
    final hasBeenRescheduled = event.lsnAdjustedDate != null && event.lsnAdjustedDate.isNotEmpty;

    // 签到日期有值，表示已经签到了
    final hasBeenSigned = event.scanQrDate != null && event.scanQrDate.isNotEmpty;

    // 计划课（未签到/已签到）
    final isScheduledUnsignedLsn = ((selectedDayStr == eventScheduleDateStr) && !hasBeenRescheduled && !hasBeenSigned);
    final isScheduledSignedLsn = ((selectedDayStr == eventScheduleDateStr) && !hasBeenRescheduled && hasBeenSigned);

    // 调课元（未签到）
    final isAdjustedUnSignedLsnFrom = ((selectedDayStr == eventScheduleDateStr) 
                                    && hasBeenRescheduled 
                                    && (selectedDayStr != eventAdjustedDateStr) 
                                    && !hasBeenSigned);
    // 调课元（已签到）                                
    final isAdjustedSignedLsnFrom   = ((selectedDayStr == eventScheduleDateStr) 
                                    && hasBeenRescheduled 
                                    && (selectedDayStr != eventAdjustedDateStr) 
                                    && hasBeenSigned);

    // 调课先（未签到）
    final isAdjustedUnSignedLsnTo = ((selectedDayStr != eventScheduleDateStr) 
                                  && hasBeenRescheduled 
                                  && (selectedDayStr == eventAdjustedDateStr) 
                                  && !hasBeenSigned);
    // 调课先（已签到）                              
    final isAdjustedSignedLsnTo   = ((selectedDayStr != eventScheduleDateStr) 
                                  && hasBeenRescheduled 
                                  && (selectedDayStr == eventAdjustedDateStr) 
                                  && hasBeenSigned);

    Color backgroundColor;
    Color textColor = Colors.black;
    String additionalInfo = '';
    // 调课元未签到
    if (isAdjustedUnSignedLsnFrom) {
      backgroundColor = Colors.grey.shade300;
      additionalInfo = '调课To：${event.lsnAdjustedDate ?? ''}';
    } 
    // 调课元已签到
    else if (isAdjustedSignedLsnFrom) {
      backgroundColor = Colors.grey.shade300;
      additionalInfo = '调课To：${event.lsnAdjustedDate ?? ''}';
    } 
    // 调课先未签到
    else if (isAdjustedUnSignedLsnTo) {
      backgroundColor = Colors.orange.shade100;
      additionalInfo = '调课From：${event.schedualDate}';
    } 
    // 调课先已签到
    else if (isAdjustedSignedLsnTo) {
      // backgroundColor = Colors.green.shade100;
      backgroundColor = Colors.grey.shade500;
      additionalInfo = '调课From：${event.schedualDate}';
    } 
    // 计划课未签到
    else if (isScheduledUnsignedLsn) {
      backgroundColor = Colors.blue.shade100;
    }
    // 计划课已签到
    else if (isScheduledSignedLsn) {
      // backgroundColor = Colors.green.shade100;
      backgroundColor = Colors.grey.shade500;
    } else {
      backgroundColor = Colors.black12;
    }

 TextDecoration textDecoration = TextDecoration.none;
 if (isScheduledSignedLsn || isAdjustedSignedLsnFrom || isAdjustedSignedLsnTo) {
    textDecoration = TextDecoration.lineThrough;
  }

    return Padding(
      padding: const EdgeInsets.only(left: 56, top: 4, bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        event.stuName,
                        style: TextStyle(fontSize: 13, color: textColor, decoration: textDecoration,),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.subjectName,
                        style: TextStyle(fontSize: 12, color: textColor, decoration: textDecoration,),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.subjectSubName,
                        style: TextStyle(fontSize: 9, color: textColor, decoration: textDecoration,),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.classDuration}分钟',
                        style: TextStyle(fontSize: 12, color: textColor, decoration: textDecoration,),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.lessonType == 0 ? '课结算' : event.lessonType == 1 ? '月计划' : '月加课',
                        style: TextStyle(fontSize: 12, color: textColor, decoration: textDecoration,),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (String result) {
                    switch (result) {
                      case '签到':
                        onSign(event);
                        break;
                      case '撤销':
                        onRestore(event);
                        break;
                      case '修改':
                        onEdit(event);
                        break;
                      case '调课':
                        onReschLsn(event);
                        break;
                      case '取消':
                        onCancel(event);
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
                    if ((event.scanQrDate != null) && (event.scanQrDate.isNotEmpty)) {
                      // 签到记录的菜单显示
                      if (DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()) == event.scanQrDate) {
                        return[
                          const PopupMenuItem<String>(
                            value: '撤销',
                            height: 36,
                            child: Text('撤销', style:
                            TextStyle(fontSize: 11.5)),
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
                      // 如果是调课元记录情况下，显示按钮
                      if (isAdjustedUnSignedLsnFrom) {
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: '修改',
                            height: 36,
                            child: Text('修改', style: TextStyle(fontSize: 11.5)),
                          ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem<String>(
                            value: '调课',
                            height: 36,
                            child: Text('调课', style: TextStyle(fontSize: 11.5)),
                          ),
                          const PopupMenuItem<String>(
                            value: '取消',
                            height: 36,
                            child: Text('取消', style: TextStyle(fontSize: 11.5)),
                          ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem<String>(
                            value: '删除',
                            height: 36,
                            child: Text('删除', style: TextStyle(fontSize: 11.5)),
                          ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem<String>(
                            value: '备注',
                            height: 36,
                            child: Text('备注', style: TextStyle(fontSize: 11.5)),
                          ),
                        ];
                      } 
                      // 计划课和调课记录情况下，显示按钮
                      else {
                        // 显示所有按钮
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: '签到',
                            height: 36,
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
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem<String>(
                            value: '备注',
                            height: 36,
                            child: Text('备注', style: TextStyle(fontSize: 11.5)),
                          ),
                        ];
                      }
                    }
                  },
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    maxWidth: 60,
                  ),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (additionalInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  additionalInfo,
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
                ),
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