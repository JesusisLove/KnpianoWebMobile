// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';

// ignore: must_be_immutable
class ScheduleForm extends StatefulWidget {
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;
  ScheduleForm({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  ScheduleFormState createState() => ScheduleFormState();
}

class ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  String titleName = "学生固定排课（新規）";

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
  List<String> hours =
      List.generate(15, (index) => (index + 8).toString().padLeft(2, '0'));
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
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.fixeDocStuSubInfoGet}';
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
          tempSubjects[stuId]
              ?.add({'subjectId': subjectId, 'subjectName': subjectName});
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
      appBar: KnAppBar(
        title: titleName,
        subtitle: '${widget.pagePath} >> $titleName',
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha,
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha,
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        addInvisibleRightButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedStuId,
                decoration: const InputDecoration(labelText: '学生姓名'),
                items: stuNameList.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedStuId = newValue;
                    selectedStudent = stuNameList[newValue];
                    selectedSubId = null;
                    selectedSubject = null;
                  });
                },
                validator: (value) => value == null ? '请选择学生' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSubId,
                decoration: const InputDecoration(labelText: '科目名称'),
                items: selectedStuId != null
                    ? subjectsByStudent[selectedStuId]?.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject['subjectId'],
                          child: Text(subject['subjectName']!),
                        );
                      }).toList()
                    : [],
                onChanged: (newValue) {
                  setState(() {
                    selectedSubId = newValue;
                    selectedSubject = subjectsByStudent[selectedStuId]
                        ?.firstWhere((subject) =>
                            subject['subjectId'] == newValue)['subjectName'];
                  });
                },
                validator: (value) => value == null ? '请选择科目' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: '固定星期几'),
                items: days.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedDay = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择星期' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedHour,
                      decoration: const InputDecoration(labelText: '固定在几点'),
                      items: hours.map((String hour) {
                        return DropdownMenuItem<String>(
                          value: hour,
                          child: Text(hour),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedHour = newValue;
                        });
                      },
                      validator: (value) => value == null ? '请选择小时' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMinute,
                      decoration: const InputDecoration(labelText: '固定在几分'),
                      items: minutes.map((String minute) {
                        return DropdownMenuItem<String>(
                          value: minute,
                          child: Text(minute),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedMinute = newValue;
                        });
                      },
                      validator: (value) => value == null ? '请选择分钟' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: widget.knBgColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 显示进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在添加固定排课处理...'),
                ],
              ),
            ),
          );
        },
      );
      _formKey.currentState!.save();
      // 学生固定排课新规登录画面，点击“保存”按钮的url请求
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoAdd}';

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'stuId': selectedStuId,
            'subjectId': selectedSubId,
            'fixedWeek': selectedDay,
            'fixedHour': selectedHour,
            'fixedMinute': selectedMinute,
          }),
        );

        // 关闭进度对话框
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('提交成功'),
              content: const Text('固定排课时间已提交'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        } else {
          throw Exception('Failed to submit data');
        }
      } catch (e) {
        // 如果发生错误，确保关闭进度对话框
        if (mounted) {
          Navigator.of(context).pop(); // 关闭进度对话框
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提交失败'),
            content: Text('发生错误: $e'),
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
