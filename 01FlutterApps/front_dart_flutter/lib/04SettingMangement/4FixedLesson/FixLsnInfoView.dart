import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'dart:convert';
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
        title: const Text('固定排课一览'),
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
        children: weekDays.map((day) => buildLessonList(day)).toList(),
      ),
    );
  }

  Widget buildLessonList(String dayIndex) {
    // Filter lessons for a specific day
    var dayLessons = fixLsnList.where((fixlsn) => fixlsn.fixedWeek == dayIndex).toList();
    return ListView.builder(
      itemCount: dayLessons.length,
      itemBuilder: (context, index) {
        // return Card(
        //   child: Column(
        //     children: <Widget>[
        //       Text(dayLessons[index].studentName),
        //       Text(dayLessons[index].subjectName),
        //       Text(dayLessons[index].classTime),
        //     ],
        //   ),
        // );
      return Card(
        child: ListTile(
          leading: const CircleAvatar(
          // backgroundImage: NetworkImage(student.imageUrl), // 假设每个学生对象有一个imageUrl字段
          // 如果没有图像URL，可以使用一个本地的占位符图像
            backgroundImage: AssetImage('images/student-placeholder.png'),
          ),
          title: Text(dayLessons[index].studentName),
          subtitle: Text(
            "      正在学习: ${dayLessons[index].subjectName}"
            "      固定时间: ${dayLessons[index].classTime}"
          ),
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
