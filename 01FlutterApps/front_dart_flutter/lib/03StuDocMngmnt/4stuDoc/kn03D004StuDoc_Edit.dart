// ignore_for_file: use_build_context_synchronously, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../CommonProcess/customUI/KnLoadingIndicator.dart'; // 导入自定义加载指示器
import '../../Constants.dart';
import 'DurationBean.dart';

// ignore: must_be_immutable
class StudentDocumentEditPage extends StatefulWidget {
  final String stuId;
  final String subjectId;
  final String subjectSubId;
  final String adjustedDate;
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;

  StudentDocumentEditPage({
    Key? key,
    required this.stuId,
    required this.subjectId,
    required this.subjectSubId,
    required this.adjustedDate,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  }) : super(key: key);

  @override
  _StudentDocumentEditPageState createState() =>
      _StudentDocumentEditPageState();
}

class _StudentDocumentEditPageState extends State<StudentDocumentEditPage> {
  final String titleName = "学生档案编辑";
  bool _isLoading = false; // 添加加载状态变量
  bool _isDataLoaded = false; // 数据是否已加载完成

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
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true; // 开始加载前设置为true
    });

    try {
      await fetchStudentInfo();
      await fetchDurations();
      setState(() {
        _isDataLoaded = true; // 数据加载完成
      });
    } catch (e) {
      print('Error fetching initial data: $e');
      // 显示错误对话框
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('加载错误'),
              content: Text('加载数据时发生错误: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // 返回上一页
                  },
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // 加载完成后设置为false
      });
    }
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
    final String apiLsnDurationUrl =
        '${KnConfig.apiBaseUrl}${Constants.stuDocLsnDuration}';
    final responseDuration = await http.get(Uri.parse(apiLsnDurationUrl));

    if (responseDuration.statusCode == 200) {
      final decodedBody = utf8.decode(responseDuration.bodyBytes);
      List<dynamic> durationJson = json.decode(decodedBody);
      setState(() {
        duration = durationJson
            .map((durationString) =>
                DurationBean.fromString(durationString as String))
            .toList();
      });
    } else {
      throw Exception('Failed to load duration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: titleName,
        subtitle: "${widget.pagePath} >> $titleName",
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义AppBar背景颜色
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义标题颜色
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white, // 自定义底部文本颜色
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        addInvisibleRightButton: false, // 显示Home按钮返回主菜单
        currentNavIndex: 2,
      ),
      body: Stack(
        children: [
          // 主要内容
          _isDataLoaded
              ? SingleChildScrollView(
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
                              onChanged: _isLoading
                                  ? null // 如果正在加载，禁用交互
                                  : (bool? value) {
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
                              onChanged: _isLoading
                                  ? null // 如果正在加载，禁用交互
                                  : (bool? value) {
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
                        onChanged: _isLoading
                            ? null // 如果正在加载，禁用交互
                            : (int? newValue) {
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
                        enabled: !_isLoading, // 如果正在加载，禁用交互
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : saveData, // 如果正在加载，禁用按钮
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                )
              : Container(), // 如果数据未加载完成，显示空容器

          // 加载指示器层
          if (_isLoading)
            Center(
              child:
                  KnLoadingIndicator(color: widget.knBgColor), // 使用自定义的加载器进度条
            ),
        ],
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
      'lessonFee': standardPrice,
      'lessonFeeAdjusted': adjustedPriceValue,
      'minutesPerLsn': selectedDuration,
    };

    try {
      // 设置加载状态
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('${KnConfig.apiBaseUrl}${Constants.stuDocInfoSave}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      // 重置加载状态
      setState(() {
        _isLoading = false;
      });

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
      // 重置加载状态
      setState(() {
        _isLoading = false;
      });

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
