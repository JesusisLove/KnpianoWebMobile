import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'dart:convert';

class RescheduleLessonDialog extends StatefulWidget {
  final String lessonId;

  const RescheduleLessonDialog({super.key, required this.lessonId});

  @override
  // ignore: library_private_types_in_public_api
  _RescheduleLessonDialogState createState() => _RescheduleLessonDialogState();
}

class _RescheduleLessonDialogState extends State<RescheduleLessonDialog> {
  DateTime? selectedDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('将该课调至'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择日期：'),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: '选择日期',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('选择时间：'),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: '选择时间',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  controller: TextEditingController(text: selectedTime.format(context)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRescheduledLesson,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // 点击保存按钮
void _saveRescheduledLesson() {
  // 直接使用 TimeOfDay 的 hour 和 minute 属性
  final selectedHour = selectedTime.hour;
  final selectedMinute = selectedTime.minute;

  // 验证小时在08-21点以内
  if (selectedHour < 8 || selectedHour > 21) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请选择有效的时间段从8点-21点')),
    );
    return;
  }

  // 验证分钟只有（00.15，30，45）有效
  if (![0, 15, 30, 45].contains(selectedMinute)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('有效的分钟只有00，15，30，45')),
    );
    return;
  }

  // 格式化日期和时间
  final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
  final lsnAdjustedDate = '${DateFormat('yyyy-MM-dd').format(selectedDate!)} $formattedTime';

  final Map<String, dynamic> adjustedStuLsn = {
    'lessonId': widget.lessonId,
    'lsnAdjustedDate': lsnAdjustedDate,
  };

  _saveLesson(adjustedStuLsn);
}

Future<void> _saveLesson(Map<String, dynamic> lessonData) async {
  try {
    final String apiLsnSaveUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnSave}';
    final response = await http.post(
      Uri.parse(apiLsnSaveUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(lessonData),
    );

    if (response.statusCode == 200) {
      // Close the current screen and return to the previous one
      Navigator.of(context).pop(true);
    } else {
      throw Exception('Failed to save lesson');
    }
  } catch (e) {
    _showErrorDialog('保存失败: ${e.toString()}');
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}