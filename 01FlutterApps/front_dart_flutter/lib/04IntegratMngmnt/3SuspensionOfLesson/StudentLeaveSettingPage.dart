// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../03StuDocMngmnt/1studentBasic/KnStu001Bean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';

// ignore: must_be_immutable
class StudentLeaveSettingPage extends StatefulWidget {
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  late String pagePath;
  StudentLeaveSettingPage(
      {super.key,
      required this.knBgColor,
      required this.knFontColor,
      required this.pagePath});

  @override
  _StudentLeaveSettingPageState createState() =>
      _StudentLeaveSettingPageState();
}

class _StudentLeaveSettingPageState extends State<StudentLeaveSettingPage> {
  final String titleName = '他(她)要休学或退学';
  final ValueNotifier<List<KnStu001Bean>> stuOffLsnNotifier = ValueNotifier([]);
  int stuInfoCount = 0;
  List<KnStu001Bean> stuOffLsnList = [];
  bool _isLoading = true; // 新增加载状态标志

  @override
  void initState() {
    super.initState();
    fetchStuOffLsnInfo();
  }

  @override
  void dispose() {
    stuOffLsnNotifier.dispose(); // 释放资源
    super.dispose();
  }

  Future<void> fetchStuOffLsnInfo() async {
    if (!mounted) return; // 检查组件是否仍然挂载

    setState(() {
      _isLoading = true; // 开始加载数据
    });

    try {
      final String apiStuOnLsnUrl =
          '${KnConfig.apiBaseUrl}${Constants.intergStuOnLsn}';
      final responseFeeDetails = await http.get(Uri.parse(apiStuOnLsnUrl));

      if (!mounted) return; // 再次检查，因为网络请求可能耗时

      if (responseFeeDetails.statusCode == 200) {
        final decodedBody = utf8.decode(responseFeeDetails.bodyBytes);
        List<dynamic> stuDocJson = json.decode(decodedBody);
        setState(() {
          stuOffLsnNotifier.value =
              stuDocJson.map((json) => KnStu001Bean.fromJson(json)).toList();
          stuInfoCount = stuOffLsnNotifier.value.length;
          stuOffLsnList = stuOffLsnNotifier.value;
          _isLoading = false; // 数据加载完成
        });
      } else {
        throw Exception('Failed to load archived students');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // 出错时也要设置加载完成
        });
        // 显示错误信息给用户
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // 注释: 修改为使用 KnStu001Bean 对象
  Set<KnStu001Bean> selectedStudents = <KnStu001Bean>{};

  // 注释: 新增保存功能
  Future<void> saveSelectedStudents() async {
    if (selectedStudents.isEmpty) {
      // 注释: 如果没有选中学生，显示提示对话框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('没有退学的学生被选中，请选择要退学的学生。'),
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
      return;
    }

    // 注释: 准备要发送的数据
    List<Map<String, dynamic>> studentsToSave = selectedStudents
        .map((student) => {'stuId': student.stuId, 'stuName': student.stuName})
        .toList();

    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.intergStuLeaveExecute}';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(studentsToSave),
      );

      if (response.statusCode == 200) {
        // 注释: 保存成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('退学处理成功'),
            backgroundColor: widget.knBgColor,
            duration: const Duration(seconds: 5),
          ),
        );
        // 退出当前页面，返回上一句页面，并让上一级页面执行刷新操作
        Navigator.of(context).pop(true);
      } else {
        // 注释: 保存失败
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('退学处理失败，请重试')),
        );
      }
    } catch (e) {
      // 注释: 发生错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: titleName,
        subtitle: '${widget.pagePath} >> $titleName',
        context: context,
        appBarBackgroundColor: widget.knBgColor, // 自定义AppBar背景颜色
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义标题颜色
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义底部文本框背景颜色
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        addInvisibleRightButton: true,
        subtitleTextColor: Colors.white, // 自定义底部文本颜色
        titleFontSize: 20.0, // 自定义标题字体大小
        subtitleFontSize: 12.0, // 自定义底部文本字体大小
        actions: [
          TextButton(
            onPressed: saveSelectedStudents,
            child: const Text('Save',
                style: TextStyle(color: Colors.white)), // 注释: 调用保存方法
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AlphabetScrollView(
              list: stuOffLsnList, // 注释: 使用 stuOffLsnList 代替 students
              selectedStudents: selectedStudents,
              onStudentSelected: (KnStu001Bean student, bool selected) {
                setState(() {
                  if (selected) {
                    selectedStudents.add(student);
                  } else {
                    selectedStudents.remove(student);
                  }
                });
              },
            ),
    );
  }
}

class AlphabetScrollView extends StatelessWidget {
  final List<KnStu001Bean> list; // 注释: 修改为 KnStu001Bean 类型的列表
  final Set<KnStu001Bean> selectedStudents; // 注释: 修改为 KnStu001Bean 类型的集合
  final Function(KnStu001Bean, bool) onStudentSelected; // 注释: 修改回调函数参数类型

  const AlphabetScrollView({
    super.key,
    required this.list,
    required this.selectedStudents,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 注释: 根据 stuName 排序
    list.sort((a, b) => a.stuName.compareTo(b.stuName));
    final groupedStudents = groupStudents(list);

    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: groupedStudents.length,
            itemBuilder: (context, index) {
              final letter = groupedStudents.keys.elementAt(index);
              final students = groupedStudents[letter]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    // 紫色长条的两端边距
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10.5),
                            ),
                            child: Text(
                              letter,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  ...students.map((student) => buildStudentItem(student)),
                ],
              );
            },
          ),
        ),
        Container(
          width: 20,
          color: Colors.grey[200],
          child: ListView.builder(
            itemCount: 26,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 处理字母索引点击
                },
                child: Container(
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 注释: 修改为使用 KnStu001Bean 对象
  Widget buildStudentItem(KnStu001Bean student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 60, // 设置cell行的高度
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            // 添加一个 SizedBox 来设置左侧间距，每一行有checkBox的学生信息距离画面错边距60像素。
            const SizedBox(width: 24),
            Checkbox(
              value: selectedStudents.contains(student),
              onChanged: (bool? value) {
                onStudentSelected(student, value ?? false);
              },
            ),
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(student.stuName[0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Text(student.stuName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 注释: 修改为使用 KnStu001Bean 对象
  Map<String, List<KnStu001Bean>> groupStudents(List<KnStu001Bean> students) {
    final grouped = <String, List<KnStu001Bean>>{};
    for (final student in students) {
      final letter = student.stuName[0].toUpperCase();
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(student);
    }
    return grouped;
  }
}
