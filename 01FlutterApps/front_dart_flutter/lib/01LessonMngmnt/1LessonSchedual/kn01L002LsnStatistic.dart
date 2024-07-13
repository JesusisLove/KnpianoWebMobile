import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../CommonProcess/customUI/KnAppBar.dart';

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

  @override
  void initState() {
    super.initState();
    widget.pagePath = '${widget.pagePath} >> $titleName';
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  void _fetchData() {
    subjectsData = {
      for (int i = 1; i <= 20; i++)
        '科目$i': List.generate(12, (index) => LessonCount(monthPlan: 3 + (index + i) % 4, monthExtra: 1 + (index + i) % 3)),
    };
    setState(() {});
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
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "上课完了统计"),
              Tab(text: "还未上课统计"),
            ],
          ),
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
                  width: 420, // 调整图表的宽度
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LineChart( // 修改：将BarChart改为LineChart
                    LineChartData( // 修改：将BarChartData改为LineChartData
                      lineBarsData: _generateLineBarsData(lessonCounts), // 新增：生成线图数据
                      minY: 0,
                      maxY: 8, //取所有记录中最大的那个课时值
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

  // 新增：生成线图数据的方法
  List<LineChartBarData> _generateLineBarsData(List<LessonCount> lessonCounts) {
    List<FlSpot> planSpots = [];
    List<FlSpot> extraSpots = [];

    for (int i = 0; i < lessonCounts.length; i++) {
      planSpots.add(FlSpot(i.toDouble(), lessonCounts[i].monthPlan.toDouble()));
      extraSpots.add(FlSpot(i.toDouble(), lessonCounts[i].monthExtra.toDouble()));
    }

    return [
      LineChartBarData(
        spots: planSpots,
        isCurved: false,
        color: Colors.blue,
        barWidth: 1, // 调整曲线的粗细
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: extraSpots,
        isCurved: false,
        color: Colors.pink,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  Widget _buildPendingLessonsView() {
    return const Center(child: Text("还未上课统计"));
  }
}

class LessonCount {
  final int monthPlan;
  final int monthExtra;

  LessonCount({required this.monthPlan, required this.monthExtra});
}