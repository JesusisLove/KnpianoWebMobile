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
    final primaryColor = Colors.green.shade600;
    final backgroundColor = Colors.green.shade50;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '添加课程:${widget.scheduleDate} ${widget.scheduleTime}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: primaryColor, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              _buildDropdown(
                label: '学生姓名',
                value: selectedStudent,
                items: stuDocList.map((student) => DropdownMenuItem(
                  value: student.stuName,
                  child: Text(student.stuName),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStudent = value as String?;
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
              ),

              _buildDropdown(
                label: '科目名称',
                value: selectedSubject,
                items: stuSubjectsList.map((subject) => DropdownMenuItem(
                  value: subject['subjectName'] as String,
                  child: Text(subject['subjectName'] as String),
                )).toList(),
                onChanged: (value) {
                  setState(() => selectedSubject = value as String?);
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
              ),

              _buildTextField(
                label: '科目级别名称',
                controller: TextEditingController(text: subjectLevel),
                readOnly: true,
              ),

              const SizedBox(height: 10),
              Text('上课种别', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['课结算', '月计划', '月加课'].map((type) {
                  return _buildRadioButton(type, primaryColor);
                }).toList(),
              ),

              const SizedBox(height: 10),
              _buildDropdown(
                label: '上课时长',
                value: selectedDuration,
                items: durationList.map((DurationBean durationBean) => DropdownMenuItem(
                  value: durationBean.minutesPerLsn,
                  child: Text('${durationBean.minutesPerLsn} 分钟'),
                )).toList(),
                onChanged: (value) => setState(() => selectedDuration = value as int?),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _saveCourse,
                  child: const Text('保存', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
              dropdownColor: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green.shade600),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRadioButton(String type, Color primaryColor) {
    return InkWell(
      onTap: () {
        if ((isRadioEnabled && type != '课结算') || (courseType == '课结算' && type == '课结算')) {
          setState(() {
            courseType = type;
            if (type == '课结算') {
              lessonType = 0;
            } else if (type == '月计划') {
              lessonType = 1;
            } else if (type == '月加课') {
              lessonType = 2;
            }
          });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: type,
            groupValue: courseType,
            onChanged: (isRadioEnabled && type != '课结算') || (courseType == '课结算' && type == '课结算')
                ? (String? value) {
                    setState(() {
                      courseType = value!;
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
            activeColor: primaryColor,
          ),
          Text(type, style: TextStyle(color: Colors.green.shade700)),
        ],
      ),
    );
  }
}