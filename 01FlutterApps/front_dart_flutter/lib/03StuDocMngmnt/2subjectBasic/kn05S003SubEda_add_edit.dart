// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:kn_piano/CommonProcess/customUI/FormFields.dart';

import 'Kn05S003SubjectEdabnBean.dart';

class SubjectEdaAddEdit extends StatefulWidget {
  const SubjectEdaAddEdit({super.key, this.subjectId, this.subjectEda, this.showMode});
  final String                    ? subjectId;
  final Kn05S003SubjectEdabnBean  ? subjectEda;
  final String                    ? showMode;
  @override
  _SubjectEdaAddEditState createState() => _SubjectEdaAddEditState();
}

class _SubjectEdaAddEditState extends State<SubjectEdaAddEdit> {

  String? subjectId;
  String? subjectSubId;
  String? subjectSubName;
  double? subjectPrice;
  int   ? delFlg;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectEdaSubNameController  = TextEditingController();
  final TextEditingController _subjectEdaPriceController    = TextEditingController();
  final FocusNode _subjectEdaSubNameFocusNode               = FocusNode();
  final FocusNode _subjectEdaPriceFocusNode                 = FocusNode();
  Color _subjectEdaSubNameColor                             = Colors.black;
  Color _subjectEdaPriceColor                               = Colors.black;

  @override
  void initState() {
    super.initState();
    // 编辑模式下的变量初期化
    if (widget.subjectEda != null) {
      // 上一级画面传递进来的数据，初始化该页面模块变量
      subjectId = widget.subjectEda!.subjectId;

      subjectSubId    = widget.subjectEda!.subjectSubId;
      subjectSubName  = widget.subjectEda!.subjectId;
      subjectPrice    = widget.subjectEda!.subjectPrice;

      delFlg = widget.subjectEda!.delFlg;
      _subjectEdaSubNameController.text   = widget.subjectEda!.subjectSubName;
      _subjectEdaPriceController.text     = widget.subjectEda!.subjectPrice.toStringAsFixed(2);
    } 
    // 新规模式下的变量初期化
    else {
      subjectId= widget.subjectId;
    }

    _subjectEdaSubNameFocusNode.addListener(() {
      setState(() => _subjectEdaSubNameColor = _subjectEdaSubNameFocusNode.hasFocus 
                                             ? Constants.stuDocThemeColor 
                                             : Colors.black);
    });

    _subjectEdaPriceFocusNode.addListener(() {
      setState(() => _subjectEdaPriceColor = _subjectEdaPriceFocusNode.hasFocus 
                                           ? Constants.stuDocThemeColor 
                                           : Colors.black);
    });
   }

  @override
  void dispose() {
    _subjectEdaSubNameController.dispose();
    _subjectEdaSubNameFocusNode.dispose();

    _subjectEdaPriceController.dispose();
    _subjectEdaPriceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('科目级别信息（${widget.showMode}）'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FormFields.createTextFormField(
                inputFocusNode          : _subjectEdaSubNameFocusNode,
                inputLabelText          : '科目级别名称',
                inputLabelColor         : _subjectEdaSubNameColor,
                inputController         : _subjectEdaSubNameController,
                themeColor              : Constants.stuDocThemeColor,
                enabledBorderSideWidth  : Constants.enabledBorderSideWidth,
                focusedBorderSideWidth  : Constants.focusedBorderSideWidth,
                onSave: (value) =>  subjectSubName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入科目级别名称';
                  }
                  return null;
                },
              ),

              FormFields.createTextFormField(
                inputFocusNode          : _subjectEdaPriceFocusNode,
                inputLabelText          : '科目价格',
                inputLabelColor         : _subjectEdaPriceColor,
                inputController         : _subjectEdaPriceController,
                themeColor              : Constants.stuDocThemeColor,
                enabledBorderSideWidth  : Constants.enabledBorderSideWidth,
                focusedBorderSideWidth  : Constants.focusedBorderSideWidth,
                // onSave: (value) =>  subjectPrice = value as double?,
                onSave: (value) {
                  if (value != null && value.isNotEmpty) {
                    subjectPrice = double.tryParse(value);
                  } else {
                    subjectPrice = null;
                  }
                },

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入该科目价格';
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
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.subjectEdaAdd}';
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'subjectId'     : subjectId,
          'subjectSubId'  : subjectSubId,
          'subjectSubName': subjectSubName,
          'subjectPrice'  : subjectPrice,
          'delFlg'        : delFlg,
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

mixin toDouble {
}