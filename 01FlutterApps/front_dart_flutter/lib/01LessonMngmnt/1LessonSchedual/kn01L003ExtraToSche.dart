// ignore: file_names
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';
import 'Kn01L003LsnExtraBean.dart';

// ignore: must_be_immutable
class ExtraToSchePage extends StatefulWidget {
  ExtraToSchePage({
    super.key,
    required this.stuId,
    required this.stuName,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  final String stuId;
  final String stuName;
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;

  @override
  _ExtraToSchePageState createState() => _ExtraToSchePageState();
}

class _ExtraToSchePageState extends State<ExtraToSchePage> {
  final String titleName = '加课消化管理';
  late int selectedYear;
  late List<int> years;
  late Future<List<Kn01L003LsnExtraBean>> futureLessons;
  int paidCount = 0;
  int unpaidCount = 0;
  int convertedCount = 0;

  // 定义颜色常量
  final Color brownColor = const Color.fromARGB(255, 167, 47, 4);
  final Color pinkColor = Colors.pink;
  final Color orangeColor = Colors.orange;
  final Color greyColor = Colors.grey;
  final Color greenColor = Colors.green;

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    years = List.generate(currentYear - 2017 + 1, (index) => currentYear - index);
    selectedYear = currentYear;
    widget.pagePath = '${widget.pagePath} >> 加课消化管理';
    _fetchLessonsData();
  }

  void _showDigestDatePicker(Kn01L003LsnExtraBean lesson) {
    String selectedDate = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '换正课日期',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 28),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('选择日期：'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: widget.knBgColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: '选择日期',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: selectedDate.isEmpty ? '' : selectedDate,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.knBgColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: selectedDate.isEmpty
                            ? null
                            : () async {
                                try {
                                  final requestData = lesson.toRequestMap(selectedDate);
                                  final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.executeExtraToSche}';
                                  final response = await http.post(
                                    Uri.parse(apiUrl),
                                    headers: {
                                      'Content-Type': 'application/json; charset=UTF-8',
                                    },
                                    body: utf8.encode(json.encode(requestData)),
                                  );

                                  if (response.statusCode == 200) {
                                    final decodedBody = utf8.decode(response.bodyBytes);
                                    if (decodedBody == 'success') {
                                      Navigator.of(context).pop();
                                      _fetchLessonsData();
                                    } else {
                                      throw Exception(decodedBody);
                                    }
                                  } else {
                                    final decodedBody = utf8.decode(response.bodyBytes);
                                    throw Exception(decodedBody);
                                  }
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('错误'),
                                        content: Text('更新失败: $e'),
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
                              },
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _fetchLessonsData() async {
    setState(() {
      futureLessons = fetchLessons();
    });
  }

  Future<List<Kn01L003LsnExtraBean>> fetchLessons() async {
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.extraToScheView}/${widget.stuId}/$selectedYear';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> lessonsJson = json.decode(decodedBody);

        paidCount = lessonsJson.where((item) => item['payFlg'] == 1).length;
        unpaidCount = lessonsJson.where((item) => item['payFlg'] == 0).length;
        convertedCount = lessonsJson.where((item) => item['extraToDurDate'] != null && item['extraToDurDate'].toString().isNotEmpty).length;

        return lessonsJson.map((json) => Kn01L003LsnExtraBean.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lessons');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void _showYearPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.pink,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消', style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('选择年份', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  CupertinoButton(
                    child: const Text('确定', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      _fetchLessonsData();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedYear = years[index];
                  });
                },
                children: years.map((year) => Center(child: Text(year.toString(), style: const TextStyle(color: Colors.pink)))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(Kn01L003LsnExtraBean lesson, bool isPaidExtraLesson) {
    Color textColor = isPaidExtraLesson ? greyColor : (lesson.extraToDurDate.isNotEmpty ? brownColor : pinkColor);

    if (lesson.extraToDurDate.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '原加课日: ${lesson.originalSchedualDate}',
            style: TextStyle(
              color: isPaidExtraLesson ? greyColor : greyColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '现正课日: ${lesson.extraToDurDate}',
            style: TextStyle(color: textColor),
          ),
        ],
      );
    } else if (lesson.lsnAdjustedDate.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '上课日期: ${lesson.schedualDate}',
            style: TextStyle(color: textColor),
          ),
          Text(
            '调课日期: ${lesson.lsnAdjustedDate}',
            style: TextStyle(
              color: isPaidExtraLesson ? greyColor : (lesson.extraToDurDate.isEmpty ? pinkColor : orangeColor),
            ),
          ),
        ],
      );
    } else {
      return Text(
        '上课日期: ${lesson.schedualDate}',
        style: TextStyle(color: textColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: '${widget.stuName}的$titleName',
        subtitle: widget.pagePath,
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(widget.knFontColor.alpha, widget.knFontColor.red - 20, widget.knFontColor.green - 20, widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(widget.knFontColor.alpha, widget.knFontColor.red + 20, widget.knFontColor.green + 20, widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 实现添加功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('已支付: $paidCount节', style: const TextStyle(color: Colors.red)),
                Text('未支付: $unpaidCount节', style: const TextStyle(color: Colors.red)),
                Text('已转换: $convertedCount节', style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: _showYearPicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('$selectedYear年'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Kn01L003LsnExtraBean>>(
              future: futureLessons,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final lesson = snapshot.data![index];
                    final bool isPaidExtraLesson = lesson.payFlg == 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaidExtraLesson ? greyColor : greenColor,
                          child: Text(
                            '${lesson.classDuration}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          '${lesson.subjectName}: ${lesson.subjectSubName}',
                          style: TextStyle(
                            color: isPaidExtraLesson ? greyColor : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '种别: ${lesson.extraToDurDate.isNotEmpty ? "加转正" : "月加课"}',
                              style: TextStyle(
                                color: isPaidExtraLesson ? greyColor : (lesson.extraToDurDate.isNotEmpty ? brownColor : pinkColor),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildDateInfo(lesson, isPaidExtraLesson),
                          ],
                        ),
                        trailing: isPaidExtraLesson
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '结算完了',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (BuildContext context) {
                                  if (lesson.extraToDurDate.isNotEmpty) {
                                    // 加转正的情况只显示撤销
                                    return <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'cancel',
                                        child: Text('撤销'),
                                      ),
                                    ];
                                  } else {
                                    // 月加课的情况只显示消化
                                    return <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'digest',
                                        child: Text('消化'),
                                      ),
                                    ];
                                  }
                                },
                                onSelected: (String result) async {
                                  if (result == 'digest') {
                                    _showDigestDatePicker(lesson);
                                  } else if (result == 'cancel') {
                                    try {
                                      final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.undoExtraToSche}/${lesson.lessonId}';

                                      final response = await http.get(
                                        // 改为POST请求
                                        Uri.parse(apiUrl),
                                        headers: {
                                          'Content-Type': 'application/json; charset=UTF-8',
                                        },
                                      );

                                      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

                                      if (response.statusCode == 200 && decodedBody['status'] == 'success') {
                                        // 撤销成功，刷新页面
                                        _fetchLessonsData();
                                        // 显示成功提示
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(decodedBody['message'] ?? '撤销成功')),
                                        );
                                      } else {
                                        throw Exception(decodedBody['message'] ?? '操作失败');
                                      }
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('错误'),
                                            content: Text('撤销失败: ${e.toString().replaceAll('Exception: ', '')}'),
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
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
