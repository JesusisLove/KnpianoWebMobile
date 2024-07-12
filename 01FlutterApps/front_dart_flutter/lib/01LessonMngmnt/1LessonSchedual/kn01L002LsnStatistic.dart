import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Kn01L002LsnStatistic extends StatefulWidget {
  @override
  _Kn01L002LsnStatisticState createState() => _Kn01L002LsnStatisticState();
}

class _Kn01L002LsnStatisticState extends State<Kn01L002LsnStatistic> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Subject> subjects = []; // 假设我们有一个Subject类来存储每个科目的数据

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 这里应该从数据源获取实际数据
    _fetchData();
  }

  void _fetchData() {
    // 模拟数据获取
    subjects = [
      Subject(
        name: "数学",
        payStyle: 1,
        monthlyLessons: {
          1: LessonCount(monthPlan: 4, monthExtra: 2),
          2: LessonCount(monthPlan: 3, monthExtra: 1),
          // ... 其他月份数据
        },
      ),
      // ... 其他科目
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("课程进度统计"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Text(subjects[index].name),
            Container(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 12,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (double value) {
                        return '${value.toInt() + 1}月';
                      },
                    ),
                  ),
                  barGroups: _generateBarGroups(subjects[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(Subject subject) {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < 12; i++) {
      LessonCount? count = subject.monthlyLessons[i + 1];
      if (count != null) {
        groups.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: count.monthPlan.toDouble(),
              colors: [Colors.blue],
              width: 16,
            ),
            BarChartRodData(
              y: count.monthExtra.toDouble(),
              colors: [Colors.pink],
              width: 16,
            ),
          ],
        ));
      } else {
        groups.add(BarChartGroupData(x: i, barRods: []));
      }
    }
    return groups;
  }

  Widget _buildPendingLessonsView() {
    return Center(child: Text("还未上课统计"));
  }
}

class Subject {
  final String name;
  final int payStyle;
  final Map<int, LessonCount> monthlyLessons;

  Subject({required this.name, required this.payStyle, required this.monthlyLessons});
}

class LessonCount {
  final int monthPlan;
  final int monthExtra;

  LessonCount({required this.monthPlan, required this.monthExtra});
}