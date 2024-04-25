// StudentInfo.dart
import 'package:flutter/material.dart';

class StudentInfoScreen extends StatefulWidget {
  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? stuName;
  String? gender;
  String? birthday;
  List<String?> telephones = List.filled(4, null);
  String? address;
  String? postCode;
  String? introducer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("学生信息登陆"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '学生姓名'),
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
                decoration: InputDecoration(labelText: '学生性别'),
                items: <String>['男', '女', '其他'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    gender = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择性别' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '出生日'),
                onSaved: (value) => birthday = value,
              ),
              ...List.generate(4, (index) => TextFormField(
                decoration: InputDecoration(labelText: '联系电话${index + 1}'),
                onSaved: (value) => telephones[index] = value,
              )),
              TextFormField(
                decoration: InputDecoration(labelText: '家庭住址'),
                onSaved: (value) => address = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '邮政编号'),
                onSaved: (value) => postCode = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '介绍人'),
                onSaved: (value) => introducer = value,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('登陆'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提交成功'),
          content: Text('学生姓名: $stuName\n性别: $gender\n出生日: $birthday\n联系电话: ${telephones.join(', ')}\n家庭住址: $address\n邮政编号: $postCode\n介绍人: $introducer'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }
}
