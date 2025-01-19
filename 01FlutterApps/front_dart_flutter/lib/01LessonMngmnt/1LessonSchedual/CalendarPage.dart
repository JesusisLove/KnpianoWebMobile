// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../CommonProcess/customUI/KnAppBar.dart';
import 'AddCourseDialog.dart';
import 'EditCourseDialog.dart';
import 'Kn01L002LsnBean.dart';
import 'RescheduleLessonDialog.dart';

class CalendarPage extends StatefulWidget {
  final String focusedDay;
  const CalendarPage({super.key, required this.focusedDay});
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  List<Kn01L002LsnBean> studentLsns = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _updateLessonTime(String lessonId, String newTime) async {
    final Map<String, dynamic> courseData = {
      'lessonId': lessonId,
      'schedualDate': '${widget.focusedDay} $newTime',
    };

    try {
      // final String updateUrl = '${KnConfig.apiBaseUrl}${Constants.apiUpdateLessonTime}/$lessonId';
      final String updateUrl = '${KnConfig.apiBaseUrl}${Constants.apiUpdateLessonTime}';
      final response = await http.post(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        // body: json.encode({'newTime': newTime}),
        body: json.encode(courseData),
      );

      if (response.statusCode == 200) {
        await _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
      } else {
        throw Exception('Failed to update lesson time');
      }
    } catch (e) {
      print('Error updating lesson time: $e');
      rethrow;
    }
  }

  List<Kn01L002LsnBean> getSchedualLessonForTime(String time) {
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    return studentLsns.where((event) {
      String eventScheduleDateStr = event.schedualDate != null && event.schedualDate.length >= 10 ? event.schedualDate.substring(0, 10) : '';
      String eventTime1 = event.schedualDate != null && event.schedualDate.length >= 16 ? event.schedualDate.substring(11, 16) : '';

      String eventAdjustedDateStr = event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10 ? event.lsnAdjustedDate.substring(0, 10) : '';
      String eventTime2 = event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 16 ? event.lsnAdjustedDate.substring(11, 16) : '';

      return (eventScheduleDateStr == selectedDateStr && eventTime1 == time) || (eventAdjustedDateStr == selectedDateStr && eventTime2 == time);
    }).toList();
  }

  void _handleTimeSelection(BuildContext context, String time) {
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
            _fetchStudentLsn(formattedDate);
          });
        }
      });
    }
  }

  void _handleEditCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCourseDialog(lessonId: event.lessonId);
      },
    ).then((result) {
      if (result == true) {
        setState(() {
          _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
        });
      }
    });
  }

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

  void _handleReschLsnCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
          _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
        });
      }
    });
  }

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

  void _handleNoteCourse(Kn01L002LsnBean event) {
    String noteContent = event.memo ?? '';
    bool hasContent = noteContent.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Text('备注'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              content: TextField(
                maxLines: 3,
                controller: TextEditingController(text: noteContent)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: noteContent.length),
                  ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请输入备注内容',
                ),
                onChanged: (value) {
                  noteContent = value;
                  setDialogState(() {
                    hasContent = value.trim().isNotEmpty;
                  });
                },
              ),
              actions: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasContent ? Colors.pink[100] : Colors.grey[300],
                    ),
                    onPressed: hasContent
                        ? () async {
                            try {
                              final String memoUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuLsnMemo}/${event.lessonId}';
                              final response = await http.post(
                                Uri.parse(memoUrl),
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: json.encode({
                                  'memo': noteContent,
                                  'lessonId': event.lessonId,
                                }),
                              );
                              final responseData = json.decode(utf8.decode(response.bodyBytes));

                              if (response.statusCode == 200 && responseData['status'] == 'success') {
                                Navigator.of(dialogContext).pop();
                                _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('备注更新成功'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(
                                    content: Text('备注更新失败: ${responseData['message'] ?? '未知错误'}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text('发生错误: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        : null,
                    child: const Text('确认'),
                  ),
                ),
              ],
            );
          },
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
        appBarBackgroundColor: Constants.lessonThemeColor,
        titleColor: Colors.white,
        subtitleBackgroundColor: Colors.blue.shade700,
        subtitleTextColor: Colors.white,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        addInvisibleRightButton: true,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
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
                _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(selectedDay));
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Constants.lessonThemeColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Constants.lessonThemeColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              DateFormat('yyyy年MM月dd日').format(_selectedDay),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ((22 - 8) * 4), // 从8点到22点，每小时4个时间段
              itemBuilder: (context, index) {
                int hour = 8 + (index ~/ 4);
                int minute = (index % 4) * 15;
                String time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                return TimeTile(
                  time: time,
                  events: getSchedualLessonForTime(time),
                  onTap: () => _handleTimeSelection(context, time),
                  onSign: _handleSignCourse,
                  onRestore: _handleRestoreCourse,
                  onEdit: _handleEditCourse,
                  onDelete: _handleDeleteCourse,
                  onReschLsn: _handleReschLsnCourse,
                  onCancel: _handleCancelRescheCourse,
                  onAddmemo: _handleNoteCourse,
                  selectedDay: _selectedDay,
                  onTimeChanged: _updateLessonTime, // 新增：传递时间更新方法
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 修改后的 TimeTile 相关代码
class TimeTile extends StatefulWidget {
  final String time;
  final List<Kn01L002LsnBean> events;
  final VoidCallback onTap;
  final Function(Kn01L002LsnBean) onSign;
  final Function(Kn01L002LsnBean) onRestore;
  final Function(Kn01L002LsnBean) onEdit;
  final Function(Kn01L002LsnBean) onDelete;
  final Function(Kn01L002LsnBean) onReschLsn;
  final Function(Kn01L002LsnBean) onCancel;
  final Function(Kn01L002LsnBean) onAddmemo;
  final DateTime selectedDay;
  final Function(String, String) onTimeChanged; // 新增：时间更新回调

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
    required this.onAddmemo,
    required this.selectedDay,
    required this.onTimeChanged, // 新增：构造函数参数
  });

  @override
  _TimeTileState createState() => _TimeTileState();
}

