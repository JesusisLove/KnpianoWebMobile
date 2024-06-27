// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/03StuDocMngmnt/4stuDoc/Kn03D004StuDocBean.dart';
import 'dart:convert';

import 'package:kn_piano/Constants.dart';

import '../../ApiConfig/KnApiConfig.dart';
import 'kn03D004StuDoc_Add.dart';
import 'kn03D004StuDoc_Detial_list.dart';

class StudentDocPage extends StatefulWidget {
  const StudentDocPage({super.key});

  @override
  _StudentDocPageState createState() => _StudentDocPageState();
}

class _StudentDocPageState extends State<StudentDocPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 使用 ValueNotifier 来管理状态
  final ValueNotifier<List<Kn03D004StuDocBean>> stuDocNotifier = ValueNotifier([]);
  final ValueNotifier<List<Kn03D004StuDocBean>> stuUnDocNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      // 获取已入档案学生
      final String apiStuDocUrl = '${KnConfig.apiBaseUrl}${Constants.stuDocInfoView}';
      final responseStuDoc = await http.get(Uri.parse(apiStuDocUrl));

      if (responseStuDoc.statusCode == 200) {
        final decodedBody = utf8.decode(responseStuDoc.bodyBytes);
        List<dynamic> stuDocJson = json.decode(decodedBody);
        stuDocNotifier.value = stuDocJson.map((json) => Kn03D004StuDocBean.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load archived students');
      }

      // 获取未入档案学生
      final String apiStuUnDocUrl = '${KnConfig.apiBaseUrl}${Constants.stuUnDocInfoView}';
      final responseStuUnDoc = await http.get(Uri.parse(apiStuUnDocUrl));

      if (responseStuUnDoc.statusCode == 200) {
        final decodedBody = utf8.decode(responseStuUnDoc.bodyBytes);
        List<dynamic> stuUnDocJson = json.decode(decodedBody);
        stuUnDocNotifier.value = stuUnDocJson.map((json) => Kn03D004StuDocBean.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load unarchived students');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('档案管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '已入档案'),
            Tab(text: '未入档案'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentList(stuDocNotifier),
          _buildStudentUnDocList(stuUnDocNotifier),
        ],
      ),
    );
  }
// 风格二：如果按钮太多导致空间不足，你可以考虑使用PopupMenuButton来替代，这样可以在一个下拉菜单中包含多个操作。
Widget _buildStudentList(ValueNotifier<List<Kn03D004StuDocBean>> notifier) {
  return ValueListenableBuilder<List<Kn03D004StuDocBean>>(
    valueListenable: notifier,
    builder: (context, students, child) {
      if (students.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('images/student-placeholder.png'),
            ),
            title: Text(student.stuName),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case 'detail':
                    // Navigate to add subjectEda page or handle add operation
                    Navigator.push<bool>(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => StudentDocDetailPage(stuId: student.stuId, stuName: student.stuName)
                      )
                    ).then((value) => {
                      setState(() {
                      _fetchStudentData();
                    })});
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'detail',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('详细'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildStudentUnDocList(ValueNotifier<List<Kn03D004StuDocBean>> notifier) {
  return ValueListenableBuilder<List<Kn03D004StuDocBean>>(
    valueListenable: notifier,
    builder: (context, students, child) {
      if (students.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('images/student-placeholder.png'),
            ),
            title: Text(student.stuName),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case 'addnew':
                    // Navigate to add subjectEda page or handle add operation
                    Navigator.push<bool>(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => StudentDocumentPage(stuId: student.stuId, stuName: student.stuName)
                      )
                    ).then((value) => {
                      setState(() {
                      _fetchStudentData();
                    })});
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'addnew',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('新規'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
  @override
  void dispose() {
    _tabController.dispose();
    stuDocNotifier.dispose();
    stuUnDocNotifier.dispose();
    super.dispose();
  }
}