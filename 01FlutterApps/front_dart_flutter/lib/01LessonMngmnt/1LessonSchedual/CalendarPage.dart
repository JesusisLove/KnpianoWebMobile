// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../CommonProcess/customUI/KnLoadingIndicator.dart';
import 'AddCourseDialog.dart';
import 'EditCourseDialog.dart';
import 'Kn01L002LsnBean.dart';
import 'RescheduleLessonDialog.dart';
import 'package:flutter/rendering.dart';

// 调课对话框组件
class RescheduleLessonTimeDialog extends StatefulWidget {
  final DateTime initialDate;
  final String initialTime;
  final Function(String) onSave;

  const RescheduleLessonTimeDialog({
    super.key,
    required this.initialDate,
    required this.initialTime,
    required this.onSave,
  });

  @override
  _RescheduleLessonTimeDialogState createState() =>
      _RescheduleLessonTimeDialogState();
}

class _RescheduleLessonTimeDialogState
    extends State<RescheduleLessonTimeDialog> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    final timeParts = widget.initialTime.split(':');
    selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
  }

  bool _isValidTime(TimeOfDay time) {
    if (time.hour < 8 || time.hour > 22) return false;
    return [0, 15, 30, 45].contains(time.minute);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && _isValidTime(picked)) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                const Text(
                  '将该课调至',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('选择日期：'),
            const SizedBox(height: 8),
            AbsorbPointer(
              absorbing: true,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: '选择日期',
                  suffixIcon:
                      const Icon(Icons.calendar_today, color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(widget.initialDate),
                ),
                enabled: false,
              ),
            ),
            const SizedBox(height: 24),
            const Text('选择时间：'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '选择时间',
                    suffixIcon: const Icon(Icons.access_time),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  controller: TextEditingController(
                    text:
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE091A0),
                  minimumSize: const Size(120, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final String newTime =
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                  try {
                    await widget.onSave(newTime); // 调用保存回调函数
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('保存失败: $e')),
                      );
                    }
                    rethrow;
                  }
                },
                child: const Text(
                  '保存',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final String focusedDay;
  final String? stuId;
  const CalendarPage({super.key, required this.focusedDay, this.stuId});
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String? highlightedStuId; // 新增
  final ScrollController _scrollController = ScrollController(); // 新增
  Timer? _highlightTimer; // 新增

  bool _isLoading = false; // 添加加载状态变量

  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  String? currentHighlightedTime;

  List<Kn01L002LsnBean> studentLsns = [];

  @override
  @override
  void initState() {
    super.initState();
    _focusedDay = DateFormat('yyyy-MM-dd').parse(widget.focusedDay);
    _selectedDay = _focusedDay;

    // 设置初始状态
    if (widget.focusedDay.contains(' ')) {
      final time = widget.focusedDay.split(' ')[1].substring(0, 5);
      setState(() {
        currentHighlightedTime = time;
        highlightedStuId = widget.stuId;
      });

      // 设置10秒后清除高亮状态
      _highlightTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            currentHighlightedTime = null;
            highlightedStuId = null;
          });
        }
      });
    }

    // 获取指定日期的课程数据
    _fetchStudentLsn(widget.focusedDay.split(' ')[0].trim());

    // 等待布局完成后滚动到目标位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTargetTime();
    });
  }

  // 新增：滚动到目标时间位置
  void _scrollToTargetTime() {
    if (widget.focusedDay.contains(' ')) {
      final targetTime = widget.focusedDay.split(' ')[1].substring(0, 5);
      final targetHour = int.parse(targetTime.split(':')[0]);
      final targetMinute = int.parse(targetTime.split(':')[1]);

      // 计算目标位置
      final index = ((targetHour - 8) * 4) + (targetMinute ~/ 15);
      final targetPosition = index * 60.0; // 假设每个时间格的高度约为60

      // 计算滚动位置，使目标位置位于屏幕中间
      final screenHeight = MediaQuery.of(context).size.height;
      final offset =
          math.max(0, targetPosition - (screenHeight / 2)).toDouble();

      // 滚动到目标位置
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // 新增：清理定时器
  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudentLsn(String schedualDate) async {
    // 开始加载，设置加载状态为true
    setState(() {
      _isLoading = true;
    });

    try {
      final String apilsnInfoByDayUrl =
          '${KnConfig.apiBaseUrl}${Constants.lsnInfoByDay}/$schedualDate';
      final response = await http.get(Uri.parse(apilsnInfoByDayUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> responseStuLsnsJson = json.decode(decodedBody);
        if (mounted) {
          // 检查组件是否仍然挂载
          setState(() {
            studentLsns = responseStuLsnsJson
                .map((json) => Kn01L002LsnBean.fromJson(json))
                .toList();
            _isLoading = false; // 加载完成，设置加载状态为false
          });
        }
      } else {
        throw Exception('Failed to load archived lessons of the day');
      }
    } catch (e) {
      print('Error fetching current-day\'s lessons data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // 出错时也要结束加载状态
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据出错: $e')),
        );
      }
    }
  }

  // 长按课程卡片弹出的对话框画面，点击“保存”，执行时间更新
  Future<void> _updateLessonTime(
      String lessonId, String newTime, bool isRescheduledLesson) async {
    // 选中的课程表日期
    final String selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    // 设置当天的调换时间
    final Map<String, dynamic> courseData = {
      'lessonId': lessonId,
      // 如果是调课From的课程，则将schedualDate，设置schedualDate为空
      'schedualDate': isRescheduledLesson ? '' : '$selectedDate $newTime',
      // 如果是调课From的课程，把调课时间设置给lsnAdjustedDate
      'lsnAdjustedDate': isRescheduledLesson ? '$selectedDate $newTime' : '',
    };

    try {
      final String updateUrl =
          '${KnConfig.apiBaseUrl}${Constants.apiUpdateLessonTime}';
      final response = await http.post(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
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
      String eventScheduleDateStr =
          event.schedualDate != null && event.schedualDate.length >= 10
              ? event.schedualDate.substring(0, 10)
              : '';
      String eventTime1 =
          event.schedualDate != null && event.schedualDate.length >= 16
              ? event.schedualDate.substring(11, 16)
              : '';

      String eventAdjustedDateStr =
          event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10
              ? event.lsnAdjustedDate.substring(0, 10)
              : '';
      String eventTime2 =
          event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 16
              ? event.lsnAdjustedDate.substring(11, 16)
              : '';

      return (eventScheduleDateStr == selectedDateStr && eventTime1 == time) ||
          (eventAdjustedDateStr == selectedDateStr && eventTime2 == time);
    }).toList();
  }

  void _handleTimeSelection(BuildContext context, String time) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
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

  // //课程的修改功能暂时不要了 2025/02/08 先暂时保留，不要删除
  // void _handleEditCourse(Kn01L002LsnBean event) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return EditCourseDialog(lessonId: event.lessonId);
  //     },
  //   ).then((result) {
  //     if (result == true) {
  //       setState(() {
  //         _fetchStudentLsn(DateFormat('yyyy-MM-dd').format(_selectedDay));
  //       });
  //     }
  //   });
  // }

  void _handleSignCourse(Kn01L002LsnBean event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('执行签到确认'),
          content: Text(
              '签到【${event.subjectName}】这节课，\n当日之内可以撤销，过了今日撤销不可！\n您确定要签到吗？'),
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
                final String signUrl =
                    '${KnConfig.apiBaseUrl}${Constants.apiStuLsnSign}/${event.lessonId}';
                try {
                  final response = await http.get(
                    Uri.parse(signUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchStudentLsn(
                          DateFormat('yyyy-MM-dd').format(_selectedDay));
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
                final String signUrl =
                    '${KnConfig.apiBaseUrl}${Constants.apiStuLsnRestore}/${event.lessonId}';
                try {
                  final response = await http.get(
                    Uri.parse(signUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchStudentLsn(
                          DateFormat('yyyy-MM-dd').format(_selectedDay));
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
              child: RescheduleLessonDialog(
                stuId: event.stuId,
                subjectId: event.subjectId,
                lessonId: event.lessonId,
                lessonType: event.lessonType,
                schedualDate: event.schedualDate,
                classDuration: event.classDuration,
              ),
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
                final String deleteUrl =
                    '${KnConfig.apiBaseUrl}${Constants.apiLsnRescheCancel}/${event.lessonId}';
                try {
                  final response = await http.post(
                    Uri.parse(deleteUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchStudentLsn(
                          DateFormat('yyyy-MM-dd').format(_selectedDay));
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
                final String deleteUrl =
                    '${KnConfig.apiBaseUrl}${Constants.apiLsnDelete}/${event.lessonId}';
                try {
                  final response = await http.delete(
                    Uri.parse(deleteUrl),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchStudentLsn(
                          DateFormat('yyyy-MM-dd').format(_selectedDay));
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

    // 创建一个TextEditingController并设置初始值和光标位置
    final TextEditingController _controller =
        TextEditingController(text: noteContent)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: noteContent.length),
          );

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
                controller: _controller,
                maxLines: 3,
                // 添加以下属性以支持IME输入
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                // 确保支持多语言输入
                enableInteractiveSelection: true,
                // 设置输入装饰
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请输入备注内容',
                  // 添加内边距使文本不会太靠边
                  contentPadding: EdgeInsets.all(12),
                ),
                // 修改onChanged处理方式
                onChanged: (value) {
                  noteContent = value;
                  setDialogState(() {
                    hasContent = value.trim().isNotEmpty;
                  });
                },
                // 添加文本样式
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasContent ? Colors.pink[100] : Colors.grey[300],
                    ),
                    onPressed: hasContent
                        ? () async {
                            try {
                              final String memoUrl =
                                  '${KnConfig.apiBaseUrl}${Constants.apiStuLsnMemo}/${event.lessonId}';
                              final response = await http.post(
                                Uri.parse(memoUrl),
                                headers: {
                                  'Content-Type':
                                      'application/json; charset=utf-8', // 确保指定正确的字符集
                                },
                                body: json.encode({
                                  'memo': noteContent,
                                  'lessonId': event.lessonId,
                                }),
                              );
                              final responseData =
                                  json.decode(utf8.decode(response.bodyBytes));
                              if (response.statusCode == 200 &&
                                  responseData['status'] == 'success') {
                                Navigator.of(dialogContext).pop();
                                _fetchStudentLsn(DateFormat('yyyy-MM-dd')
                                    .format(_selectedDay));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('备注更新成功'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '备注更新失败: ${responseData['message'] ?? '未知错误'}'),
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
        addInvisibleRightButton: false,
      ),
      body: Column(
        children: [
          // 日历部分始终显示
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
              startingDayOfWeek: StartingDayOfWeek.monday, // 星期排列从Mon开始
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

          // 日期标题部分始终显示
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              DateFormat('yyyy年MM月dd日').format(_selectedDay),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 课程时间轴部分，包含加载状态
          Expanded(
            child: Stack(
              children: [
                // 时间轴内容
                ListView.builder(
                  controller: _scrollController,
                  itemCount: ((22 - 8) * 4), // 从8点到22点，每小时4个时间段
                  itemBuilder: (context, index) {
                    int hour = 8 + (index ~/ 4);
                    int minute = (index % 4) * 15;
                    String time =
                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                    // 始终显示时间轴，但只在不加载时显示事件
                    if (!_isLoading) {
                      return TimeTile(
                        key: ValueKey(time),
                        time: time,
                        events: getSchedualLessonForTime(time),
                        onTap: () => _handleTimeSelection(context, time),
                        onSign: _handleSignCourse,
                        onRestore: _handleRestoreCourse,
                        // onEdit: _handleEditCourse,
                        highlightedStuId: highlightedStuId,
                        onDelete: _handleDeleteCourse,
                        onReschLsn: _handleReschLsnCourse,
                        onCancel: _handleCancelRescheCourse,
                        onAddmemo: _handleNoteCourse,
                        selectedDay: _selectedDay,
                        onTimeChanged: _updateLessonTime,
                        highlightedTime: currentHighlightedTime,
                        onHighlightChanged: (time) {
                          setState(() {
                            currentHighlightedTime = time;
                          });
                        },
                      );
                    } else {
                      // 加载时只显示时间轴，不显示事件
                      return GestureDetector(
                        onTap: () {}, // 加载时禁用点击
                        child: Container(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: time.endsWith(':00')
                                        ? Text(
                                            time,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black,
                                            ),
                                          )
                                        : RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: time.substring(0, 3),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
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
                                          ),
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
                          ),
                        ),
                      );
                    }
                  },
                ),

                // 加载指示器覆盖在时间轴上
                if (_isLoading)
                  const Center(
                    // child: CircularProgressIndicator(),
                    child: KnLoadingIndicator(
                        color: Constants.lessonThemeColor), // 使用自定的加载器进度条
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TimeTile Widget 的定义
class TimeTile extends StatefulWidget {
  final String time;
  final List<Kn01L002LsnBean> events;
  final VoidCallback onTap;
  final Function(Kn01L002LsnBean) onSign;
  final Function(Kn01L002LsnBean) onRestore;
  // final Function(Kn01L002LsnBean) onEdit; 废弃课程的修改处理
  final Function(Kn01L002LsnBean) onDelete;
  final Function(Kn01L002LsnBean) onReschLsn;
  final Function(Kn01L002LsnBean) onCancel;
  final Function(Kn01L002LsnBean) onAddmemo;
  final DateTime selectedDay;
  final Function(String, String, bool) onTimeChanged;
  final String? highlightedTime;
  final Function(String) onHighlightChanged;
  final String? highlightedStuId; // 新增

  const TimeTile({
    super.key,
    required this.time,
    this.events = const [],
    required this.onTap,
    required this.onSign,
    required this.onRestore,
    // required this.onEdit,
    required this.onDelete,
    required this.onReschLsn,
    required this.onCancel,
    required this.onAddmemo,
    required this.selectedDay,
    required this.onTimeChanged,
    required this.highlightedTime,
    required this.onHighlightChanged,
    this.highlightedStuId, // 新增
  });

  @override
  _TimeTileState createState() => _TimeTileState();
}

class _TimeTileState extends State<TimeTile>
    with SingleTickerProviderStateMixin {
  GlobalKey timeLineKey = GlobalKey();
  String? pressedLessonId;
  Timer? _blinkTimer;
  late AnimationController _fadeController; // 动画控制器，控制动画
  late Animation<double> _fadeAnimation; // 动画显示课程卡片外缘显示红色，然后颜色消失
  bool _isSaving = false; // 新增：保存状态标志

  // 修改高亮判断逻辑
  bool _isHighlighted(Kn01L002LsnBean event) {
    final bool timeMatches = widget.time == widget.highlightedTime;
    final bool stuIdMatches = event.stuId == widget.highlightedStuId;
    return timeMatches && stuIdMatches;
  }

  @override
  void initState() {
    super.initState();
    // 动画初期化
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);
    // 如果该课程卡片需要高亮显示，启动闪烁动画
    if (widget.events.isNotEmpty) {
      for (var event in widget.events) {
        if (_isHighlighted(event)) {
          _startBlinking();
          break;
        }
      }
    }
  }

// 添加闪烁控制方法
  void _startBlinking() {
    // 取消已存在的闪烁
    _blinkTimer?.cancel();

    // 重置控制器状态
    _fadeController.value = 1.0;

    // 每500毫秒闪烁一次，持续10秒（总共闪烁20次）
    int blinkCount = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && blinkCount < 20) {
        setState(() {
          _fadeController.value = _fadeController.value == 0 ? 1.0 : 0.0;
        });
        blinkCount++;
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _fadeController.value = 0.0; // 确保动画结束时边框消失
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel(); // 确保在销毁时取消计时器
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimeTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查事件列表是否发生变化
    bool eventsChanged = widget.events.length != oldWidget.events.length;
    if (!eventsChanged && widget.events.isNotEmpty) {
      for (int i = 0; i < widget.events.length; i++) {
        if (widget.events[i].lessonId != oldWidget.events[i].lessonId) {
          eventsChanged = true;
          break;
        }
      }
    }

    // 当高亮状态发生改变或事件列表发生变化时，触发动画
    if (widget.events.isNotEmpty &&
        (widget.highlightedTime != oldWidget.highlightedTime ||
            widget.highlightedStuId != oldWidget.highlightedStuId ||
            eventsChanged)) {
      for (var event in widget.events) {
        if (_isHighlighted(event)) {
          _startBlinking();
          break;
        }
      }
    }
  }

  // 修改：调整长按处理逻辑
  void _handleLongPressStart(Kn01L002LsnBean event) async {
    if (!_isGrayBackground(event)) {
      await HapticFeedback.heavyImpact();
      setState(() {
        pressedLessonId = event.lessonId;
        _isSaving = false;
      });
      _fadeController.reset();

      // 获取当前卡片所在的时间位置
      final String currentTime = widget.time; // 直接使用时间轴上的时间
      // 判断是否有调课From
      final isRescheduledLesson = (event.lsnAdjustedDate.isNotEmpty == true);

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return RescheduleLessonTimeDialog(
            initialDate: widget.selectedDay,
            initialTime: currentTime, // 使用时间轴上的时间
            onSave: (String newTime) async {
              try {
                setState(() {
                  _isSaving = true;
                });
                await widget.onTimeChanged(
                    event.lessonId, newTime, isRescheduledLesson);
                return true;
              } catch (e) {
                setState(() {
                  _isSaving = false;
                });
                rethrow;
              }
            },
          );
        },
      );

      if (result == true && mounted) {
        // 保存成功，开始2秒计时后执行渐变动画
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && _isSaving) {
            _fadeController.forward().then((_) {
              if (mounted) {
                setState(() {
                  pressedLessonId = null;
                  _isSaving = false;
                });
              }
            });
          }
        });
      } else {
        // 取消或关闭对话框，直接清除状态
        if (mounted) {
          setState(() {
            pressedLessonId = null;
            _isSaving = false;
          });
        }
      }
    }
  }

  void _handleLongPressEnd() {
    // 长按结束时不立即清除边框
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

    return ((selectedDayStr == eventScheduleDateStr) && hasBeenRescheduled) ||
        ((selectedDayStr == eventScheduleDateStr) && hasBeenSigned) ||
        ((selectedDayStr == eventAdjustedDateStr) && hasBeenSigned);
  }

  @override
  Widget build(BuildContext context) {
    bool isHighlighted = widget.time == widget.highlightedTime;
    return GestureDetector(
      // 将GestureDetector移到最外层
      onTap: widget.onTap,
      child: Container(
        // 这是是设置时间槽的背景颜色
        // color: isHighlighted ? Colors.red[100] : Colors.transparent,
        child: widget.events.isEmpty
            ? _buildTimeLine()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      key: timeLineKey,
                      child: _buildTimeLine(),
                    ),
                    ...widget.events
                        .map((event) => _buildEventTile(context, event)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTimeLine() {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 0, right: 0),
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

  Widget _buildTimeText() {
    final isFullHour = widget.time.endsWith(':00');
    const backgroundColor = Colors.white;

    if (isFullHour) {
      return Text(
        widget.time,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.time.substring(0, 3),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: widget.time.substring(3),
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

  Widget _buildEventTile(BuildContext context, Kn01L002LsnBean event) {
    final selectedDayStr = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    final eventScheduleDateStr =
        event.schedualDate != null && event.schedualDate.length >= 10
            ? event.schedualDate.substring(0, 10)
            : '';
    final eventAdjustedDateStr =
        event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10
            ? event.lsnAdjustedDate.substring(0, 10)
            : '';
    final hasBeenRescheduled =
        event.lsnAdjustedDate != null && event.lsnAdjustedDate.isNotEmpty;

    final hasBeenSigned =
        event.scanQrDate != null && event.scanQrDate.isNotEmpty;

    final isScheduledUnsignedLsn = selectedDayStr == eventScheduleDateStr &&
        !hasBeenRescheduled &&
        !hasBeenSigned;

    final isScheduledSignedLsn = selectedDayStr == eventScheduleDateStr &&
        !hasBeenRescheduled &&
        hasBeenSigned;

    final isAdjustedUnSignedLsnFrom = selectedDayStr == eventScheduleDateStr &&
        hasBeenRescheduled &&
        selectedDayStr != eventAdjustedDateStr &&
        !hasBeenSigned;

    final isAdjustedSignedLsnFrom = selectedDayStr == eventScheduleDateStr &&
        hasBeenRescheduled &&
        selectedDayStr != eventAdjustedDateStr &&
        hasBeenSigned;

    final isAdjustedUnSignedLsnTo = selectedDayStr != eventScheduleDateStr &&
        hasBeenRescheduled &&
        selectedDayStr == eventAdjustedDateStr &&
        !hasBeenSigned;

    final isAdjustedSignedLsnTo = selectedDayStr != eventScheduleDateStr &&
        hasBeenRescheduled &&
        selectedDayStr == eventAdjustedDateStr &&
        hasBeenSigned;

    Color backgroundColor;
    Color textColor = Colors.black;
    String additionalInfo = '';

    if (isAdjustedUnSignedLsnFrom || isAdjustedSignedLsnFrom) {
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
    if (isScheduledSignedLsn ||
        isAdjustedSignedLsnFrom ||
        isAdjustedSignedLsnTo) {
      textDecoration = TextDecoration.lineThrough;
    }
    return GestureDetector(
      onLongPressStart: (_) => _handleLongPressStart(event),
      onLongPressEnd: (_) => _handleLongPressEnd(),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(left: 56, top: 4, bottom: 4, right: 8),
        // 设置课程卡片的背景颜色
        color: _isHighlighted(event) ? Colors.red[100] : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: _isHighlighted(event) // 修改这里的判断条件
              ? BorderSide(
                  color: Colors.red.withOpacity(_fadeAnimation.value),
                  width: 2.0,
                )
              : (pressedLessonId == event.lessonId && _isSaving
                  ? BorderSide(
                      color: Colors.red.withOpacity(_fadeAnimation.value),
                      width: 2.0,
                    )
                  : BorderSide.none),
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: child!,
            );
          },
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        decoration: textDecoration,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${event.subjectName} - ${event.subjectSubName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              decoration: textDecoration,
                            ),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              decoration: textDecoration,
                            ),
                          ),
                        ),
                        if (event.memo != null &&
                            event.memo!.isNotEmpty &&
                            (!isAdjustedUnSignedLsnTo &&
                                !isAdjustedSignedLsnTo))
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Text(
                                '备注: ${event.memo}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
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
                    // case '修改':
                    //   widget.onEdit(event);
                    //   break;
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
                itemBuilder: (BuildContext context) =>
                    _buildPopupMenuItems(event),
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
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(Kn01L002LsnBean event) {
    if ((event.scanQrDate != null) && (event.scanQrDate.isNotEmpty)) {
      if (DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()) ==
          event.scanQrDate) {
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
    }

    // 检查是否为已调课但未签到的课程
    final selectedDayStr = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    final eventScheduleDateStr =
        event.schedualDate != null && event.schedualDate.length >= 10
            ? event.schedualDate.substring(0, 10)
            : '';
    final eventAdjustedDateStr =
        event.lsnAdjustedDate != null && event.lsnAdjustedDate.length >= 10
            ? event.lsnAdjustedDate.substring(0, 10)
            : '';

    final hasBeenRescheduled = event.lsnAdjustedDate?.isNotEmpty ?? false;
    final hasBeenSigned = event.scanQrDate?.isNotEmpty ?? false;

    final isAdjustedUnSignedLsnFrom = selectedDayStr == eventScheduleDateStr &&
        hasBeenRescheduled &&
        selectedDayStr != eventAdjustedDateStr &&
        !hasBeenSigned;

    if (isAdjustedUnSignedLsnFrom) {
      return <PopupMenuEntry<String>>[
        // const PopupMenuItem<String>(
        //   value: '修改',
        //   height: 36,
        //   child: Text('修改', style: TextStyle(fontSize: 11.5)),
        // ),
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
          child: Text(
            '签到',
            style: TextStyle(
                fontSize: 11.5,
                color: widget.selectedDay.isAfter(DateTime.now())
                    ? Colors.grey
                    : null),
          ),
        ),
        const PopupMenuDivider(height: 1),
        // const PopupMenuItem<String>(
        //   value: '修改',
        //   height: 36,
        //   child: Text('修改', style: TextStyle(fontSize: 11.5)),
        // ),
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
}
