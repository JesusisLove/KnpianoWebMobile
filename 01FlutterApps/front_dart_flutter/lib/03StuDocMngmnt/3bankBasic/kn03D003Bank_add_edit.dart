// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'package:kn_piano/Constants.dart';
import 'package:kn_piano/CommonProcess/customUI/FormFields.dart';

import 'Kn03D003BnkBean.dart';

class BankAddEdit extends StatefulWidget {
  const BankAddEdit({super.key, this.bank, this.showMode});
  final Kn03D003BnkBean? bank;
  final String? showMode;
  @override
  _BankAddEditState createState() => _BankAddEditState();
}

class _BankAddEditState extends State<BankAddEdit> {
  
  String? bankId;
  String? bankName;
  int? delFlg;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final FocusNode _bankNameFocusNode = FocusNode();
  Color _bankNameColor = Colors.black;

  @override
  void initState() {
    super.initState();
    if (widget.bank != null) {
      bankId = widget.bank!.bankId;
      delFlg = widget.bank!.delFlg;
      _bankNameController.text = widget.bank!.bankName;
    }
    _bankNameFocusNode.addListener(() {
      setState(() => _bankNameColor = _bankNameFocusNode.hasFocus 
                                       ? Constants.stuDocThemeColor 
                                       : Colors.black);
    });
   }

  @override
  void dispose() {
    _bankNameController.dispose();
    _bankNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('银行信息（${widget.showMode}）'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FormFields.createTextFormField(
                inputFocusNode          : _bankNameFocusNode,
                inputLabelText          : '银行名称',
                inputLabelColor         : _bankNameColor,
                inputController         : _bankNameController,
                themeColor              : Constants.stuDocThemeColor,
                enabledBorderSideWidth  : Constants.enabledBorderSideWidth,
                focusedBorderSideWidth  : Constants.focusedBorderSideWidth,
                onSave: (value) =>  bankName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入银行名称';
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

      // 银行新规编辑画面，点击“保存”按钮的url请求
      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.bankAddEdit}';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'bankId': bankId,
          'bankName': bankName,
          'delFlg': delFlg,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提交成功'),
            content: const Text('银行信息已保存'),
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