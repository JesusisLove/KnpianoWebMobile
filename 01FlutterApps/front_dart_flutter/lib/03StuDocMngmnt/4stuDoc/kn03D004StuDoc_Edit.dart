// ignore_for_file: use_build_context_synchronously, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'DurationBean.dart';

class StudentDocumentEditPage extends StatefulWidget {
  final String stuId;
  final String subjectId;
  final String subjectSubId;
  final String adjustedDate;

  const StudentDocumentEditPage({
    Key? key,
    required this.stuId,
    required this.subjectId,
    required this.subjectSubId,
    required this.adjustedDate,
  }) : super(key: key);

  @override
  _StudentDocumentEditPageState createState() => _StudentDocumentEditPageState();
}

class _StudentDocumentEditPageState extends State<StudentDocumentEditPage> {
  late Future<void> _initialData;
  String stuName = '';
  String subjectName = '';
  String subjectSubName = '';
  List<DurationBean> duration = []; // 初始化为空列表
  bool isMonthlyPayment = true;
  int? payStyle;
  int? selectedDuration;
  double standardPrice = 0.0;
  TextEditingController adjustedPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDuration = null; // 确保初始化为 null
    _initialData = _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await fetchStudentInfo();
    await fetchDurations();
  }

  Future<void> fetchStudentInfo() async {
    final String apiStuDocUrl =
        '${KnConfig.apiBaseUrl}${Constants.stuDocInfoEdit}/${widget.stuId}/${widget.subjectId}/${widget.subjectSubId}/${widget.adjustedDate}';
    final response = await http.get(Uri.parse(apiStuDocUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> studentInfo = json.decode(decodedBody);
      setState(() {
        stuName = studentInfo['stuName'] ?? '';
        subjectName = studentInfo['subjectName'] ?? '';
        subjectSubName = studentInfo['subjectSubName'] ?? '';
        selectedDuration = studentInfo['minutesPerLsn'] ?? 0;
        standardPrice = studentInfo['lessonFee'] ?? 0.0;
        adjustedPriceController.text =
            (studentInfo['lessonFeeAdjusted'] ?? 0.0).toStringAsFixed(2);
        payStyle = studentInfo['payStyle'];
      });
    } else {
      throw Exception('Failed to load student info');
    }
  }

  Future<void> fetchDurations() async {
    final String apiLsnDurationUrl = '${KnConfig.apiBaseUrl}${Constants.stuDocLsnDuration}';
    final responseDuration = await http.get(Uri.parse(apiLsnDurationUrl));

    if (responseDuration.statusCode == 200) {
      final decodedBody = utf8.decode(responseDuration.bodyBytes);
      List<dynamic> durationJson = json.decode(decodedBody);
      setState(() {
        duration = durationJson.map((durationString) => DurationBean.fromString(durationString as String)).toList();
      });
    } else {
      throw Exception('Failed to load duration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学生档案编辑')),
      body: FutureBuilder<void>(
        future: _initialData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: stuName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '学生姓名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: subjectName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '科目名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: subjectSubName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '科目级别名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: widget.adjustedDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '调整日期',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('科目支付方式'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('按月付费'),
                          value: (payStyle == 1),
                          groupValue: isMonthlyPayment,
                          onChanged: (bool? value) {
                            setState(() {
                              payStyle = 1;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('课时付费'),
                          value: (payStyle == 0),
                          groupValue: isMonthlyPayment,
                          onChanged: (bool? value) {
                            setState(() {
                              payStyle = 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: '课程时长',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDuration,
                    items: duration.map((DurationBean durationBean) {
                      return DropdownMenuItem<int>(
                        value: durationBean.minutesPerLsn,
                        child: Text('${durationBean.minutesPerLsn} 分钟'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedDuration = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    initialValue: standardPrice.toStringAsFixed(2),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '标准价格',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: adjustedPriceController,
                    decoration: const InputDecoration(
                      labelText: '调整价格',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: saveData,
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> saveData() async {
    if (selectedDuration == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('输入错误'),
            content: const Text('请选择课程时长'),
            actions: <Widget>[
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    double? adjustedPriceValue = double.tryParse(adjustedPriceController.text);

    if (adjustedPriceValue == null || adjustedPriceValue < 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('输入错误'),
            content: const Text('请输入有效的调整价格'),
            actions: <Widget>[
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    Map<String, dynamic> data = {
      'stuId': widget.stuId,
      'subjectId': widget.subjectId,
      'subjectSubId': widget.subjectSubId,
      'adjustedDate': widget.adjustedDate,
      'payStyle': payStyle,
      'duration': selectedDuration,
      'lessonFee': standardPrice,
      'lessonFeeAdjusted': adjustedPriceValue,
      'minutesPerLsn':selectedDuration,
    };

    try {
      final response = await http.post(
        Uri.parse('${KnConfig.apiBaseUrl}${Constants.stuDocInfoSave}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('成功'),
              content: const Text('学生档案已成功保存。'),
              actions: <Widget>[
                TextButton(
                  child: const Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('错误'),
              content: Text('保存失败: ${response.body}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('确定'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('错误'),
            content: Text('发生错误: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }
}