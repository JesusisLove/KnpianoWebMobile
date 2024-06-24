// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';

class BankStuAddEdit extends StatefulWidget {
  const BankStuAddEdit({super.key, this.bankId, this.showMode});
  final String? bankId;
  final String? showMode;
  @override
  _BankStuAddEditState createState() => _BankStuAddEditState();
}

class _BankStuAddEditState extends State<BankStuAddEdit> {
  String? bankId;
  String? stuId;
  String? stuName;
  int? delFlg;

  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _students = [];
  Map<String, dynamic>? _selectedStudent;

  @override
  void initState() {
    super.initState();
    bankId = widget.bankId;
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.studentInfoView}';
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        _students = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      });
    } else {
      // Handle error
      print("Error fetching students: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用该银行学生（${widget.showMode}）'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedStudent,
                items: _students.map((student) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: student,
                    child: Text(student['stuName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStudent = value;
                    stuId = value?['stuId']; // Set the selected student ID
                    stuName = value?['stuName']; // Set the selected student name
                  });
                },
                decoration: const InputDecoration(
                  labelText: '学生姓名',
                  labelStyle: TextStyle(color: Constants.stuDocThemeColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Constants.stuDocThemeColor,
                      width: Constants.enabledBorderSideWidth,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Constants.stuDocThemeColor,
                      width: Constants.focusedBorderSideWidth,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择学生姓名';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 科目新规编辑画面，点击“保存”按钮的url请求
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.stuBankAdd}';
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'bankId': bankId,
          'stuId': stuId,
          'stuName': stuName,
          'delFlg': delFlg,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提交成功'),
            content: const Text('科目信息已保存'),
            actions: <Widget>[
              TextButton(
                onPressed: () => {
                  // 直接退回到一览画面
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

mixin toDouble {}
