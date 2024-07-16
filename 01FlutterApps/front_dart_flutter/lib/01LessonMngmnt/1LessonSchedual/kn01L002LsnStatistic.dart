import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http; // 新增：导入http包
import 'dart:convert'; // 新增：导入json解码

import '../../02LsnFeeMngmnt/Kn02F002FeeBean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';

// 新增：导入Kn02F002FeeBean类
import '../../Constants.dart';

// ignore: must_be_immutable
class Kn01L002LsnStatistic extends StatefulWidget {
  Kn01L002LsnStatistic({
    super.key, 
    required this.stuId, 
    required this.stuName,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });
  final String stuId;
  final String stuName;
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  late String pagePath ;

  @override
  // ignore: library_private_types_in_public_api
  _Kn01L002LsnStatisticState createState() => _Kn01L002LsnStatisticState();
}

class _Kn01L002LsnStatisticState extends State<Kn01L002LsnStatistic> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<LessonCount>> subjectsData = {};
  final String titleName = '课程进度统计';

  // 新增：选择年份相关变量
  late List<int> _years;
  late int _selectedYear;

  // 新增：存储从后端获取的数据
  List<Kn02F002FeeBean> staticLsnList = [];

  @override
  void initState() {
    super.initState();
    widget.pagePath = '${widget.pagePath} >> $titleName';
    _tabController = TabController(length: 2, vsync: this);

    // 新增：初始化年份列表和选中年份
    int currentYear = DateTime.now().year;
    _years = List.generate(currentYear - 2017, (index) => currentYear - index);
    _selectedYear = currentYear;

    _fetchData(); // 修改：在初始化时调用_fetchData
  }

  // 修改：_fetchData方法
  Future<void> _fetchData() async {
    final String apiLsnSignedStatisticUrl = '${KnConfig.apiBaseUrl}${Constants.apiLsnSignedStatistic}/${widget.stuId}/$_selectedYear';
    
    try {
      final response = await http.get(Uri.parse(apiLsnSignedStatisticUrl));
      if (response.statusCode == 200) {
        // 使用 utf8.decode 来正确处理字符编码
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        staticLsnList = jsonData.map((item) => Kn02F002FeeBean.fromJson(item)).toList();
        _processData();
      } else {
        // 处理错误情况
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // 处理异常
      print('Error fetching data: $e');
      if (e is HttpException) {
        print('HttpException: ${e.message}');
      } else if (e is SocketException) {
        print('SocketException: ${e.message}');
      }
    }
  }

  // 新增：处理数据的方法
  void _processData() {
    subjectsData.clear();
    List<String> uniqueSubjects = getUniqueSubjectNames(staticLsnList);
    
    for (var subjectName in uniqueSubjects) {
      List<LessonCount> monthlyData = List.generate(12, (_) => LessonCount(monthRegular: 0, monthPlan: 0, monthExtra: 0));
      
      for (var item in staticLsnList.where((item) => item.subjectName == subjectName)) {
        List<String> dateParts = item.lsnMonth.split('-');
        if (dateParts.length == 2) {
          int monthIndex = int.parse(dateParts[1]) - 1; // 将月份转换为0-11的索引
          if (monthIndex >= 0 && monthIndex < 12) {
            LessonCount newCount = convertToLessonCount(item);
            monthlyData[monthIndex] = LessonCount(
              monthRegular: monthlyData[monthIndex].monthRegular + newCount.monthRegular,
              monthPlan: monthlyData[monthIndex].monthPlan + newCount.monthPlan,
              monthExtra: monthlyData[monthIndex].monthExtra + newCount.monthExtra
            );
          }
        }
      }
      
      subjectsData[subjectName] = monthlyData;
    }

    setState(() {});
  }

  // 把从后端取出来的结果集，对科目名称去掉重复处理
  List<String> getUniqueSubjectNames(List<Kn02F002FeeBean> staticLsnList) {
    Set<String> uniqueSubjects = <String>{};
    
    for (var lesson in staticLsnList) {
      uniqueSubjects.add(lesson.subjectName);
    }
    
    List<String> sortedUniqueSubjects = uniqueSubjects.toList()..sort();
    return sortedUniqueSubjects;
  }
  // 新增：显示年份选择器
  void _showYearPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: _years.indexOf(_selectedYear),
            ),
            onSelectedItemChanged: (int selectedItem) {
              setState(() {
                _selectedYear = _years[selectedItem];
                _fetchData(); // 修改：在年份改变时重新获取数据
              });
            },
            children: List<Widget>.generate(_years.length, (int index) {
              return Center(
                child: Text(
                  _years[index].toString(),
                ),
              );
            }),
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
        subtitle: widget.pagePath,
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(widget.knFontColor.alpha,
                                   widget.knFontColor.red - 20, 
                                   widget.knFontColor.green - 20, 
                                   widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(widget.knFontColor.alpha,
                                   widget.knFontColor.red + 20, 
                                   widget.knFontColor.green + 20, 
                                   widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                // bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "上课完了统计"),
                      Tab(text: "还未上课统计"),
                    ],
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: TextButton(
                    onPressed: _showYearPicker,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(80, 48),
                    ),
                    child: Text('$_selectedYear'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // 添加一些垂直间距
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCompletedLessonsView(),
                _buildPendingLessonsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 修改：_buildCompletedLessonsView方法
  Widget _buildCompletedLessonsView() {
    return ListView.builder(
      itemCount: subjectsData.length,
      itemBuilder: (context, index) {
        String subject = subjectsData.keys.elementAt(index);
        List<LessonCount> lessonCounts = subjectsData[subject]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                subject,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 420,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: _generateLineBarsData(lessonCounts),
                      minY: 0,
                      maxY: _calculateMaxY(lessonCounts),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('${value.toInt() + 1}月'),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(), // 添加分隔线
          ],
        );
      },
    );
  }

  // 修改：_generateLineBarsData方法
  List<LineChartBarData> _generateLineBarsData(List<LessonCount> lessonCounts) {
    List<FlSpot> regularSpots = [];
    List<FlSpot> planSpots = [];
    List<FlSpot> extraSpots = [];

    for (int i = 0; i < lessonCounts.length; i++) {
      double month = i.toDouble(); // 使用索引作为月份（0-11）
      regularSpots.add(FlSpot(month, lessonCounts[i].monthRegular));
      planSpots.add(FlSpot(month, lessonCounts[i].monthPlan));
      extraSpots.add(FlSpot(month, lessonCounts[i].monthExtra));
    }

    return [
      LineChartBarData(
        spots: regularSpots,
        isCurved: false,
        color: Colors.green,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: planSpots,
        isCurved: false,
        color: Colors.blue,
        barWidth: 1, // 调整曲线的粗细
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: extraSpots,
        isCurved: false,
        color: Colors.red,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  // 新增：计算Y轴最大值的方法
  double _calculateMaxY(List<LessonCount> lessonCounts) {
    double maxY = 0;
    for (var count in lessonCounts) {
      double total = count.monthRegular + count.monthPlan + count.monthExtra;
      if (total > maxY) maxY = total;
    }
    return maxY.ceilToDouble();
  }

  Widget _buildPendingLessonsView() {
    return const Center(child: Text("还未上课统计"));
  }

// 创建一个转换函数
LessonCount convertToLessonCount(Kn02F002FeeBean feeBean) {
  return LessonCount(
    monthRegular: feeBean.totalLsnCount0,
    monthPlan: feeBean.totalLsnCount1,
    monthExtra: feeBean.totalLsnCount2,
  );
}

}

// 修改：LessonCount类
class LessonCount {
  late final double monthRegular;
  late final double monthPlan;
  late final double monthExtra;

  LessonCount({
    required this.monthRegular,
    required this.monthPlan,
    required this.monthExtra,
  });
}