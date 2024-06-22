// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:kn_piano/CommonProcess/FormFields.dart';

import 'KnSub001Bean.dart';

class SubjectAddEdit extends StatefulWidget {
  const SubjectAddEdit({super.key, this.subject, this.showMode});
  final KnSub001Bean? subject;
  final String? showMode;
  @override
  _SubjectAddEditState createState() => _SubjectAddEditState();
}

class _SubjectAddEditState extends State<SubjectAddEdit> {
  
  String? subjectId;
  String? subjectName;
  int? delFlg;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectNameController = TextEditingController();
  final FocusNode _subjectNameFocusNode = FocusNode();
  Color _subjectNameColor = Colors.black;

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      subjectId = widget.subject!.subjectId;
      delFlg = widget.subject!.delFlg;
      _subjectNameController.text = widget.subject!.subjectName;
    }
    _subjectNameFocusNode.addListener(() {
      setState(() => _subjectNameColor = _subjectNameFocusNode.hasFocus 
                                       ? Constants.stuDocThemeColor 
                                       : Colors.black);
    });
   }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('科目信息（${widget.showMode}）'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FormFields.createTextFormField(
                inputFocusNode          : _subjectNameFocusNode,
                inputLabelText          : '科目名称',
                inputLabelColor         : _subjectNameColor,
                inputController         : _subjectNameController,
                themeColor              : Constants.stuDocThemeColor,
                enabledBorderSideWidth  : Constants.enabledBorderSideWidth,
                focusedBorderSideWidth  : Constants.focusedBorderSideWidth,
                onSave: (value) =>  subjectName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入科目名称';
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
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.subjectInfoAdd}';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'subjectId': subjectId,
          'subjectName': subjectName,
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