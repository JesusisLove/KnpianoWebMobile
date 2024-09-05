// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../03StuDocMngmnt/4stuDoc/DurationBean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'Kn01L002LsnBean.dart';

class EditCourseDialog extends StatefulWidget {
  const EditCourseDialog({super.key, required this.lessonId});
  final String lessonId;

  @override
  _EditCourseDialogState createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  Kn01L002LsnBean? selectedStuLsn;
  List<DurationBean> durationList = [];
  int? selectedDuration;

  // 添加 TextEditingController
  late TextEditingController stuNameController;
  late TextEditingController subjectNameController;
  late TextEditingController subjectSubNameController;
  late TextEditingController lessonTypeController;

  @override
  void initState() {
    super.initState();
    // 初始化 controllers
    stuNameController = TextEditingController();
    subjectNameController = TextEditingController();
    subjectSubNameController = TextEditingController();
    lessonTypeController = TextEditingController();
    _fetchCourseData();
    fetchDurations();
  }

  @override
  void dispose() {
    // 释放 controllers
    stuNameController.dispose();
    subjectNameController.dispose();
    subjectSubNameController.dispose();
    lessonTypeController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourseData() async {
    try {
      final String apiStuLsnEditUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuLsnEdit}/${widget.lessonId}';
      final response = await http.get(Uri.parse(apiStuLsnEditUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> responseJson = json.decode(decodedBody);
        setState(() {
          selectedStuLsn = Kn01L002LsnBean.fromJson(responseJson);
          selectedDuration = selectedStuLsn?.classDuration;
          // 更新 controllers
          stuNameController.text = selectedStuLsn?.stuName ?? '';
          subjectNameController.text = selectedStuLsn?.subjectName ?? '';
          subjectSubNameController.text = selectedStuLsn?.subjectSubName ?? '';
          lessonTypeController.text = _getLessonTypeText(selectedStuLsn?.lessonType);
          }
        );
      } else {
        throw Exception('Failed to load course data');
      }
    } catch (e) {
      _showErrorDialog('加载课程数据失败: ${e.toString()}');
    }
  }

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

  Future<void> _saveCourse() async {
    final Map<String, dynamic> editStuLsn = {
      'lessonId': selectedStuLsn?.lessonId,
      'classDuration': selectedDuration,
    };

    try {
      final String apiLsnSaveUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnSave}';
      final response = await http.post(
        Uri.parse(apiLsnSaveUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(editStuLsn),
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
                      '编辑课程: ${selectedStuLsn?.schedualDate ?? ''}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: primaryColor, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              _buildTextField(
                label: '学生姓名',
                controller: stuNameController,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              _buildTextField(
                label: '科目名称',
                controller: subjectNameController,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              _buildTextField(
                label: '科目级别名称',
                controller: subjectSubNameController,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              _buildTextField(
                label: '上课种别',
                controller: lessonTypeController,
                readOnly: true,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
        ),
      ],
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
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }

  String _getLessonTypeText(int? lessonType) {
    switch (lessonType) {
      case 0:
        return '课结算';
      case 1:
        return '月计划';
      case 2:
        return '月加课';
      default:
        return '';
    }
  }
}