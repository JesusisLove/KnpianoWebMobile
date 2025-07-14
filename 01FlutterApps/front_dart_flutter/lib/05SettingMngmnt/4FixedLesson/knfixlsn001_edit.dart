// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';
import 'KnFixLsn001Bean.dart';

class ScheduleFormEdit extends StatefulWidget {
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;
  final KnFixLsn001Bean? lesson;

  ScheduleFormEdit({
    super.key,
    this.lesson,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  ScheduleFormEditState createState() => ScheduleFormEditState();
}

class ScheduleFormEditState extends State<ScheduleFormEdit> {
  final _formKey = GlobalKey<FormState>();
  String titleName = "学生固定排课（編集）";
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
      appBar: KnAppBar(
        title: titleName,
        subtitle: '${widget.pagePath} >> $titleName',
        context: context,
        appBarBackgroundColor: widget.knBgColor, // 自定义AppBar背景颜色
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义标题颜色
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),

        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义底部文本框背景颜色
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),

        subtitleTextColor: Colors.white, // 自定义底部文本颜色
        titleFontSize: 20.0, // 自定义标题字体大小
        subtitleFontSize: 12.0, // 自定义底部文本字体大小
        addInvisibleRightButton: false, // 显示Home按钮返回主菜单
        currentNavIndex: 4,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 修改: 将内容左对齐
            children: <Widget>[
              // 修改: 添加标签和间距
              const Text('学生姓名',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // 修改: 更新DropdownButtonFormField的样式
              DropdownButtonFormField<String>(
                value: selectedStudent,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                onChanged: null,
                items: [
                  DropdownMenuItem<String>(
                    value: selectedStudent,
                    child: Text(selectedStudent!),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // 修改: 添加标签和间距
              const Text('科目名称',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // 修改: 更新DropdownButtonFormField的样式
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                onChanged: null,
                items: [
                  DropdownMenuItem<String>(
                    value: selectedSubject,
                    child: Text(selectedSubject!),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // 修改: 添加标签和间距
              const Text('固定星期几',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // 修改: 更新DropdownButtonFormField的样式
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                onChanged: null,
                items: [
                  DropdownMenuItem<String>(
                    value: selectedDay,
                    child: Text(selectedDay!),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // 修改: 将时间选择放在同一行
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('固定在几点',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedHour,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              selectedHour = newValue;
                            });
                          },
                          validator: (value) => value == null ? '请选择几点' : null,
                          items: hours
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('固定在几分',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedMinute,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              selectedMinute = newValue;
                            });
                          },
                          validator: (value) => value == null ? '请选择几分' : null,
                          items: minutes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 修改: 更新保存按钮的样式
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: widget.knBgColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text('保存', style: TextStyle(fontSize: 18)),
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
                  Text('正在更新固定排课处理...'),
                ],
              ),
            ),
          );
        },
      );
      _formKey.currentState!.save();
      // 学生固定排课编辑画面，点击"保存"按钮的url请求
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoEdit}';

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
