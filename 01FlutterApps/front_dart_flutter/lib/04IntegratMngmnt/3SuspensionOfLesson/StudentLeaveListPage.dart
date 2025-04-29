// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:kn_piano/03StuDocMngmnt/1studentBasic/KnStu001Bean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../CommonProcess/customUI/KnLoadingIndicator.dart'; // 导入自定义加载指示器
import '../../Constants.dart';
import 'package:http/http.dart' as http;
import 'StudentLeaveSettingPage.dart';
import 'dart:convert';
import 'dart:async'; // 新增导入

// ignore: must_be_immutable
class StudentLeaveListPage extends StatefulWidget {
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  late String pagePath;
  StudentLeaveListPage(
      {super.key,
      required this.knBgColor,
      required this.knFontColor,
      required this.pagePath});

  @override
  // ignore: library_private_types_in_public_api
  _StudentLeaveListPageState createState() => _StudentLeaveListPageState();
}

class _StudentLeaveListPageState extends State<StudentLeaveListPage> {
  final String titleName = '学生休学退学名单';
  final ValueNotifier<List<KnStu001Bean>> stuOffLsnNotifier = ValueNotifier([]);
  int stuInfoCount = 0;
  List<KnStu001Bean> students = [];
  bool _isLoading = false; // 修改加载状态标志
  bool _showDeleteButtons = false; // 控制删除按钮显示的状态
  bool _isDataLoaded = false; // 数据是否已加载完成

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
      final String apiStuQuitLsnUrl =
          '${KnConfig.apiBaseUrl}${Constants.intergStuQuitLsn}';
      final responseFeeDetails = await http.get(Uri.parse(apiStuQuitLsnUrl));

      if (!mounted) return; // 再次检查，因为网络请求可能耗时

      if (responseFeeDetails.statusCode == 200) {
        final decodedBody = utf8.decode(responseFeeDetails.bodyBytes);
        List<dynamic> stuDocJson = json.decode(decodedBody);
        setState(() {
          stuOffLsnNotifier.value =
              stuDocJson.map((json) => KnStu001Bean.fromJson(json)).toList();
          stuInfoCount = stuOffLsnNotifier.value.length;
          students = stuOffLsnNotifier.value;
          _isDataLoaded = true; // 数据加载完成
          _isLoading = false; // 加载状态结束
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

  // 切换删除按钮显示状态的方法
  void toggleDeleteButtons() {
    setState(() {
      _showDeleteButtons = !_showDeleteButtons;
    });
  }

  // 处理学生退学的方法
  Future<void> handleStudentReturn(String stuId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true; // 开始处理操作
    });

    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.intergStuReturnExecute}/$stuId';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false; // 操作完成
      });

      if (response.statusCode == 200) {
        // 请求成功，刷新页面
        await fetchStuOffLsnInfo();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('学生已成功复学'),
            backgroundColor: widget.knBgColor,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // 请求失败，显示错误信息
        throw Exception('Failed to process student return');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // 确保出错时也重置加载状态
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          // 当加载中时禁用按钮
          IconButton(
            icon: Icon(
              _showDeleteButtons ? Icons.close : Icons.add,
              color: Colors.white,
            ),
            onPressed: _isLoading ? null : toggleDeleteButtons,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 主要内容
          _isDataLoaded
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: students.length + 1,
                    itemBuilder: (context, index) {
                      if (index == students.length) {
                        return GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  // 处理添加新学生的逻辑
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StudentLeaveSettingPage(
                                              knBgColor:
                                                  Constants.ingergThemeColor,
                                              knFontColor: Colors.white,
                                              pagePath:
                                                  '${widget.pagePath} >> $titleName',
                                            )),
                                  ).then((value) {
                                    // 如果需要，在返回时刷新学生列表
                                    if (value == true) {
                                      fetchStuOffLsnInfo();
                                    }
                                  });
                                },
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.add_circle,
                                color: _isLoading
                                    ? Colors.grey // 加载中时使用灰色
                                    : widget.knBgColor,
                                size: 50),
                          ),
                        );
                      }
                      KnStu001Bean student = students[index];
                      return Stack(
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: widget.knBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              student.nikName.isNotEmpty
                                  ? student.nikName
                                  : student.stuName,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // 根据_showDeleteButtons状态显示或隐藏删除按钮
                          if (_showDeleteButtons && !_isLoading) // 加载中时不显示
                            Positioned(
                              left: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // 调用handleStudentReturn方法
                                  handleStudentReturn(student.stuId);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
}
