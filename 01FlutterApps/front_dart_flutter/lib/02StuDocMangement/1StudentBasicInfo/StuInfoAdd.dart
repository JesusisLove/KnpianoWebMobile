/// 学生入学管理 

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 引入 intl 包来格式化日期
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';// API配置文件
import 'package:kn_piano/CommonProcess/FormFields.dart';// 共通控件作成（所有窗体控件统一标准）
import 'package:kn_piano/Constants.dart'; // 引入包含全局常量的文件


class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  StudentInfoScreenState createState() => StudentInfoScreenState();
}

class StudentInfoScreenState extends State<StudentInfoScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController(); // 控制器用于管理日期输入

  String? stuName;
  String? gender;
  String? birthday;
  List<String?> telephones = List.filled(4, null);
  String? address;
  String? postCode;
  String? introducer;

  final FocusNode _stuNameFocusNode = FocusNode();
  final FocusNode _genderFocusNode = FocusNode();
  final FocusNode _birthdayFocusNode = FocusNode();
  final List<FocusNode?> _telephonesNode = List.filled(4, null);
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _postCodeFocusNode = FocusNode();
  final FocusNode _introducerFocusNode = FocusNode();

  Color _stuNameColor = Colors.black;
  Color _genderColor = Colors.black;
  Color _birthdayColor = Colors.black;

  final List<Color> _telephonesColor = List.generate(4, (_) => Colors.black);

  Color _addressColor = Colors.black;
  Color _postCodeColor = Colors.black;
  Color _introducerColor = Colors.black;

  @override
  void initState() {
    super.initState();

    // 获得焦点时的标签字体颜色
    _stuNameFocusNode.addListener(() {
      setState(() => _stuNameColor = _stuNameFocusNode.hasFocus ? Constants.stuDocThemeColor : Colors.black);
    });
    _genderFocusNode.addListener(() {
      setState(() => _genderColor = _genderFocusNode.hasFocus ? Constants.stuDocThemeColor : Colors.black);
    });
    _birthdayFocusNode.addListener(() {
      setState(() => _birthdayColor = _birthdayFocusNode.hasFocus ? Constants.stuDocThemeColor : Colors.black);
    });
    // 初始化电话号码的 FocusNode
    for (int i = 0; i < _telephonesNode.length; i++) {
      _telephonesNode[i] = FocusNode();
      _telephonesNode[i]!.addListener(() {
        setState(() => _telephonesColor[i] = _telephonesNode[i]!.hasFocus ? Constants.stuDocThemeColor : Colors.black);
      });
    }
    _addressFocusNode.addListener(() {
      setState(() => _addressColor = _addressFocusNode.hasFocus ? Constants.stuDocThemeColor : Colors.black);
    });
    _postCodeFocusNode.addListener(() {
      setState(() => _postCodeColor = _postCodeFocusNode.hasFocus ? Constants.stuDocThemeColor : Colors.black);
    });
    _introducerFocusNode.addListener(() {
      setState(() => _introducerColor = _introducerFocusNode.hasFocus ? Constants.stuDocThemeColor : Colors.black);
    });
  }

  @override
  void dispose() {
    // 释放控制器资源
    _birthdayController.dispose(); 
    _stuNameFocusNode.dispose();
    _genderFocusNode.dispose();
    _birthdayFocusNode.dispose();

    for (var node in _telephonesNode) {
      node!.removeListener(() {});
      node.dispose();
    }
    _addressFocusNode.dispose();
    _postCodeFocusNode.dispose();
    _introducerFocusNode.dispose();
    super.dispose();
  }

  // 日期选择处理
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
        title: const Text("学生信息登录"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FormFields.createTextFormField(
                inputFocusNode: _stuNameFocusNode,
                inputLabelText: '学生姓名',
                inputLabelColor: _stuNameColor,
                themeColor: Constants.stuDocThemeColor, 
                enabledBorderSideWidth: Constants.enabledBorderSideWidth, 
                focusedBorderSideWidth: Constants.focusedBorderSideWidth,
                onSave: (value) => stuName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入学生姓名';
                  }
                  return null;
                }, 
              ),
              
              DropdownButtonFormField<String>(
                focusNode: _genderFocusNode,
                value: gender,
                decoration: InputDecoration(
                  labelText: '学生性别',
                  labelStyle: TextStyle(color: _genderColor),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Constants.stuDocThemeColor, 
                                           width: Constants.enabledBorderSideWidth),  // 未聚焦时的边框颜色
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Constants.stuDocThemeColor, 
                                           width: Constants.focusedBorderSideWidth),  // 聚焦时的边框颜色
                  ),
                ),
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

              FormFields.createTextFormField(
                inputFocusNode: _birthdayFocusNode,
                inputController: _birthdayController, // 使用控制器
                inputLabelText: '出生日',
                inputLabelColor: _birthdayColor,
                themeColor: Constants.stuDocThemeColor, 
                enabledBorderSideWidth: Constants.enabledBorderSideWidth, 
                focusedBorderSideWidth: Constants.focusedBorderSideWidth,
                blnReadOnly: true, // 设置为只读
                onTap: () => _selectDate(context), // 点击时调用日期选择器
                onSave: (value) => birthday = value,
              ),

              ...List.generate(4, (index) => FormFields.createTextFormField(
                  inputFocusNode: _telephonesNode[index]!,
                  inputLabelText: '联系电话${index + 1}',
                  inputLabelColor: _telephonesColor[index],
                  themeColor: Constants.stuDocThemeColor, 
                  enabledBorderSideWidth: Constants.enabledBorderSideWidth, 
                  focusedBorderSideWidth: Constants.focusedBorderSideWidth,
                  onSave: (value) => telephones[index] = value,
                )
              ),

              FormFields.createTextFormField(
                inputFocusNode: _postCodeFocusNode,
                inputLabelText: '邮政编号',
                inputLabelColor: _postCodeColor,
                themeColor: Constants.stuDocThemeColor, 
                enabledBorderSideWidth: Constants.enabledBorderSideWidth, 
                focusedBorderSideWidth: Constants.focusedBorderSideWidth,
                onSave: (value) => postCode = value,
              ),

              FormFields.createTextFormField(
                inputFocusNode: _addressFocusNode,
                inputLabelText: '家庭住址',
                inputLabelColor: _addressColor,
                themeColor: Constants.stuDocThemeColor, 
                enabledBorderSideWidth: Constants.enabledBorderSideWidth, 
                focusedBorderSideWidth: Constants.focusedBorderSideWidth,
                onSave: (value) => address = value,
              ),

              FormFields.createTextFormField(
                themeColor: Constants.stuDocThemeColor, 
                enabledBorderSideWidth: Constants.enabledBorderSideWidth, 
                focusedBorderSideWidth: Constants.focusedBorderSideWidth,
                inputFocusNode: _introducerFocusNode,
                inputLabelText: '介绍人',
                inputLabelColor: _introducerColor,
                onSave: (value) => introducer = value,
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

  // 点击保存按钮
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 学生档案菜单画面，点击“保存”按钮的url请求
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.studentInfoAdd}';
    
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
