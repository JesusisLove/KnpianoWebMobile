import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http; // 导入http包
import 'dart:convert'; // 导入json解码

import '../../02LsnFeeMngmnt/Kn02F002FeeBean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';

// 导入Kn02F002FeeBean类
import '../../Constants.dart';
import 'CalendarPage.dart';
import 'Kn01L002LsnBean.dart';

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
  late String pagePath;

  @override
  // ignore: library_private_types_in_public_api
  _Kn01L002LsnStatisticState createState() => _Kn01L002LsnStatisticState();
}

class _Kn01L002LsnStatisticState extends State<Kn01L002LsnStatistic>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<LessonCount>> subjectsScanedLsnData = {};
  final String titleName = '课程进度统计';

  // 选择年份相关变量
  late List<int> _years;
  late int _selectedYear;

  // 存储从后端获取的数据
  List<Kn02F002FeeBean> staticScanedLsnList = [];
  // 新增：初始化未上课数据数组
  List<Kn01L002LsnBean> staticUnScanedLsnList = [];

  @override
  void initState() {
    super.initState();
    widget.pagePath = '${widget.pagePath} >> $titleName';
    _tabController = TabController(length: 2, vsync: this);

    // 初始化年份列表和选中年份
    int currentYear = DateTime.now().year;
    _years = List.generate(currentYear - 2017, (index) => currentYear - index);
    _selectedYear = currentYear;

    _fetchData(); // 修改：在初始化时调用_fetchData
  }

  // 修改：_fetchData方法
  Future<void> _fetchData() async {
    // 已上完课的结果集取得
    final String apiLsnScanedStatisticUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiLsnSignedStatistic}/${widget.stuId}/$_selectedYear';
    try {
      final response = await http.get(Uri.parse(apiLsnScanedStatisticUrl));
      if (response.statusCode == 200) {
        // 使用 utf8.decode 来正确处理字符编码
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        staticScanedLsnList =
            jsonData.map((item) => Kn02F002FeeBean.fromJson(item)).toList();
        _processScanedLsnData();
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

    // 新增：未上课的结果集取得
    final String apiLsnUnScanedStatisticUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiLsnUnSignedStatistic}/${widget.stuId}/$_selectedYear';
    try {
      final response = await http.get(Uri.parse(apiLsnUnScanedStatisticUrl));
      if (response.statusCode == 200) {
        // 使用 utf8.decode 来正确处理字符编码
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        staticUnScanedLsnList =
            jsonData.map((item) => Kn01L002LsnBean.fromJson(item)).toList();
        _processUnScanedLsnData();
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

  // 处理已经签到完了的课的数据的方法  staticUnScanedLsnList
  void _processScanedLsnData() {
    subjectsScanedLsnData.clear();
    List<String> uniqueSubjects = getUniqueSubjectNames(staticScanedLsnList);

    for (var subjectName in uniqueSubjects) {
      List<LessonCount> monthlyData = List.generate(
          12, (_) => LessonCount(monthRegular: 0, monthPlan: 0, monthExtra: 0));

      for (var item in staticScanedLsnList
          .where((item) => item.subjectName == subjectName)) {
        List<String> dateParts = item.lsnMonth.split('-');
        if (dateParts.length == 2) {
          int monthIndex = int.parse(dateParts[1]) - 1; // 将月份转换为0-11的索引
          if (monthIndex >= 0 && monthIndex < 12) {
            LessonCount newCount = convertToLessonCount(item);
            monthlyData[monthIndex] = LessonCount(
                monthRegular: monthlyData[monthIndex].monthRegular +
                    newCount.monthRegular,
                monthPlan:
                    monthlyData[monthIndex].monthPlan + newCount.monthPlan,
                monthExtra:
                    monthlyData[monthIndex].monthExtra + newCount.monthExtra);
          }
        }
      }

      subjectsScanedLsnData[subjectName] = monthlyData;
    }

    setState(() {});
  }

// 新增：未上课的结果集取得
  void _processUnScanedLsnData() {
    // 从后端取出未上课的结果集后，在此处理数据，把未上课的信息显示在ListView上，
    // ListView上显示课程名（subjectName），上课日期（注意如果调课日期不为空，上课日期就是调课日期（lsnAdjustedDate），
    // 如果调课日期（lsnAdjustedDate）为空，则上课日期就是schedualDate），然后在显示数据的每一行上加一个"查看"按钮
    setState(() {
      staticUnScanedLsnList.sort((a, b) {
        int dateComparison =
            (a.lsnAdjustedDate.isNotEmpty ? a.lsnAdjustedDate : a.schedualDate)
                .compareTo(b.lsnAdjustedDate.isNotEmpty
                    ? b.lsnAdjustedDate
                    : b.schedualDate);
        if (dateComparison != 0) return dateComparison;
        return a.subjectName.compareTo(b.subjectName);
      });
    });
  }

  // 把从后端取出来的结果集，对科目名称去掉重复处理
  List<String> getUniqueSubjectNames(
      List<Kn02F002FeeBean> staticScanedLsnList) {
    Set<String> uniqueSubjects = <String>{};
    for (var lesson in staticScanedLsnList) {
      uniqueSubjects.add(lesson.subjectName);
    }
    List<String> sortedUniqueSubjects = uniqueSubjects.toList()..sort();
    return sortedUniqueSubjects;
  }

  // 显示年份选择器
  void _showYearPicker() {
    int tempSelectedYear = _selectedYear;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250, // 减小高度以去除顶部空白
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)), // 添加顶部圆角
        ),
        child: ClipRRect(
          // 使用ClipRRect来裁剪内容，确保圆角效果
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              Container(
                height: 54, // 设置固定高度，您可以根据需要调整这个值
                padding: const EdgeInsets.symmetric(horizontal: 8), // 添加水平内边距
                color: const Color(0xFFE8F5E9), // 浅绿色背景
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('取消',
                          style: TextStyle(color: Colors.black)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('确定',
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        setState(() {
                          _selectedYear = tempSelectedYear;
                          _fetchData(); // 在点击确定按钮后，重新获取数据
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: _years.indexOf(_selectedYear),
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    tempSelectedYear = _years[selectedItem];
                  },
                  children: List<Widget>.generate(_years.length, (int index) {
                    return Center(
                      child: Text(
                        _years[index].toString(),
                        style: const TextStyle(
                          color: Color(0xFF1B5E20), // 年度的深绿色字体
                          fontSize: 20,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: '${widget.stuName}的$titleName',
        subtitle: "${widget.pagePath} >> $titleName",
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

  // 在 _Kn01L002LsnStatisticState 类中添加这个新方法
  double _getMaxLessonCount(List<LessonCount> lessonCounts) {
    double maxCount = 0;
    for (var count in lessonCounts) {
      double total = count.monthRegular + count.monthPlan + count.monthExtra;
      if (total > maxCount) maxCount = total;
    }
    return maxCount;
  }

  // 根据课程种别和上完的课程画线
  Widget _buildCompletedLessonsView() {
    return ListView.builder(
      itemCount: subjectsScanedLsnData.length,
      itemBuilder: (context, index) {
        String subject = subjectsScanedLsnData.keys.elementAt(index);
        List<LessonCount> lessonCounts = subjectsScanedLsnData[subject]!;

        // 计算最大课时
        double maxLessonCount = _getMaxLessonCount(lessonCounts);

        // 根据最大课时决定图表高度
        double chartHeight =
            maxLessonCount > 5.0 ? (maxLessonCount > 10 ? 200.0 : 250.0) : 150;

        // 计算计划课时合计和额外加课合计
        double totalPlanned =
            lessonCounts.fold(0, (sum, count) => sum + count.monthPlan);
        double totalExtra =
            lessonCounts.fold(0, (sum, count) => sum + count.monthExtra);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                subject,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
              child: Row(
                children: [
                  Text(
                    '计划课时合计: ${totalPlanned.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(width: 16), // 在两个文本之间添加间距
                  if (totalExtra > 0)
                    Text(
                      '额外加课合计: ${totalExtra.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: chartHeight, // Chart图的高度
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

  /// 修改：_generateLineBarsData方法
  /// 允许月计划课和课结算课的点和线（即，蓝点和蓝色以及绿点和绿线）落在横轴上
  /// 月加课的点和线不落在横轴上（即，当该月份的月加课和是零的时候，横轴上不显示）
  List<LineChartBarData> _generateLineBarsData(List<LessonCount> lessonCounts) {
    List<FlSpot> regularSpots = [];
    List<FlSpot> planSpots = [];
    List<FlSpot> extraSpots = [];

    double regularTotal = 0;
    double planTotal = 0;
    double extraTotal = 0;

    for (int i = 0; i < lessonCounts.length; i++) {
      double month = i.toDouble(); // 使用索引作为月份（0-11）
      regularTotal += lessonCounts[i].monthRegular;
      planTotal += lessonCounts[i].monthPlan;
      extraTotal += lessonCounts[i].monthExtra;

      regularSpots.add(FlSpot(month, lessonCounts[i].monthRegular));
      planSpots.add(FlSpot(month, lessonCounts[i].monthPlan));
      // 只有当 monthExtra 不为 0 时才添加点
      if (lessonCounts[i].monthExtra > 0) {
        extraSpots.add(FlSpot(month, lessonCounts[i].monthExtra));
      }
    }

    List<LineChartBarData> lineBarsData = [];

    // 课结算的情况下
    if (regularTotal > 0) {
      lineBarsData.add(LineChartBarData(
        spots: regularSpots,
        isCurved: false,
        color: Colors.green,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ));
    }

    // 月计划的情况下
    if (planTotal > 0) {
      lineBarsData.add(LineChartBarData(
        spots: planSpots,
        isCurved: false,
        color: Colors.blue,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ));
    }

    // 月加课的情况下
    if (extraTotal > 0) {
      lineBarsData.add(LineChartBarData(
        spots: extraSpots,
        isCurved: false,
        color: Colors.red.withOpacity(0.6),
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ));
    }

    return lineBarsData;
  }

  // 计算Y轴最大值的方法
  double _calculateMaxY(List<LessonCount> lessonCounts) {
    double maxY = 0;
    for (var count in lessonCounts) {
      double total = count.monthRegular + count.monthPlan + count.monthExtra;
      if (total > maxY) maxY = total;
    }
    return maxY.ceilToDouble();
  }

// 还未上课统计
  Widget _buildPendingLessonsView() {
    return ListView.builder(
      itemCount: staticUnScanedLsnList.length,
      itemBuilder: (context, index) {
        final lesson = staticUnScanedLsnList[index];
        final lessonDate = lesson.lsnAdjustedDate.isNotEmpty
            ? lesson.lsnAdjustedDate
            : lesson.schedualDate;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(lesson.subjectName),
            subtitle: Text('上课日期: $lessonDate'),
            trailing: ElevatedButton(
              child: const Text('查看'),
              onPressed: () async {
                // 将 onPressed 改为异步函数
                String targetDateTime = lessonDate.substring(0, 10);
                // 等待 CalendarPage 返回
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CalendarPage(focusedDay: targetDateTime)),
                );
                // 当 CalendarPage 关闭并返回到此页面时，刷新数据
                setState(() {
                  // 重新加载您的数据
                  _fetchData();
                });
              },
            ),
          ),
        );
      },
    );
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
  final double monthRegular;
  final double monthPlan;
  final double monthExtra;

  LessonCount({
    required this.monthRegular,
    required this.monthPlan,
    required this.monthExtra,
  });
}
