// StudentInfo.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 引入 intl 包来格式化日期
import 'package:my_first_app/ConfigAPI/KnConfig.dart';// API配置文件

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController(); // 控制器用于管理日期输入

  String? stuName;
  String? gender;
  String? birthday;
  List<String?> telephones = List.filled(4, null);
  String? address;
  String? postCode;
  String? introducer;

  @override
  void initState() {
    super.initState();
    initConfig();
  }

  // 一次性加载配置信息
  void initConfig() async {
    await KnConfig.load();
  }

  @override
  void dispose() {
    _birthdayController.dispose(); // 释放控制器资源
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthday != null ? DateFormat('yyyy/MM/dd').parse(birthday!) : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthday = DateFormat('yyyy/MM/dd').format(picked);
        _birthdayController.text = birthday!; // 更新文本字段内容
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("学生信息登陆"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: '学生姓名'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入学生姓名';
                  }
                  return null;
                },
                onSaved: (value) => stuName = value,
              ),
              
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: '学生性别'),
                items: const [
                  DropdownMenuItem<String>(
                    value: '1',  // 用于提交的值为1
                    child: Text('男'),  // 显示为“男”
                  ),
                  DropdownMenuItem<String>(
                    value: '2',  // 用于提交的值为2
                    child: Text('女'),  // 显示为“女”
                  )
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue;
                  });
                },
                validator: (String? value) => value == null ? '请选择性别' : null,
              ),
              TextFormField(
                controller: _birthdayController, // 使用控制器
                decoration: const InputDecoration(labelText: '出生日'),
                readOnly: true, // 设置为只读
                onTap: () => _selectDate(context), // 点击时调用日期选择器
                onSaved: (value) => birthday = value,
              ),
              ...List.generate(4, (index) => TextFormField(
                decoration: InputDecoration(labelText: '联系电话${index + 1}'),
                onSaved: (value) => telephones[index] = value,
              )),
              TextFormField(
                decoration: const InputDecoration(labelText: '家庭住址'),
                onSaved: (value) => address = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '邮政编号'),
                onSaved: (value) => postCode = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '介绍人'),
                onSaved: (value) => introducer = value,
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

      final String apiUrl = '${KnConfig.apiBaseUrl}/liu/kn_stu_001_add';
    
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'stuName'    : stuName,
            'gender'     : gender,
            'birthday'   : birthday,
            'tel1'       : telephones.isNotEmpty ? telephones[0] : null,
            'tel2'       : telephones.isNotEmpty ? telephones[1] : null,
            'tel3'       : telephones.isNotEmpty ? telephones[2] : null,
            'tel4'       : telephones.isNotEmpty ? telephones[3] : null,
            'address'    : address,
            'postCode'   : postCode,
            'introducer' : introducer,
          }),
        );
    
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提交成功'),
            content: const Text('学生信息已提交'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
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