class _TimeTileState extends State<TimeTile> {
  bool isDragging = false;
  double verticalOffset = 0;
  Kn01L002LsnBean? draggedEvent;
  String? highlightedTime;
  final GlobalKey _timeLineKey = GlobalKey();
  double? _timeSlotHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTimeSlotHeight();
    });
  }

  void _calculateTimeSlotHeight() {
    final RenderBox? renderBox = _timeLineKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _timeSlotHeight = renderBox.size.height;
        print('Time slot height: $_timeSlotHeight');
      });
    }
  }

  // 处理长按开始，添加触觉反馈
  void _handleLongPressStart(Kn01L002LsnBean event) async {
    if (!_isGrayBackground(event)) {
      await HapticFeedback.heavyImpact();
      setState(() {
        isDragging = true;
        draggedEvent = event;
      });
    }
  }

  // 处理拖动更新，使用卡片上边缘计算时间
  void _handleDragUpdate(LongPressMoveUpdateDetails details) {
    if (isDragging && draggedEvent != null) {
      // 获取ListView在屏幕上的位置
      final RenderBox listBox = context.findRenderObject() as RenderBox;
      final listPosition = listBox.localToGlobal(Offset.zero);

      // 获取8:00时间轴的位置
      final firstTimeSlotBox = _timeLineKey.currentContext?.findRenderObject() as RenderBox?;
      final firstTimeSlotPosition = firstTimeSlotBox?.localToGlobal(Offset.zero);

      if (firstTimeSlotPosition != null) {
        // 计算拖动点相对于8:00时间轴的垂直距离
        final verticalDistance = details.globalPosition.dy - firstTimeSlotPosition.dy;

        // 计算滚动偏移
        final ScrollableState? scrollable = Scrollable.maybeOf(context);
        final scrollOffset = scrollable?.position.pixels ?? 0;

        // 考虑所有offset后计算实际位置
        final adjustedPosition = verticalDistance + scrollOffset;

        // 每15分钟的实际高度(根据UI计算)
        final quarterHourHeight = 28.0; // 可以通过实际测量得到这个值

        // 计算时间槽
        final timeSlot = (adjustedPosition / quarterHourHeight).floor();

        // 计算对应时间
        final int totalMinutes = (timeSlot * 15) + (8 * 60);
        final int hour = totalMinutes ~/ 60;
        final int minute = totalMinutes % 60;

        if (hour >= 8 && hour < 22) {
          setState(() {
            verticalOffset = details.offsetFromOrigin.dy;
            highlightedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
            print('Adjusted position: $adjustedPosition, '
                'Time slot: $timeSlot, '
                'Vertical distance: $verticalDistance, '
                'Scroll offset: $scrollOffset, '
                'Time: $highlightedTime');
          });
        }
      }
    }
  }

  // 处理拖动结束
  void _handleDragEnd(LongPressEndDetails details) async {
    if (isDragging && draggedEvent != null && highlightedTime != null) {
      // 显示更新进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('正在更新上课时间...'),
                  ],
                ),
              ),
            ),
          );
        },
      );

      try {
        // 调用父组件提供的更新方法
        await widget.onTimeChanged(draggedEvent!.lessonId, highlightedTime!);

        // 成功后提供触觉反馈
        await HapticFeedback.mediumImpact();

        if (context.mounted) {
          // 关闭进度对话框
          Navigator.of(context).pop();

          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('上课时间更新成功'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // 关闭进度对话框
          Navigator.of(context).pop();

          // 显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('更新失败: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // 重置状态
      setState(() {
        isDragging = false;
        draggedEvent = null;
        verticalOffset = 0;
        highlightedTime = null;
      });
    }
  }

  bool _isGrayBackground(Kn01L002LsnBean event) {
    String selectedDayStr = DateFormat('yyyy-MM-dd').format(widget.selectedDay);

    String eventScheduleDateStr = '';
    if (event.schedualDate != null && event.schedualDate.length >= 10) {
      eventScheduleDateStr = event.schedualDate.substring(0, 10);
    }

    String eventAdjustedDateStr = '';
    if (event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10) {
      eventAdjustedDateStr = event.lsnAdjustedDate.substring(0, 10);
    }

    bool hasBeenRescheduled = event.lsnAdjustedDate?.isNotEmpty ?? false;
    bool hasBeenSigned = event.scanQrDate?.isNotEmpty ?? false;

    bool isGray = ((selectedDayStr == eventScheduleDateStr) && hasBeenRescheduled) || ((selectedDayStr == eventScheduleDateStr) && hasBeenSigned) || ((selectedDayStr == eventAdjustedDateStr) && hasBeenSigned);

    return isGray;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          key: _timeLineKey,
          height: 20, // 这里保持固定高度作为基准
          child: _buildTimeLine(),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              key: _timeLineKey,
              child: _buildTimeLine(),
            ),
            ...widget.events.map((event) => _buildEventTile(context, event)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLine() {
    final isCurrentTimeHighlighted = widget.time == highlightedTime;

    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 0, right: 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildTimeText(isHighlighted: isCurrentTimeHighlighted),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: isCurrentTimeHighlighted ? 2.0 : 0.5,
            color: isCurrentTimeHighlighted ? Colors.blue : Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeText({bool isHighlighted = false}) {
    final isFullHour = widget.time.endsWith(':00');
    const backgroundColor = Colors.white; // 用于隐藏非整点时间的小时部分

    if (isFullHour) {
      return Text(
        widget.time,
        style: TextStyle(
          fontSize: isHighlighted ? 13 : 11,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w300,
          color: isHighlighted ? Colors.blue : Colors.black,
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.time.substring(0, 3), // 小时部分和冒号
              style: TextStyle(
                fontSize: isHighlighted ? 12 : 10,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w300,
                color: backgroundColor, // 使用白色使其不可见
              ),
            ),
            TextSpan(
              text: widget.time.substring(3), // 分钟部分
              style: TextStyle(
                fontSize: isHighlighted ? 12 : 10,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w300,
                color: isHighlighted ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEventTile(BuildContext context, Kn01L002LsnBean event) {
    final selectedDayStr = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    final eventScheduleDateStr = event.schedualDate != null && event.schedualDate.length >= 10 ? event.schedualDate.substring(0, 10) : '';
    final eventAdjustedDateStr = event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10 ? event.lsnAdjustedDate.substring(0, 10) : '';

    final hasBeenRescheduled = event.lsnAdjustedDate != null && event.lsnAdjustedDate.isNotEmpty;
    final hasBeenSigned = event.scanQrDate != null && event.scanQrDate.isNotEmpty;

    final isScheduledUnsignedLsn = ((selectedDayStr == eventScheduleDateStr) && !hasBeenRescheduled && !hasBeenSigned);
    final isScheduledSignedLsn = ((selectedDayStr == eventScheduleDateStr) && !hasBeenRescheduled && hasBeenSigned);

    final isAdjustedUnSignedLsnFrom = ((selectedDayStr == eventScheduleDateStr) && hasBeenRescheduled && (selectedDayStr != eventAdjustedDateStr) && !hasBeenSigned);
    final isAdjustedSignedLsnFrom = ((selectedDayStr == eventScheduleDateStr) && hasBeenRescheduled && (selectedDayStr != eventAdjustedDateStr) && hasBeenSigned);

    final isAdjustedUnSignedLsnTo = ((selectedDayStr != eventScheduleDateStr) && hasBeenRescheduled && (selectedDayStr == eventAdjustedDateStr) && !hasBeenSigned);

    final isAdjustedSignedLsnTo = ((selectedDayStr != eventScheduleDateStr) && hasBeenRescheduled && (selectedDayStr == eventAdjustedDateStr) && hasBeenSigned);

    Color backgroundColor;
    Color textColor = Colors.black;
    String additionalInfo = '';

    if (isAdjustedUnSignedLsnFrom) {
      backgroundColor = Colors.grey.shade300;
      additionalInfo = '调课To：${event.lsnAdjustedDate}';
    } else if (isAdjustedSignedLsnFrom) {
      backgroundColor = Colors.grey.shade300;
      additionalInfo = '调课To：${event.lsnAdjustedDate}';
    } else if (isAdjustedUnSignedLsnTo) {
      backgroundColor = Colors.orange.shade100;
      additionalInfo = '调课From：${event.schedualDate}';
    } else if (isAdjustedSignedLsnTo) {
      backgroundColor = Colors.grey.shade500;
      additionalInfo = '调课From：${event.schedualDate}';
    } else if (isScheduledUnsignedLsn) {
      backgroundColor = Colors.blue.shade100;
    } else if (isScheduledSignedLsn) {
      backgroundColor = Colors.grey.shade500;
    } else {
      backgroundColor = Colors.black12;
    }

    TextDecoration textDecoration = TextDecoration.none;
    if (isScheduledSignedLsn || isAdjustedSignedLsnFrom || isAdjustedSignedLsnTo) {
      textDecoration = TextDecoration.lineThrough;
    }

    bool isGray = _isGrayBackground(event);
    bool isCurrentDragging = isDragging && draggedEvent?.lessonId == event.lessonId;

    return GestureDetector(
      onLongPressStart: (_) => _handleLongPressStart(event),
      onLongPressMoveUpdate: !isGray ? _handleDragUpdate : null,
      onLongPressEnd: !isGray ? _handleDragEnd : null,
      child: Transform.translate(
        offset: isCurrentDragging ? Offset(0, verticalOffset) : Offset.zero,
        child: Card(
          elevation: isCurrentDragging ? 8 : 2,
          margin: const EdgeInsets.only(left: 56, top: 4, bottom: 4, right: 8),
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isCurrentDragging ? const BorderSide(color: Colors.red, width: 2.0) : BorderSide.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.stuName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor, decoration: textDecoration),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${event.subjectName} - ${event.subjectSubName}',
                              style: TextStyle(fontSize: 12, color: textColor, decoration: textDecoration),
                            ),
                          ),
                          if (additionalInfo.isNotEmpty)
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Text(
                                  additionalInfo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${event.classDuration}分钟 | ${event.lessonType == 0 ? '课结算' : event.lessonType == 1 ? '月计划' : '月加课'}',
                              style: TextStyle(fontSize: 11, color: textColor, decoration: textDecoration),
                            ),
                          ),
                          if (event.memo != null && event.memo!.isNotEmpty)
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Text(
                                  '备注: ${event.memo}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (String result) {
                    switch (result) {
                      case '签到':
                        widget.onSign(event);
                        break;
                      case '撤销':
                        widget.onRestore(event);
                        break;
                      case '修改':
                        widget.onEdit(event);
                        break;
                      case '调课':
                        widget.onReschLsn(event);
                        break;
                      case '取消':
                        widget.onCancel(event);
                        break;
                      case '删除':
                        widget.onDelete(event);
                        break;
                      case '备注':
                        widget.onAddmemo(event);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if ((event.scanQrDate != null) && (event.scanQrDate.isNotEmpty)) {
                      if (DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()) == event.scanQrDate) {
                        return [
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
                        return [
                          const PopupMenuItem<String>(
                            value: '备注',
                            height: 36,
                            child: Text('备注', style: TextStyle(fontSize: 11.5)),
                          ),
                        ];
                      }
                    } else {
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
                      } else {
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: '签到',
                            enabled: !widget.selectedDay.isAfter(DateTime.now()),
                            height: 36,
                            child: Text('签到', style: TextStyle(fontSize: 11.5, color: widget.selectedDay.isAfter(DateTime.now()) ? Colors.grey : null)),
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
          ),
        ),
      ),
    );
  }
}
