import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'dart:convert';
// import 'package:logger/logger.dart';
import '../../Constants.dart';
import 'FixLenInfoAdd.dart';
import 'FixLesson.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  ClassSchedulePageState createState() => ClassSchedulePageState();
}

class ClassSchedulePageState extends State<ClassSchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<KnFixLsn001Bean> fixLsnList = [];
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    // 设置管理菜单画面，点击“固定排课设置”按钮的url请求
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoView}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        final decodedBody = utf8.decode(response.bodyBytes);
        fixLsnList = (json.decode(decodedBody) as List)
            .map((data) => KnFixLsn001Bean.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load fixLsnList');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Weekly Class Schedule'),
        title: const Text('每周固定排课计划'),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.black, // 未选中标签内文本颜色
          tabs: const [
            Tab(text: 'Mon'),
            Tab(text: 'Tue'),
            Tab(text: 'Wed'),
            Tab(text: 'Thu'),
            Tab(text: 'Fri'),
            Tab(text: 'Sat'),
            Tab(text: 'Sun'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 点击 "add" 按钮，迁移到固定排课新规登录画面
              Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleForm()));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: weekDays.map((day) => buildLessonGrid(day)).toList(),
      ),
    );
  }

  Widget buildLessonGrid(String dayIndex) {
    // Filter lessons for a specific day
    var dayLessons = fixLsnList.where((fixlsn) => fixlsn.fixedWeek == dayIndex).toList();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: dayLessons.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: <Widget>[
              Text(dayLessons[index].studentName),
              Text(dayLessons[index].subjectName),
              Text(dayLessons[index].classTime),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
