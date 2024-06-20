import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({super.key});

  @override
  ScheduleFormState createState() => ScheduleFormState();
}

class ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();

  String? selectedStuId;
  String? selectedSubId;
  String? selectedStudent;
  String? selectedSubject;
  String? selectedDay;
  String? selectedHour;
  String? selectedMinute;

  // WeekDays初期化
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // 只要从早08点到22点之间到时间 
  List<String> hours = List.generate(15, (index) => (index + 8).toString().padLeft(2, '0'));
  List<String> minutes = ['00', '15', '30', '45'];

  // 存储从API获取的数据
  List<dynamic> rawData = [];

  // 存储处理后的学生列表和科目列表
  Map<String, String> stuNameList = {};
  Map<String, List<Map<String, String>>> subjectsByStudent = {};

  // 画面初期化
  @override
  void initState() {
    super.initState();
    fetchLessons(); // 在初始化时调用fetchLessons，并将结果存储在futureFixLsnList中
  }

  Future<void> fetchLessons() async {
    try {
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.fixeDocStuSubInfoGet}';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(utf8.decode(response.bodyBytes));
        Map<String, List<Map<String, String>>> tempSubjects = {};
        for (var data in rawData) {
          String stuId = data['stuId'];
          String stuName = data['stuName'].trim();
          String subjectId = data['subjectId'];
          String subjectName = data['subjectName'].trim();
          if (!stuNameList.containsKey(stuId)) {
            stuNameList[stuId] = stuName;
          }
          if (!tempSubjects.containsKey(stuId)) {
            tempSubjects[stuId] = [];
          }
          tempSubjects[stuId]?.add({'subjectId': subjectId, 'subjectName': subjectName});
        }
        setState(() {
          subjectsByStudent = tempSubjects;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("学生固定排课（新規）")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedStuId,
                hint: const Text('学生姓名'),
                onChanged: (newValue) {
                  setState(() {
                    selectedStuId = newValue;
                    selectedSubId = null;  // Reset subject when student changes
                  });
                },
                validator: (value) => value == null ? '请选择要排课的学生' : null,
                items: stuNameList.entries
                .map<DropdownMenuItem<String>>((MapEntry<String, String> entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
              ),

              DropdownButtonFormField<String>(
                value: selectedSubId,
                hint: const Text('科目名称'),
                onChanged: (newValue) {
                  setState(() {
                    // selectedSubject = newValue;
                    selectedSubId = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择要排课的科目' : null,
                items: selectedStuId == null
                ? []
                : subjectsByStudent[selectedStuId]!.map<DropdownMenuItem<String>>((Map<String, String> subject) {
                    return DropdownMenuItem<String>(
                      value: subject['subjectId'],
                      child: Text(subject['subjectName']!),
                    );
                  }
                ).toList(),
              ),

              DropdownButtonFormField<String>(
                value: selectedDay,
                hint: const Text('固定星期几'),
                onChanged: (newValue) {
                  setState(() {
                    selectedDay = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择星期几' : null,
                items: days.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              DropdownButtonFormField<String>(
                value: selectedHour,
                hint: const Text('固定在几点'),
                onChanged: (newValue) {
                  setState(() {
                    selectedHour = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择几点' : null,
                items: hours.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            
              DropdownButtonFormField<String>(
                value: selectedMinute,
                hint: const Text('固定在几分'),
                onChanged: (newValue) {
                  setState(() {
                    selectedMinute = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择几分' : null,
                items: minutes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('保存'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // 学生固定排课新规登录画面，点击“保存”按钮的url请求
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoAdd}';
    
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'stuId'       : selectedStuId,
          'subjectId'   : selectedSubId,
          'fixedWeek'   : selectedDay,
          'fixedHour'   : selectedHour,
          'fixedMinute' : selectedMinute,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提交成功'),
            content: const Text('固定排课时间已提交'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // 直接退回到一览画面
                  Navigator.of(context).pop(); // 关闭对话框
                  Navigator.of(context).pop(true); // 关闭当前页面并返回成功标识
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提交失败'),
            content: Text('错误: ${response.body}'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }
}
   