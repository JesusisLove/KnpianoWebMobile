import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'dart:convert';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';
import 'knfixlsn001_add.dart';
import 'knfixlsn001_edit.dart';
import 'KnFixLsn001Bean.dart';

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

class ClassSchedulePageState extends State<ClassSchedulePage> with SingleTickerProviderStateMixin {
    final String titleName = '固定排课一览';
  late TabController _tabController;
  late Future<List<KnFixLsn001Bean>> futureFixLsnList; // 增加一个Future列表，用于存储异步加载的数据
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // 画面初期化
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    futureFixLsnList = fetchLessons(); // 在初始化时调用fetchLessons，并将结果存储在futureFixLsnList中
  }

  // 画面初期化：取得所有学生信息
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
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: KnAppBar(
        title: titleName,
        subtitle: '${widget.pagePath} >> $titleName',
        context: context,
        appBarBackgroundColor: widget.knBgColor, // 自定义AppBar背景颜色
        titleColor: Color.fromARGB(widget.knFontColor.alpha, // 自定义标题颜色
                                    widget.knFontColor.red - 20, 
                                    widget.knFontColor.green - 20, 
                                    widget.knFontColor.blue - 20),

        subtitleBackgroundColor: Color.fromARGB(widget.knFontColor.alpha, // 自定义底部文本框背景颜色
                                    widget.knFontColor.red + 20, 
                                    widget.knFontColor.green + 20, 
                                    widget.knFontColor.blue + 20),

        subtitleTextColor: Colors.white, // 自定义底部文本颜色
        titleFontSize: 20.0, // 自定义标题字体大小
        subtitleFontSize: 12.0, // 自定义底部文本字体大小
        actions: [
        IconButton(
          icon: const Icon(Icons.add),
          color: Colors.white,
          onPressed: () {
            Navigator.push<bool>(
              context, 
              MaterialPageRoute(
                builder: (context) =>  ScheduleForm(
                                            knBgColor: Constants.settngThemeColor,
                                          knFontColor: Colors.white,
                                             pagePath: titleName,),
              )
            ).then((value){
              if (value == true) {
                setState(() {
                  futureFixLsnList = fetchLessons();
                });
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
          child: FutureBuilder<List<KnFixLsn001Bean>>(
            future: futureFixLsnList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.hasData) {
                return TabBarView(
                  controller: _tabController,
                  children: weekDays.map((day) => buildLessonList(snapshot.data!, day)).toList(),
                );
              } else {
                return const Center(child: Text("No data available"));
              }
            },
          ),
        ),
      ],
    ),
  );
}

  Widget buildLessonList(List<KnFixLsn001Bean> lessons, String dayIndex) {
    // 根据特定的日子过滤课程
    var dayLessons = lessons.where((lesson) => lesson.fixedWeek == dayIndex).toList();
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
        leading: const CircleAvatar(backgroundImage: AssetImage('images/student-placeholder.png')),
        title: Text(lesson.studentName),
        subtitle: Row(
          children: <Widget>[
            // 为科目名称设置像素的左间距
            const SizedBox(width: 48 ), 
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
              // 编辑按钮的事件处理函数
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleFormEdit(
                                                  lesson: lesson,
                                               knBgColor: Constants.settngThemeColor,
                                             knFontColor: Colors.white,
                                                pagePath: titleName,
                                             ),
                    ),
                  ).then((value) {
                    // 检查返回值，如果为true，则重新加载数据
                    if (value == true) {
                      setState(() {
                        futureFixLsnList = fetchLessons();
                      });
                    }
                  });
                },
              ),
              // 删除按钮
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
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
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.fixedLsnInfoDelete}/${lesson.studentId}/${lesson.subjectId}/${lesson.fixedWeek}';
    http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // 添加内容类型头
      },
    )
    .then((response) {
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
      // 错误处理
      if (kDebugMode) {
        print("出现错误: $error");
      }
    });
  }

  void reloadData(String fixedWeek) {
    // 重新加载数据
    futureFixLsnList = fetchLessons();
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
