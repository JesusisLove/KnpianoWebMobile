// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import '../2subjectBasic/Kn05S003SubjectEdabnBean.dart';
import '../2subjectBasic/KnSub001Bean.dart';
import 'DurationBean.dart';

class StudentDocumentPage extends StatefulWidget {
  final String? stuId;
  final String? stuName;
  const StudentDocumentPage({super.key, required this.stuId, required this.stuName});

  @override
  // ignore: library_private_types_in_public_api
  _StudentDocumentPageState createState() => _StudentDocumentPageState();
}

class _StudentDocumentPageState extends State<StudentDocumentPage> {

  List<KnSub001Bean>              subjects = [];
  List<Kn05S003SubjectEdabnBean>  subjectSubs = [];
  List<DurationBean> ?            duration = [];
  KnSub001Bean?                   selectedSubject;
  Kn05S003SubjectEdabnBean?       selectedSubjectSub;
  DateTime ?                      adjustmentDate = DateTime.now();
  bool                            isMonthlyPayment = true;
  int ?                           selectedDuration;
  double                          standardPrice = 0.0;
  TextEditingController           adjustedPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects();
    fetchDurations();
  }

  // 获取科目信息，初始化下拉列表框 
  Future<void> fetchSubjects() async {
    final String apiStuDocUrl = '${KnConfig.apiBaseUrl}${Constants.subjectView}';
    final responseSubject = await http.get(Uri.parse(apiStuDocUrl));

    if (responseSubject.statusCode == 200) {
      final decodedBody = utf8.decode(responseSubject.bodyBytes);
      List<dynamic> subjectJson = json.decode(decodedBody);
      setState(() {
        subjects = subjectJson.map((json) => KnSub001Bean.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  // 获取科目下的科目级别信息，初始化下拉列表框 
  Future<void> fetchSubjectSubs(String subjectId) async {
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.subjectEdaView}/$subjectId';
    final responseSubject = await http.get(Uri.parse(apiUrl));

    if (responseSubject.statusCode == 200) {
      final decodedBody = utf8.decode(responseSubject.bodyBytes);
      final List<dynamic> subjectSubsJson = json.decode(decodedBody);

      setState(() {
        subjectSubs = subjectSubsJson.map((json) => Kn05S003SubjectEdabnBean.fromJson(json)).toList();
        selectedSubjectSub = null;
      });
    } else {
      throw Exception('Failed to load subject subs');
    }
  }

  // 取得学生上1节课的分钟时长，初始化下拉列表框 
  Future<void> fetchDurations() async {
    final String apiLsnDruationUrl = '${KnConfig.apiBaseUrl}${Constants.stuDocLsnDuration}';
    final responseDuration = await http.get(Uri.parse(apiLsnDruationUrl));

    if (responseDuration.statusCode == 200) {
      final decodedBody = utf8.decode(responseDuration.bodyBytes);
      List<dynamic> durationJson = json.decode(decodedBody);
      setState(() {
        /* 后端Java层的duration的数据类型时List<Stirng>,而此处的前端的duration的数据类型时List<DurationBean>,
           为了保持前端与后端实体Bean对象的一致性做了特殊处理
        */
        duration = durationJson.map((durationString) => DurationBean.fromString(durationString as String)).toList();
      });
    } else {
      throw Exception('Failed to load duration');
    }
  }

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<KnSub001Bean>(
      decoration: const InputDecoration(
        labelText: '科目名称',
        border: OutlineInputBorder(),
      ),
      value: selectedSubject,
      items: subjects.map((KnSub001Bean subject) {
        return DropdownMenuItem<KnSub001Bean>(
          value: subject,
          child: Text(subject.subjectName),
        );
      }).toList(),
      onChanged: (KnSub001Bean? newValue) {
        setState(() {
          selectedSubject = newValue;
          if (newValue != null) {
            fetchSubjectSubs(newValue.subjectId);
          }
        });
      },
    );
  }

  Widget _buildSubjectSubDropdown() {
    return DropdownButtonFormField<Kn05S003SubjectEdabnBean>(
      decoration: const InputDecoration(
        labelText: '科目级别名称',
        border: OutlineInputBorder(),
      ),
      value: selectedSubjectSub,
      items: subjectSubs.map((Kn05S003SubjectEdabnBean subjectSub) {
        return DropdownMenuItem<Kn05S003SubjectEdabnBean>(
          value: subjectSub,
          child: Text(subjectSub.subjectSubName),
        );
      }).toList(),
      onChanged: (Kn05S003SubjectEdabnBean? newValue) {
        setState(() {
          selectedSubjectSub = newValue;
          standardPrice = newValue?.subjectPrice ?? 0.0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学生档案追加')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: widget.stuName,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '学生姓名',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
              minLines: 1,
            ),
            const SizedBox(height: 8),
            _buildSubjectDropdown(),
            const SizedBox(height: 8),
            _buildSubjectSubDropdown(),
            const SizedBox(height: 8),

            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: adjustmentDate.toString().split(' ')[0]),
              decoration: const InputDecoration(
                labelText: '调整日付',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              maxLines: 1,
              minLines: 1,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: adjustmentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != adjustmentDate) {
                  setState(() {
                    adjustmentDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            const Text('科目支付区分'),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('按月付费'),
                    value: true,
                    groupValue: isMonthlyPayment,
                    onChanged: (bool? value) {
                      setState(() {
                        isMonthlyPayment = value ?? true;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('课时付费'),
                    value: false,
                    groupValue: isMonthlyPayment,
                    onChanged: (bool? value) {
                      setState(() {
                        isMonthlyPayment = value ?? false;
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
              items: duration?.map((DurationBean durationBean) {
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
              readOnly: true,
              controller: TextEditingController(text: standardPrice.toStringAsFixed(2)),
              decoration: const InputDecoration(
                labelText: '标准价格',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
              minLines: 1,
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: adjustedPriceController,
              decoration: const InputDecoration(
                labelText: '调整价格',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLines: 1,
              minLines: 1,
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              child: const Text('保存'),
              onPressed: () {
                List<String> missingFields = [];

                if (selectedSubject == null) {
                  missingFields.add('科目名称');
                }
                if (selectedSubjectSub == null) {
                  missingFields.add('科目级别名称');
                }
                if (adjustmentDate == null) {
                  missingFields.add('调整日期');
                }
                if (selectedDuration == null) {
                  missingFields.add('课程时长');
                }

                if (missingFields.isNotEmpty) {
                  // 显示错误消息，列出具体缺少的字段
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('输入错误'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('请填写以下必填项:'),
                            const SizedBox(height: 10),
                            ...missingFields.map((field) => Text('• $field')).toList(),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('确定'),
                            onPressed: () => {
                              Navigator.of(context).pop(),
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // 所有必填项都已填写，继续保存操作
                  saveData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

Future<void> saveData() async {
  // 准备要发送的数据
  Map<String, dynamic> data = {
    'stuId': widget.stuId,
    'subjectId': selectedSubject?.subjectId,
    'subjectSubId': selectedSubjectSub?.subjectSubId,
    'adjustedDate': adjustmentDate?.toIso8601String().split('T')[0], // 格式化为 YYYY-MM-DD
    'payStyle': isMonthlyPayment ? 1 : 0,
    'duration': selectedDuration,
    'lessonFee': standardPrice,
    'lessonFeeAdjusted': double.tryParse(adjustedPriceController.text) ?? 0.0,
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
      // 保存成功
      showDialog(
        // ignore: use_build_context_synchronously
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
                  // 可以选择返回上一页或清空表单
                  Navigator.of(context).pop(true); // 关闭当前页面并返回成功标识
                  // 或者清空表单
                  resetForm();
                },
              ),
            ],
          );
        },
      );
    } else {
      // 保存失败
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('错误'),
            content: Text('保存失败: ${response.body}'),
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
  } catch (e) {
    // 捕获网络错误等异常
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误'),
          content: Text('发生错误: $e'),
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
}

// 重置表单的辅助方法
void resetForm() {
  setState(() {
    selectedSubject = null;
    selectedSubjectSub = null;
    subjectSubs.clear();
    adjustmentDate = DateTime.now();
    isMonthlyPayment = true;
    selectedDuration = null;
    standardPrice = 0.0;
    adjustedPriceController.clear();
  });
}
}
