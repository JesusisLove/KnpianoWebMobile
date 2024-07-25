// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'Kn05S002FixedLsnStatusBean.dart';
import 'package:intl/intl.dart';

class Kn05S002WeekCalculatorSchedual extends StatefulWidget {
  const Kn05S002WeekCalculatorSchedual({Key? key}) : super(key: key);

  @override
  _Kn05S002WeekCalculatorSchedualState createState() => _Kn05S002WeekCalculatorSchedualState();
}

class _Kn05S002WeekCalculatorSchedualState extends State<Kn05S002WeekCalculatorSchedual> {
  List<Kn05S002FixedLsnStatusBean> staticLsnList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWeeklySchedual();
  }

  Future<void> fetchWeeklySchedual() async {
    setState(() {
      isLoading = true;
    });
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.weeklySchedualDateForOneYear}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(decodedBody);
        setState(() {
          staticLsnList = jsonList.map((json) => Kn05S002FixedLsnStatusBean.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load weekly schedual');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载数据失败：$e')),
      );
    }
  }

  // 执行排课
  Future<void> executeWeeklySchedual(int weekNumber, String startDate, String endDate) async {
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.weeklySchedualExcute}/$startDate/$endDate';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        await fetchWeeklySchedual(); // 刷新页面
      } else {
        throw Exception('Failed to execute weekly schedual');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('排课失败：$e')),
      );
    }
  }

  // 撤销排课
Future<void> cancelWeeklySchedual(int weekNumber, String startDate, String endDate) async {
  final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.weeklySchedualCancel}/$startDate/$endDate/$weekNumber';
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      if (responseBody == "ok") {
        await fetchWeeklySchedual(); // 刷新页面
      } else {
        // 显示错误消息
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('撤销失败'),
              content: Text(responseBody),
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
    } else {
      throw Exception('Failed to cancel weekly schedual');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('撤销失败：$e')),
    );
  }
}

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return DateFormat('MM-dd').format(dateTime);
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: const Size(60, 30),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DateTime.now().year}年度周次排课设置'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text('周次', textAlign: TextAlign.center)),
                      Expanded(child: Text('开始日', textAlign: TextAlign.center)),
                      Expanded(child: Text('结束日', textAlign: TextAlign.center)),
                      Expanded(child: Text('操作', textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: staticLsnList.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        color: Colors.grey[300],
                        height: 1,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final item = staticLsnList[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text('第${item.weekNumber.toString().padLeft(2, '0')}周', textAlign: TextAlign.center)),
                            Expanded(child: Text(formatDate(item.startWeekDate), textAlign: TextAlign.center)),
                            Expanded(child: Text(formatDate(item.endWeekDate), textAlign: TextAlign.center)),
                            Expanded(
                              child: Center(
                                child: item.fixedStatus == 0
                                    ? _buildButton('排课', Colors.blue, () => executeWeeklySchedual(item.weekNumber, item.startWeekDate, item.endWeekDate))
                                    : _buildButton('撤销', Colors.red, () => cancelWeeklySchedual(item.weekNumber, item.startWeekDate, item.endWeekDate)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}