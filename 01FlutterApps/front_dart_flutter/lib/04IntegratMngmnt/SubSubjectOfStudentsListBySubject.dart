import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../Constants.dart';
import '../03StuDocMngmnt/4stuDoc/Kn03D004StuDocBean.dart';

class SubSubjectOfStudentsListBySubject extends StatefulWidget {
  final Color knBgColor;
  final Color knFontColor;
  final String pagePath;

  const SubSubjectOfStudentsListBySubject({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  _SubSubjectOfStudentsListBySubjectState createState() =>
      _SubSubjectOfStudentsListBySubjectState();
}

class _SubSubjectOfStudentsListBySubjectState
    extends State<SubSubjectOfStudentsListBySubject>
    with TickerProviderStateMixin {
  final String titleName = '正在学习该科目的学生';
  late String pagePath;

  // 科目列表相关
  List<Map<String, String>> subjectList = [];
  String? selectedSubjectId;
  String? selectedSubjectName;
  int tempSelectedIndex = 0;

  // Tab相关
  TabController? _tabController;
  List<String> subjectSubNames = [];
  int selectedTabIndex = 0;

  // 学生列表相关
  List<Kn03D004StuDocBean> studentList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pagePath = '${widget.pagePath} >> $titleName';
    fetchSubjectList();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // 获取科目列表
  Future<void> fetchSubjectList() async {
    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.subjectEdaStuAll}';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(decodedBody);

        setState(() {
          subjectList = jsonList
              .map((json) => {
                    'subjectId': json['subjectId'].toString(),
                    'subjectName': json['subjectName'].toString(),
                  })
              .toList();

          if (subjectList.isNotEmpty) {
            selectedSubjectId = subjectList[0]['subjectId'];
            selectedSubjectName = subjectList[0]['subjectName'];
            fetchStudentsBySubject(selectedSubjectId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching subject list: $e');
    }
  }

  // 获取指定科目的学生列表
  Future<void> fetchStudentsBySubject(String subjectId) async {
    if (isLoading) return;

    // 首先销毁现有的TabController
    _tabController?.dispose();
    _tabController = null;

    setState(() {
      isLoading = true;
      studentList = [];
      subjectSubNames = [];
      selectedTabIndex = 0;
    });

    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.subjectEdaStuBysub}/$subjectId';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(decodedBody);

        // 处理新数据
        final newStudentList =
            jsonList.map((json) => Kn03D004StuDocBean.fromJson(json)).toList();

        // 获取新的子科目名称列表（去重）
        final newSubjectSubNames = newStudentList
            .map((student) => student.subjectSubName)
            .toSet()
            .toList();

        if (mounted) {
          setState(() {
            studentList = newStudentList;
            subjectSubNames = newSubjectSubNames;
            selectedTabIndex = 0;

            // 创建新的TabController
            if (subjectSubNames.isNotEmpty) {
              _tabController = TabController(
                length: subjectSubNames.length,
                vsync: this,
              );
              _tabController!.addListener(() {
                if (mounted && !_tabController!.indexIsChanging) {
                  setState(() {
                    selectedTabIndex = _tabController!.index;
                  });
                }
              });
            }

            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // 显示科目选择器
  void _showSubjectPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(bottom: 34), // 为底部安全区域留出空间
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: widget.knBgColor,
                border: const Border(
                  bottom: BorderSide(color: CupertinoColors.separator),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedSubjectId =
                            subjectList[tempSelectedIndex]['subjectId'];
                        selectedSubjectName =
                            subjectList[tempSelectedIndex]['subjectName'];
                      });
                      fetchStudentsBySubject(selectedSubjectId!);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: subjectList.indexWhere(
                      (subject) => subject['subjectId'] == selectedSubjectId),
                ),
                children: subjectList
                    .map((subject) => Text(subject['subjectName']!))
                    .toList(),
                onSelectedItemChanged: (index) {
                  tempSelectedIndex = index;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建Tab栏
  Widget _buildTabs() {
    if (subjectSubNames.isEmpty) return Container();

    return DefaultTabController(
      length: subjectSubNames.length,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(left: 1), // 整个TabBar与屏幕左边距离1像素
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.only(right: 1), // Tab之间的间隔设为1像素
          indicatorPadding: EdgeInsets.zero,
          padding: EdgeInsets.zero, // 移除TabBar自身的内边距
          indicatorColor: Colors.transparent, // 移除indicator
          tabAlignment: TabAlignment.start, // 强制Tab从左开始对齐
          tabs: subjectSubNames
              .map((subName) => Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color:
                            subjectSubNames.indexOf(subName) == selectedTabIndex
                                ? Colors.green
                                : Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          subName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // 构建学生列表
// 构建学生列表
  Widget _buildStudentList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (subjectSubNames.isEmpty || selectedTabIndex >= subjectSubNames.length) {
      return const Center(
        child: Text(
          '目前没有该科目下的学生列表信息！',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    final currentSubName = subjectSubNames[selectedTabIndex];
    final filteredStudents = studentList
        .where((student) => student.subjectSubName == currentSubName)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 15.0,
        columns: const [
          DataColumn(
            label: Text(
              '学生姓名',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '上课种别',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '学费/月',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '基准日',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              '介绍人',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: filteredStudents
            .map((student) => DataRow(
                  cells: [
                    DataCell(Text(student.stuName)),
                    DataCell(Container(
                      alignment: Alignment.center,
                      child: Text(student.payStyle == 1 ? '计' : '时'),
                    )),
                    DataCell(Text((student.lessonFeeAdjusted > 0
                            ? student.lessonFeeAdjusted * 4
                            : student.lessonFee * 4)
                        .toStringAsFixed(1))),
                    DataCell(Text(student.adjustedDate)),
                    DataCell(Text(student.introducer)),
                  ],
                ))
            .toList(),
      ),
    );
  }

  // 构建科目选择器按钮
  Widget _buildSubjectPickerButton() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 44,
      width: screenWidth / 2, // 设置宽度为屏幕的一半
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 232, 228, 228), // 设置背景色为黄色
        onPressed: _showSubjectPicker,
        child: Text(
          selectedSubjectName ?? '选择科目',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: titleName,
        subtitle: pagePath,
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
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildStudentList(),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabs(),
              _buildSubjectPickerButton(),
              const SizedBox(height: 34), // 为底部安全区域留出空间
            ],
          ),
        ],
      ),
    );
  }
}
