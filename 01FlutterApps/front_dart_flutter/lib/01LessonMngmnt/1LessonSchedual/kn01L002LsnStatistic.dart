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
          bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "上课完了统计"),
            Tab(text: "还未上课统计"),
          ],
        ),
      ),


      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompletedLessonsView(),
          _buildPendingLessonsView(),
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
                  width: 800, // 调整图表的宽度
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 12,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.round().toString(),
                              const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
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
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
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
                      barGroups: _generateBarGroups(lessonCounts),
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

  List<BarChartGroupData> _generateBarGroups(List<LessonCount> lessonCounts) {
    return List.generate(12, (index) {
      LessonCount count = lessonCounts[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.monthPlan.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.all(Radius.zero),
          ),
          BarChartRodData(
            toY: count.monthExtra.toDouble(),
            color: Colors.pink,
            width: 16,
            borderRadius: const BorderRadius.all(Radius.zero),
          ),
        ],
        showingTooltipIndicators: [0, 1],
      );
    });
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