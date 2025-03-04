// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../02LsnFeeMngmnt/Kn02F002FeeBean.dart';
import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
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

  /* 存储从后端获取的数据 */
  // 初始化已上完课的数据数组
  List<Kn02F002FeeBean> staticScanedLsnList = [];
  // 初始化未上课数据数组
  List<Kn01L002LsnBean> staticUnScanedLsnList = [];
  // 初始化课程详细信息数组
  List<Kn01L002LsnBean> staticScanedLsnDetailsList = [];

  @override
  void initState() {
    super.initState();
    widget.pagePath = '${widget.pagePath} >> $titleName';
    _tabController = TabController(length: 2, vsync: this);

    // 初始化年份列表和选中年份
    int currentYear = DateTime.now().year;
    _years = List.generate(currentYear - 2017, (index) => currentYear - index);
    _selectedYear = currentYear;
    _fetchData();
  }

  Future<void> _fetchData() async {
    // 已上完课的结果集取得
    final String apiLsnSignedStatisticUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiLsnSignedStatistic}/${widget.stuId}/$_selectedYear';
    try {
      final response = await http.get(Uri.parse(apiLsnSignedStatisticUrl));
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
    }

    // 新增：获取课程详细信息
    await _fetchScanedLsnDetails();
  }

  String _getWeekday(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      switch (date.weekday) {
        case 1:
          return '(Mon)';
        case 2:
          return '(Tue)';
        case 3:
          return '(Wed)';
        case 4:
          return '(Thu)';
        case 5:
          return '(Fri)';
        case 6:
          return '(Sat)';
        case 7:
          return '(Sun)';
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  // 新增：获取课程详细信息的方法
  Future<void> _fetchScanedLsnDetails() async {
    final String apiLsnScanedLsnStatisticUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiLsnScanedLsnStatistic}/${widget.stuId}/$_selectedYear';
    try {
      final response = await http.get(Uri.parse(apiLsnScanedLsnStatisticUrl));
      if (response.statusCode == 200) {
        // 使用 utf8.decode 来正确处理字符编码
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        staticScanedLsnDetailsList =
            jsonData.map((item) => Kn01L002LsnBean.fromJson(item)).toList();
        _processScanedLsnDetails();
      } else {
        print('Failed to load scaned lesson details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching scaned lesson details: $e');
    }
  }

  // 处理已经签到完了的课的数据的方法
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

  // 新增：处理课程详细信息的方法
  void _processScanedLsnDetails() {
    // 在这里处理 staticScanedLsnDetailsList 的数据
    // 例如，可以按科目和月份对数据进行分组
    setState(() {});
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
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: "上课完了统计"),
                        Tab(text: "还未上课统计"),
                      ],
                      indicatorColor: Colors.green,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black54,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _showYearPicker,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: Text('$_selectedYear年'),
                  ),
                ],
              ),
            ),
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

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  subject,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
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
                child: Padding(
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
              // 新增：月份Tab和详细信息
              _buildMonthlyTabs(subject),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyTabs(String subject) {
    List<int> months = List.generate(12, (index) => index + 1);
    return DefaultTabController(
      length: months.length,
      // 修改：初始化Tab时设置当前月份为默认选中
      initialIndex: DateTime.now().month - 1,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: months.map((month) => Tab(text: '$month月')).toList(),
            labelColor: Colors.green, // 选中Tab的文字颜色
            unselectedLabelColor: Colors.black54, // 未选中Tab的文字颜色
            indicatorColor: Colors.green, // 指示器颜色
          ),
          SizedBox(
            height: 200, // 调整高度以适应内容
            child: TabBarView(
              children: months
                  .map((month) => _buildMonthTab(subject, month))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 新增：构建单个月份Tab的内容
  Widget _buildMonthTab(String subject, int month) {
    List<Kn01L002LsnBean> monthLessons = staticScanedLsnDetailsList
        .where((lesson) =>
            lesson.subjectName == subject &&
            (int.parse(lesson.schedualDate.substring(5, 7)) == month ||
                (lesson.lsnAdjustedDate.isNotEmpty &&
                    int.parse(lesson.lsnAdjustedDate.substring(5, 7)) ==
                        month)))
        .toList();

    return ListView.builder(
      itemCount: monthLessons.length,
      itemBuilder: (context, index) {
        return _buildLessonItem(monthLessons[index], month);
      },
    );
  }

  Widget _buildLessonItem(Kn01L002LsnBean lesson, int currentMonth) {
    String lessonType = getLessonTypeString(lesson);
    Color textColor = _getTextColor(lesson, currentMonth);

    // 2024-11-04 添加：检查是否是月加课类型
    bool isExtraLesson = lesson.lessonType == 2;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // 添加顶部对齐
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: Text(lesson.classDuration.toString()),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '种别: $lessonType',
                    style: TextStyle(
                        color: isExtraLesson ? Colors.pink : textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lesson.lsnAdjustedDate.isNotEmpty) ...[
                    Text(
                      '原定: ${_getWeekday(lesson.schedualDate)}  ${lesson.schedualDate}',
                      style: TextStyle(
                        color: isExtraLesson ? Colors.pink : textColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4), // 添加垂直间距
                    Text(
                      '调至: ${_getWeekday(lesson.lsnAdjustedDate)}  ${lesson.lsnAdjustedDate}',
                      style: TextStyle(
                          color: isExtraLesson ? Colors.pink : Colors.orange),
                    ),
                  ] else if (lesson.originalSchedualDate.isNotEmpty) ...[
                    Text(
                      '原加课: ${_getWeekday(lesson.originalSchedualDate)}  ${lesson.originalSchedualDate}',
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4), // 添加垂直间距
                    Text(
                      '现正课: ${_getWeekday(lesson.schedualDate)}  ${lesson.schedualDate}',
                      style: TextStyle(color: textColor),
                    ),
                  ] else ...[
                    Text(
                      '上课: ${_getWeekday(lesson.schedualDate)}  ${lesson.schedualDate}',
                      style: TextStyle(
                          color: isExtraLesson ? Colors.pink : textColor),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 新增：获取课程种别字符串
  String getLessonTypeString(Kn01L002LsnBean lesson) {
    bool isExtraToSche =
        (lesson.lessonType == 1 && lesson.originalSchedualDate.isNotEmpty);

    switch (lesson.lessonType) {
      case 0:
        return '时'; // 课时结算
      case 1:
        if (isExtraToSche) {
          return '转'; // 加课转正课
        } else {
          return '计'; // 月计划课
        }
      case 2:
        return '加'; // 月加课
      default:
        return '未知';
    }
  }

  // 新增：获取文本颜色
  Color _getTextColor(Kn01L002LsnBean lesson, int currentMonth) {
    int schedualMonth = int.parse(lesson.schedualDate.split('-')[1]);
    int adjustedMonth = lesson.lsnAdjustedDate.isNotEmpty
        ? int.parse(lesson.lsnAdjustedDate.split('-')[1])
        : schedualMonth;

    if (schedualMonth == currentMonth && adjustedMonth != currentMonth) {
      return Colors.grey;
    } else if (schedualMonth != currentMonth && adjustedMonth == currentMonth) {
      return Colors.orange;
    } else {
      if (lesson.originalSchedualDate.isNotEmpty) {
        // 加课换正课颜色
        return const Color.fromARGB(255, 167, 47, 4);
      }
      return Colors.black;
    }
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
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              child: Text((index + 1).toString()),
            ),
            title: Text(lesson.subjectName),
            subtitle: Text('上课日期: ${_getWeekday(lessonDate)} $lessonDate'),
            trailing: ElevatedButton(
              onPressed: () async {
                // 将 onPressed 改为异步函数
                // String targetDateTime = lessonDate.substring(0, 10);
                String targetDateTime = lessonDate;
                // 等待 CalendarPage 返回
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalendarPage(
                            focusedDay: targetDateTime,
                            stuId: lesson.stuId,
                          )),
                );
                // 当 CalendarPage 关闭并返回到此页面时，刷新数据
                setState(() {
                  // 重新加载您的数据
                  _fetchData();
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('查看'),
            ),
          ),
        );
      },
    );
  }

  double _getMaxLessonCount(List<LessonCount> lessonCounts) {
    double maxCount = 0;
    for (var count in lessonCounts) {
      double total = count.monthRegular + count.monthPlan + count.monthExtra;
      if (total > maxCount) maxCount = total;
    }
    return maxCount;
  }

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

    // 课结算的情况下,Chart图上的点用绿色标识
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

    // 月计划的情况下,Chart图上的点用蓝色色标识
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

    // 月加课的情况下,Chart图上的点用红色标识
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

  // 创建一个转换函数：把课程按照种别分类
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
