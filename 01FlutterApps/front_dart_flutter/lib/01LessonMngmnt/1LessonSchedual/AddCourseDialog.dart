// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../03StuDocMngmnt/4stuDoc/DurationBean.dart';
import '../../03StuDocMngmnt/4stuDoc/Kn03D004StuDocBean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key, required this.scheduleDate, required this.scheduleTime});
  final String scheduleDate;
  final String scheduleTime;
  @override
  _AddCourseDialogState createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  String? selectedStudent;
  String? selectedSubject;
  String? subjectLevel;
  String? courseType;
  int? lessonType;
  int? selectedDuration;
  List<Kn03D004StuDocBean> stuDocList = [];
  List<dynamic> stuSubjectsList = [];
  List<DurationBean> durationList = [];
  bool isRadioEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    fetchDurations();
    // 初始化时设置courseType为null，表示所有radio按钮处于为选中状态
    courseType = null;
  }

  // 从档案表里取出入档案的学生初期化学生下拉列表框
  Future<void> _fetchStudentData() async {
    try {
      final String apiStuDocUrl = '${KnConfig.apiBaseUrl}${Constants.stuDocInfoView}';
      final response = await http.get(Uri.parse(apiStuDocUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> stuDocJson = json.decode(decodedBody);
        setState(() {
          stuDocList = stuDocJson.map((json) => Kn03D004StuDocBean.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load archived students');
      }
    } catch (e) {
      _showErrorDialog('加载学生数据失败: ${e.toString()}');
    }
  }

  // 从档案表里取入档案的学生最新的科目初期化科目下拉列表框
  Future<void> _fetchStudentSubjects(String stuId) async {
    try {
      final String apiLatestSubjectsnUrl = '${KnConfig.apiBaseUrl}${Constants.apiLatestSubjectsnUrl}/$stuId';
      final responseStuSubjects = await http.get(Uri.parse(apiLatestSubjectsnUrl));

      if (responseStuSubjects.statusCode == 200) {
        final decodedBody = utf8.decode(responseStuSubjects.bodyBytes);
        List<dynamic> responseStuSubjectsJson = json.decode(decodedBody);
        setState(() {
          stuSubjectsList = responseStuSubjectsJson;
          selectedSubject = null;
          subjectLevel = null;
          courseType = null;
          selectedDuration = null;
          isRadioEnabled = false;
        });
      } else {
        throw Exception('Failed to load archived subjects of the student');
      }
    } catch (e) {
      _showErrorDialog('加载学生科目失败: ${e.toString()}');
    }
  }

  // 从后端取出上课时长初期化上课时长下拉列表框
  Future<void> fetchDurations() async {
    try {
      final String apiLsnDruationUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnDruationUrl}';
      final response = await http.get(Uri.parse(apiLsnDruationUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> durationJson = json.decode(decodedBody);
        setState(() {
          durationList = durationJson.map((durationString) => DurationBean.fromString(durationString as String)).toList();
        });
      } else {
        throw Exception('Failed to load duration');
      }
    } catch (e) {
      _showErrorDialog('加载上课时长失败: ${e.toString()}');
    }
  }

  void _updateSubjectInfo(dynamic selectedSubjectInfo) {
    setState(() {
      subjectLevel = selectedSubjectInfo['subjectSubName'];
      if (selectedSubjectInfo['payStyle'] == 0) {
        courseType = '课结算';
        isRadioEnabled = false;
        lessonType = 0;
      } else {
        courseType = '月计划';
        isRadioEnabled = true;
        lessonType = 1;
      }
      selectedDuration = selectedSubjectInfo['minutesPerLsn'];
    });
  }

  bool _validateForm() {
    if (selectedStudent == null) {
      _showErrorDialog('请选择学生姓名');
      return false;
    }
    if (selectedSubject == null) {
      _showErrorDialog('请选择科目名称');
      return false;
    }
    if (selectedDuration == null) {
      _showErrorDialog('请选择上课时长');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('必须入力：'),
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

  Future<void> _saveCourse() async {
    if (!_validateForm()) return;

    final selectedStudentDoc = stuDocList.firstWhere((student) => student.stuName == selectedStudent);
    final selectedSubjectInfo = stuSubjectsList.firstWhere((subject) => subject['subjectName'] == selectedSubject);

    final Map<String, dynamic> courseData = {
      'stuId': selectedStudentDoc.stuId,
      'subjectId': selectedSubjectInfo['subjectId'],
      'subjectSubId': selectedSubjectInfo['subjectSubId'],
      'lessonType': lessonType,
      'classDuration': selectedDuration,
      'schedualDate': '${widget.scheduleDate} ${widget.scheduleTime}',

    };

    try {
      final String apiLsnSaveUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnSave}';
      final response = await http.post(
        Uri.parse(apiLsnSaveUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(courseData),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // Close dialog and indicate success
      } else {
        throw Exception('Failed to save course');
      }
    } catch (e) {
      _showErrorDialog('保存失败: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '添加课程:${widget.scheduleDate} ${widget.scheduleTime}', 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 0),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '学生姓名'),
              value: selectedStudent,
              onChanged: (value) {
                setState(() {
                  selectedStudent = value;
                  selectedSubject = null;
                  subjectLevel = null;
                  courseType = null;
                  isRadioEnabled = false;
                });
                if (value != null) {
                  final selectedStudentDoc = stuDocList.firstWhere((student) => student.stuName == value);
                  _fetchStudentSubjects(selectedStudentDoc.stuId);
                }
              },
              items: stuDocList.map((student) => DropdownMenuItem(
                value: student.stuName,
                child: Text(student.stuName ?? ''),
              )).toList(),
            ),
            const SizedBox(height: 0),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '科目名称'),
              value: selectedSubject,
              onChanged: (value) {
                setState(() => selectedSubject = value);
                if (value != null) {
                  final selectedSubjectInfo = stuSubjectsList.firstWhere(
                    (subject) => subject['subjectName'] == value,
                    orElse: () => null,
                  );
                  if (selectedSubjectInfo != null) {
                    _updateSubjectInfo(selectedSubjectInfo);
                  }
                }
              },
              items: stuSubjectsList.map((subject) => DropdownMenuItem(
                value: subject['subjectName'] as String,
                child: Text(subject['subjectName'] as String),
              )).toList(),
            ),
            const SizedBox(height: 0),

            TextFormField(
              decoration: const InputDecoration(labelText: '科目级别名称'),
              controller: TextEditingController(text: subjectLevel),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            const Text('上课种别', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['课结算', '月计划', '月加课'].map((type) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: type,
                      groupValue: courseType,
                      onChanged: (isRadioEnabled && type != '课结算') || (courseType == '课结算' && type == '课结算')
                          ? (String? value) {
                              setState(() {
                                courseType = value!;
                                // 根据上课种别设定该当值
                                if (type == '课结算') {
                                  lessonType = 0;
                                } else if (type == '月计划') {
                                  lessonType = 1;
                                } else if (type == '月加课') {
                                  lessonType = 2;
                                }
                              });
                            }
                          : null,
                    ),
                    Text(type),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 0),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: '上课时长'),
              value: selectedDuration,
              onChanged: (value) => setState(() => selectedDuration = value),
              items: durationList.map((DurationBean durationBean) => DropdownMenuItem(
                value: durationBean.minutesPerLsn,
                child: Text('${durationBean.minutesPerLsn} 分钟'),
              )).toList(),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // ignore: sort_child_properties_last
                child: const Text('保存'),
                onPressed: _saveCourse,
              ),
            ),
          ],
        ),
      ),
    );
  }
}