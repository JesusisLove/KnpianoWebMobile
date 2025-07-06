import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'dart:convert';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../CommonProcess/customUI/KnLoadingIndicator.dart'; // 导入自定义加载指示器
import '../../Constants.dart';
import 'knfixlsn001_add.dart';
import 'knfixlsn001_edit.dart';
import 'KnFixLsn001Bean.dart';

// ignore: must_be_immutable
class ClassSchedulePage extends StatefulWidget {
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;
  ClassSchedulePage({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  ClassSchedulePageState createState() => ClassSchedulePageState();
}

class ClassSchedulePageState extends State<ClassSchedulePage>
    with SingleTickerProviderStateMixin {
  final String titleName = '固定排课一览';
  late TabController _tabController;
  late Future<List<KnFixLsn001Bean>> futureFixLsnList;
  late String subtitle;
  bool _isLoading = false; // 添加加载状态变量

  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    // 获取当前日期并计算星期几的索引
    int currentDayIndex = _getCurrentDayIndex();
    _tabController =
        TabController(length: 7, vsync: this, initialIndex: currentDayIndex);
    _fetchLessonData();
  }

  // 新增方法：获取当前日期对应的星期几索引
  int _getCurrentDayIndex() {
    DateTime now = DateTime.now();
    // DateTime.weekday 返回 1-7，其中 1=Monday, 7=Sunday
    // 我们的weekDays数组是 [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
    // 所以需要将 weekday-1 来匹配数组索引
    int weekday = now.weekday; // 1=Monday, 2=Tuesday, ..., 7=Sunday
    return weekday - 1; // 转换为0-6的索引
  }

  // 新增方法：获取当前选中的星期
  String getCurrentSelectedDay() {
    return weekDays[_tabController.index];
  }

  // 新的数据加载方法
  void _fetchLessonData() {
    setState(() {
      _isLoading = true; // 开始加载前设置为true
    });

    futureFixLsnList = fetchLessons().then((result) {
      // 数据加载完成后
      setState(() {
        _isLoading = false; // 加载完成后设置为false
      });
      return result;
    }).catchError((error) {
      // 发生错误时
      setState(() {
        _isLoading = false; // 出错时也要设置为false
      });
      throw error; // 继续传递错误
    });
  }

  // 画面初期化：取得所有固定排课信息
  Future<List<KnFixLsn001Bean>> fetchLessons() async {
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoView}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return (json.decode(decodedBody) as List)
          .map((data) => KnFixLsn001Bean.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load fixLsnList');
    }
  }

  @override
  Widget build(BuildContext context) {
    subtitle = "${widget.pagePath} >> $titleName";
    return Scaffold(
      appBar: KnAppBar(
        title: titleName,
        subtitle: subtitle,
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
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        addInvisibleRightButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            // 新規"➕"按钮的事件处理函数
            onPressed: _isLoading
                ? null // 如果正在加载，禁用按钮
                : () {
                    // 获取当前选中的星期并传递给子画面
                    String currentDay = getCurrentSelectedDay();
                    Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleForm(
                            knBgColor: Constants.settngThemeColor,
                            knFontColor: Colors.white,
                            pagePath: subtitle,
                            preSelectedDay: currentDay, // 传递当前选中的星期
                          ),
                        )).then((value) {
                      if (value == true) {
                        _fetchLessonData();
                      }
                    });
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            unselectedLabelColor: Colors.black,
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
          Expanded(
            child: Stack(
              children: [
                // 原有的FutureBuilder
                FutureBuilder<List<KnFixLsn001Bean>>(
                  future: futureFixLsnList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !_isLoading) {
                      // 当连接状态是等待中，但_isLoading为false时不显示任何内容
                      // 因为我们将使用全屏的加载指示器
                      return Container();
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      return TabBarView(
                        controller: _tabController,
                        children: weekDays
                            .map((day) => buildLessonList(snapshot.data!, day))
                            .toList(),
                      );
                    } else {
                      return const Center(child: Text(""));
                    }
                  },
                ),

                // 加载指示器层
                if (_isLoading)
                  Center(
                    child: KnLoadingIndicator(
                        color: widget.knBgColor), // 使用自定义的加载器进度条
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLessonList(List<KnFixLsn001Bean> lessons, String dayIndex) {
    // 根据特定的日子过滤课程
    var dayLessons =
        lessons.where((lesson) => lesson.fixedWeek == dayIndex).toList();

    if (dayLessons.isEmpty) {
      return const Center(child: Text(""));
    }

    return ListView.builder(
      itemCount: dayLessons.length,
      itemBuilder: (context, index) {
        return buildLessonCard(dayLessons[index]);
      },
    );
  }

  Widget buildLessonCard(KnFixLsn001Bean lesson) {
    // 创建一个Card小部件，用于显示每个课程的详细信息
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
            backgroundImage: AssetImage('images/student-placeholder.png')),
        title: Text(lesson.studentName),
        subtitle: Row(
          children: <Widget>[
            // 为科目名称设置像素的左间距
            const SizedBox(width: 48),
            Expanded(
              child: Text(
                lesson.subjectName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            // const Spacer(), // 先不要删除，留着学习：这会填充所有可用空间
            Container(
              // 为固定时间设置像素的右间距
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                lesson.classTime,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Row的宽度只足够包含子控件
          children: <Widget>[
            // 编辑按钮
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _isLoading
                  ? null // 如果正在加载，禁用按钮
                  : () {
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleFormEdit(
                            lesson: lesson,
                            knBgColor: Constants.settngThemeColor,
                            knFontColor: Colors.white,
                            pagePath: subtitle,
                          ),
                        ),
                      ).then((value) {
                        // 检查返回值，如果为true，则重新加载数据
                        if (value == true) {
                          _fetchLessonData();
                        }
                      });
                    },
            ),
            // 删除按钮
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading
                  ? null // 如果正在加载，禁用按钮
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('删除确认'),
                            content: Text('确定要删除${lesson.studentName}的固定排课吗？'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('取消'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // 关闭对话框
                                },
                              ),
                              TextButton(
                                child: const Text('确定'),
                                onPressed: () {
                                  // 执行删除操作
                                  deleteLesson(lesson);
                                  Navigator.of(context).pop(); // 关闭对话框
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  // 删除课程的函数
  void deleteLesson(KnFixLsn001Bean lesson) {
    setState(() {
      _isLoading = true; // 开始删除操作前设置为true
    });

    final String apiUrl =
        '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoDelete}/${lesson.studentId}/${lesson.subjectId}/${lesson.fixedWeek}';
    http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // 添加内容类型头
      },
    ).then((response) {
      setState(() {
        _isLoading = false; // 操作完成后设置为false
      });

      if (response.statusCode == 200) {
        // 调用重新加载数据的函数
        reloadData(lesson.fixedWeek);
      } else {
        // 错误处理
        if (kDebugMode) {
          print("删除失败: ${response.body}");
        }
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false; // 出错时也要设置为false
      });

      // 错误处理
      if (kDebugMode) {
        print("出现错误: $error");
      }
    });
  }

  void reloadData(String fixedWeek) {
    // 重新加载数据
    _fetchLessonData();

    // 更新状态以重建UI
    futureFixLsnList.whenComplete(() {
      setState(() {
        // 将TabController的索引设置为被删除数据的fixedWeek对应的索引
        _tabController.index = weekDays.indexOf(fixedWeek);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
