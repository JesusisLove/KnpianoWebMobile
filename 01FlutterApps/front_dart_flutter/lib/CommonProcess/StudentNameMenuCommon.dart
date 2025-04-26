import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig/KnApiConfig.dart';
import 'customUI/KnAppBar.dart';
import 'pageIdMapping.dart';

class StudentNameMenuCommon extends StatefulWidget {
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  final String pagePath;
  // 子画面迁移Id
  final String pageId;
  // 接受各业务画面传递过来的uri
  final String strUri;

  const StudentNameMenuCommon({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
    required this.pageId,
    required this.strUri,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StudentNameMenuCommonState createState() => _StudentNameMenuCommonState();
}

class _StudentNameMenuCommonState extends State<StudentNameMenuCommon> {
  List<Map<String, dynamic>> students = [];
  DisplayMode _displayMode = DisplayMode.medium;
  bool _isLoading = true; // 添加加载状态变量

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() {
      _isLoading = true; // 开始加载
    });
    final String apiUrl = '${KnConfig.apiBaseUrl}${widget.strUri}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // 使用 Set 来去重
        final Set<String> uniqueIds = {};
        final List<Map<String, dynamic>> uniqueStudents = [];

        for (var item in data) {
          final String id = item['stuId'].toString();
          if (!uniqueIds.contains(id)) {
            uniqueIds.add(id);
            uniqueStudents.add({
              'id': id,
              'name': item['nikName'] != null &&
                      item['nikName'].toString().isNotEmpty
                  ? item['nikName']
                  : (item['stuName'] ?? '未知姓名'),
            });
          }
        }

        setState(() {
          students = uniqueStudents;
          _isLoading = false; // 加载完成
        });
      } else {
        print('Failed to load students');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false; // 出错也要结束加载状态
      });
    }
  }

  void _onStudentTap(String stuId, String stuName, String pageId) {
    // 导航到页面ID的Mapping文件，根据相应的PageId跳转至PageId对应的业务画面。
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PageIdMapping(
                  pageId: pageId,
                  stuId: stuId,
                  stuName: stuName,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: '在课学生一览',
        subtitle: widget.pagePath,
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha,
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha,
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white,
        addInvisibleRightButton: true,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        actions: [
          PopupMenuButton<DisplayMode>(
            icon: Icon(Icons.more_horiz, color: widget.knFontColor),
            onSelected: (DisplayMode result) {
              setState(() {
                _displayMode = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<DisplayMode>>[
              const PopupMenuItem<DisplayMode>(
                value: DisplayMode.small,
                child: Text('小'),
              ),
              const PopupMenuItem<DisplayMode>(
                value: DisplayMode.medium,
                child: Text('中'),
              ),
              const PopupMenuItem<DisplayMode>(
                value: DisplayMode.large,
                child: Text('大'),
              ),
            ],
          ),
        ],
        bottom: null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 加载中显示进度条
          : _buildStudentGrid(), // 加载完成显示网格
    );
  }

  Widget _buildStudentGrid() {
    int crossAxisCount;
    switch (_displayMode) {
      case DisplayMode.small:
        crossAxisCount = 4;
        break;
      case DisplayMode.medium:
        crossAxisCount = 3;
        break;
      case DisplayMode.large:
        crossAxisCount = 2;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0), // 增加整体内边距
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 4 / 2,
          crossAxisSpacing: 1, // 增加水平间距
          mainAxisSpacing: 1, // 增加垂直间距
        ),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ElevatedButton(
            onPressed: () =>
                _onStudentTap(student['id'], student['name'], widget.pageId),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), //倒角
              ),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white, // 设置按钮背景色为白色
              foregroundColor: Colors.indigo, // 设置文字颜色
              elevation: 2, // 添加轻微阴影效果R
            ),
            child: Center(
              child: Text(
                student['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum DisplayMode { small, medium, large }
