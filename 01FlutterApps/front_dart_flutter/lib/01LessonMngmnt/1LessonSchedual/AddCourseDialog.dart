import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../03StuDocMngmnt/4stuDoc/DurationBean.dart';
import '../../03StuDocMngmnt/4stuDoc/Kn03D004StuDocBean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({Key? key, this.scheduleDate, this.scheduleTime}) : super(key: key);
  final String? scheduleDate;
  final String? scheduleTime;
  @override
  _AddCourseDialogState createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  String? selectedStudent;
  String? selectedSubject;
  String? subjectLevel;
  String? courseType;
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
      // Handle error
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
      // Handle error
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
      // Handle error
    }
  }

  void _updateSubjectInfo(dynamic selectedSubjectInfo) {
    setState(() {
      subjectLevel = selectedSubjectInfo['subjectSubName'];
      if (selectedSubjectInfo['payStyle'] == 0) {
        courseType = '课结算';
        isRadioEnabled = false;
      } else {
        courseType = '月计划';
        isRadioEnabled = true;
      }
      selectedDuration = selectedSubjectInfo['minutesPerLsn'];
    });
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
                              setState(() => courseType = value!);
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
                child: const Text('保存'),
                onPressed: () {
                  // 在这里处理保存逻辑
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}