// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/03StuDocMngmnt/4stuDoc/Kn03D004StuDocBean.dart';
import 'dart:convert';

import 'package:kn_piano/Constants.dart';

import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import 'kn03D004StuDoc_Add.dart';
import 'kn03D004StuDoc_Detial_list.dart';

// ignore: must_be_immutable
class StudentDocPage extends StatefulWidget {
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;
  late String subtitle;

  StudentDocPage({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  }){
     subtitle = '$pagePath >> 档案管理';
  }

  @override
  // ignore: library_private_types_in_public_api
  _StudentDocPageState createState() => _StudentDocPageState();
}

class _StudentDocPageState extends State<StudentDocPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int archivedCount = 0;
  int unarchivedCount = 0;

  // 使用 ValueNotifier 来管理状态
  final ValueNotifier<List<Kn03D004StuDocBean>> stuDocNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Kn03D004StuDocBean>> stuUnDocNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      // 获取已入档案学生
      final String apiStuDocUrl =
          '${KnConfig.apiBaseUrl}${Constants.stuDocInfoView}';
      final responseStuDoc = await http.get(Uri.parse(apiStuDocUrl));

      if (responseStuDoc.statusCode == 200) {
        final decodedBody = utf8.decode(responseStuDoc.bodyBytes);
        List<dynamic> stuDocJson = json.decode(decodedBody);
        stuDocNotifier.value = stuDocJson
            .map((json) => Kn03D004StuDocBean.fromJson(json))
            .toList();
        archivedCount = stuDocNotifier.value.length; // 更新已入档案人数
      } else {
        throw Exception('Failed to load archived students');
      }

      // 获取未入档案学生
      final String apiStuUnDocUrl =
          '${KnConfig.apiBaseUrl}${Constants.stuUnDocInfoView}';
      final responseStuUnDoc = await http.get(Uri.parse(apiStuUnDocUrl));

      if (responseStuUnDoc.statusCode == 200) {
        final decodedBody = utf8.decode(responseStuUnDoc.bodyBytes);
        List<dynamic> stuUnDocJson = json.decode(decodedBody);
        stuUnDocNotifier.value = stuUnDocJson
            .map((json) => Kn03D004StuDocBean.fromJson(json))
            .toList();
        unarchivedCount = stuUnDocNotifier.value.length; // 更新未入档案人数
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
    return ValueListenableBuilder<List<Kn03D004StuDocBean>>(
      valueListenable: stuUnDocNotifier,
      builder: (context, unDocStudents, child) {
        return Scaffold(
          appBar: KnAppBar(
            title: unarchivedCount == 0 ? '档案管理（$archivedCount人）' : '档案管理',
            subtitle: widget.subtitle,
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
            addInvisibleRightButton: true,
          ),
          body: Column(
            children: [
              if (unDocStudents.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '已入档案 （$archivedCount人）'),
                    Tab(text: '未入档案 （$unarchivedCount人）'),
                  ],
                ),
              Expanded(
                child: unDocStudents.isNotEmpty
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          _buildStudentList(stuDocNotifier),
                          _buildStudentUnDocList(stuUnDocNotifier),
                        ],
                      )
                    : _buildStudentList(stuDocNotifier),
              ),
            ],
          ),
        );
      },
    );
  }

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${student.subjectCount} 科',
                      style: const TextStyle(fontSize: 16.0)),
                  const SizedBox(
                      width: 48.0), // 调整 Text 和 PopupMenuButton 之间的间距
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'detail':
                          Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDocDetailPage(
                                stuId: student.stuId,
                                stuName: student.stuName,
                                knBgColor: widget.knBgColor,
                                knFontColor: widget.knFontColor,
                                pagePath: widget.subtitle,
                              ),
                            ),
                          ).then((value) {
                            _fetchStudentData();
                          });
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'detail',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('详细'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentUnDocList(
      ValueNotifier<List<Kn03D004StuDocBean>> notifier) {
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
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentDocumentPage(
                            stuId: student.stuId,
                            stuName: student.stuName,
                            knBgColor: widget.knBgColor,
                            knFontColor: widget.knFontColor,
                            pagePath: widget.subtitle,
                          ),
                        ),
                      ).then((value) {
                        _fetchStudentData();
                      });
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
