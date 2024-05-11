import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'KnFixLsn001Bean.dart';

class ScheduleFormEdit extends StatefulWidget {
  final KnFixLsn001Bean? lesson;
  const ScheduleFormEdit({super.key, this.lesson});

  @override
  ScheduleFormEditState createState() => ScheduleFormEditState();
}

class ScheduleFormEditState extends State<ScheduleFormEdit> {
  final _formKey = GlobalKey<FormState>();

  String? selectedStuId;
  String? selectedSubId;
  String? selectedStudent;
  String? selectedSubject;
  String? selectedDay;
  String? selectedHour;
  String? selectedMinute;

  // 只要从早08点到22点之间到时间 
  List<String> hours = List.generate(15, (index) => (index + 8).toString().padLeft(2, '0'));
  List<String> minutes = ['00', '15', '30', '45'];

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      selectedStuId = widget.lesson!.studentId;
      selectedSubId = widget.lesson!.subjectId;
      selectedStudent = widget.lesson!.studentName;
      selectedSubject = widget.lesson!.subjectName;
      selectedDay = widget.lesson!.fixedWeek;
      // 设置时间
      selectedHour = widget.lesson!.classTime.split(':')[0];
      selectedMinute = widget.lesson!.classTime.split(':')[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("学生固定排课（編集）")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedStudent,
                hint: const Text('学生姓名'),
                onChanged: null,
                items: [DropdownMenuItem<String>(
                  value: selectedStudent,
                  child: Text(selectedStudent!),
                )],
              ),

              DropdownButtonFormField<String>(
                value: selectedSubject,
                hint: const Text('科目名称'),
                onChanged: null,
                items: [DropdownMenuItem<String>(
                  value: selectedSubject,
                  child: Text(selectedSubject!),
                )],
              ),

              DropdownButtonFormField<String>(
                value: selectedDay,
                hint: const Text('固定星期几'),
                onChanged: null,
                items: [DropdownMenuItem<String>(
                  value: selectedDay,
                  child: Text(selectedDay!),
                )],
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
      // 学生固定排课编辑画面，点击“保存”按钮的url请求
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoEdit}';
    
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
            title: const Text('更新成功'),
            content: const Text('固定排课时间已更新'),
            actions: <Widget>[
              TextButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                  Navigator.of(context).pop(true) // 关闭当前页面并返回成功标识
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
   