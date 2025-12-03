// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../CommonProcess/customUI/KnLoadingIndicator.dart';
import '../Constants.dart';
import '../01LessonMngmnt/1LessonSchedual/kn01L002LsnStatistic.dart';
import '../01LessonMngmnt/1LessonSchedual/kn01L003ExtraToSche.dart';
import '../01LessonMngmnt/1LessonSchedual/kn01L003ExtraPiesesIntoOne.dart';

// Bean class for lesson counting data
class Kn04I003LsnCountingBean {
  final String stuId;
  final String stuName;
  final String subjectId;
  final String subjectName;
  final int payStyle;
  final double standartYearLsnCnt;
  final double totalLsnCnt0; // 按课时收费
  final double totalLsnCnt1; // 计划课
  final double totalLsnCnt2; // 加时课（整节加课课统计）
  final double totalLsnCnt3; // 加时课（零碎加课课统计

  Kn04I003LsnCountingBean({
    required this.stuId,
    required this.stuName,
    required this.subjectId,
    required this.subjectName,
    required this.payStyle,
    required this.standartYearLsnCnt,
    required this.totalLsnCnt0,
    required this.totalLsnCnt1,
    required this.totalLsnCnt2,
    required this.totalLsnCnt3,
  });

  factory Kn04I003LsnCountingBean.fromJson(Map<String, dynamic> json) {
    return Kn04I003LsnCountingBean(
      stuId: json['stuId'] as String? ?? '',
      stuName: json['stuName'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      payStyle: json['payStyle'] as int? ?? 0,
      standartYearLsnCnt: json['yearLsnCnt']?.toDouble() ?? 0.0,
      totalLsnCnt0: json['totalLsnCnt0']?.toDouble() ?? 0.0,
      totalLsnCnt1: json['totalLsnCnt1']?.toDouble() ?? 0.0,
      totalLsnCnt2: json['totalLsnCnt2']?.toDouble() ?? 0.0,
      totalLsnCnt3: json['totalLsnCnt3']?.toDouble() ?? 0.0,
    );
  }

  double get totalLessons => totalLsnCnt0 + totalLsnCnt1 + totalLsnCnt2;
}

class Kn04I003LsnCounting extends StatefulWidget {
  const Kn04I003LsnCounting({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  final Color knBgColor;
  final Color knFontColor;
  final String pagePath;

  @override
  // ignore: library_private_types_in_public_api
  _Kn04I003LsnCountingState createState() => _Kn04I003LsnCountingState();
}

class _Kn04I003LsnCountingState extends State<Kn04I003LsnCounting> {
  int selectedYear = DateTime.now().year;
  int selectedMonthFrom = 1;
  int selectedMonthTo = DateTime.now().month;

  List<int> years = List.generate(
          DateTime.now().year - 2017, (index) => DateTime.now().year - index)
      .toList();
  List<int> months = List.generate(12, (index) => index + 1);

  List<Kn04I003LsnCountingBean> lessonCountingData = [];
  bool isLoading = true;
  final String titleName = '学生课程统计';
  late String pagePath;

  // 搜索功能相关
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // final double maxLessons = 43.0; // 满课时数

  @override
  void initState() {
    super.initState();
    pagePath = '${widget.pagePath} >> $titleName';
    // 页面初始加载 - 调用第一个API
    loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 过滤学生数据
  List<Kn04I003LsnCountingBean> get filteredLessonData {
    if (_searchQuery.isEmpty) {
      return lessonCountingData;
    }
    return lessonCountingData.where((student) {
      return student.stuName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // 页面初始加载数据 - 使用 /mb_kn_lsn_counting
  Future<void> loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.intergLsnCounting}';
      // print('Loading initial data from: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonData = json.decode(decodedBody);

        setState(() {
          lessonCountingData = jsonData
              .map((json) => Kn04I003LsnCountingBean.fromJson(json))
              .toList();
          isLoading = false;
        });

        // print('Initial data loaded: ${lessonCountingData.length} records');
      } else {
        throw Exception('Failed to load initial data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 用户筛选查询 - 使用 /mb_kn_lsn_counting_search/{year}/{monthFrom}/{monthTo}
  Future<void> searchWithFilters() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.intergLsnCountingSearch}'
          '/$selectedYear'
          '/${selectedMonthFrom.toString().padLeft(2, '0')}'
          '/${selectedMonthTo.toString().padLeft(2, '0')}';

      print('Searching with filters: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonData = json.decode(decodedBody);

        setState(() {
          lessonCountingData = jsonData
              .map((json) => Kn04I003LsnCountingBean.fromJson(json))
              .toList();
          isLoading = false;
        });

        // print('Search completed: ${lessonCountingData.length} records');
      } else {
        throw Exception('Failed to search data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 显示搜索对话框
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索学生'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '请输入学生姓名',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
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
        addInvisibleRightButton: false,
        currentNavIndex: 3,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: widget.knFontColor),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildLegend(),
          Expanded(
            child: isLoading
                ? Center(
                    child: KnLoadingIndicator(color: widget.knBgColor),
                  )
                : _buildLessonChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Text(
            '$selectedYear年度课程统计报表',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterItem(
                  '统计年度',
                  '$selectedYear年',
                  () => _showYearPicker(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  '开始月份',
                  '${selectedMonthFrom.toString().padLeft(2, '0')}月',
                  () => _showMonthPicker(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterItem(
                  '结束月份',
                  '${selectedMonthTo.toString().padLeft(2, '0')}月',
                  () => _showMonthPicker(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: widget.knBgColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.knBgColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.knBgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('课时课', Colors.green),
          _buildLegendItem('计划课', widget.knBgColor),
          _buildLegendItem('加时课', Colors.pink),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonChart() {
    final displayData = filteredLessonData;

    if (lessonCountingData.isEmpty) {
      return const Center(
        child: Text(
          '暂无数据',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // 如果搜索后无结果
    if (displayData.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到匹配的学生',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请尝试其他关键词',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 显示搜索结果计数
        if (_searchQuery.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.knBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.knBgColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.knBgColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '找到 ${displayData.length} 名学生',
                  style: TextStyle(
                    color: widget.knBgColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayData.length,
            itemBuilder: (context, index) {
              final item = displayData[index];
              return _buildStudentLessonCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentLessonCard(Kn04I003LsnCountingBean item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：学生姓名、科目、总计、完成度
            Row(
              children: [
                // 学生姓名（可点击跳转到课程进度统计页面）
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      // 跳转到课程进度统计页面
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Kn01L002LsnStatistic(
                            stuId: item.stuId,
                            stuName: item.stuName,
                            knBgColor: Constants.lessonThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "综合管理 >> 学生课程统计",
                          ),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          // 如果计划总课时达到43节,显示🏆图标
                          if (item.totalLsnCnt1 >= item.standartYearLsnCnt &&
                              item.payStyle == 1)
                            const TextSpan(
                              text: '✅🏆',
                              style: TextStyle(fontSize: 16),
                            ),
                          TextSpan(
                            text: item.stuName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // 改为蓝色，表示可点击
                              decoration:
                                  TextDecoration.underline, // 添加下划线，表示可点击
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 科目标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.knBgColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.subjectName,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.knBgColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 总计
                Text(
                  '总计: ${item.totalLessons.toStringAsFixed(1)}节',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                // 计划总课时
                Text(
                  '计划: ${item.standartYearLsnCnt == 0 ? 43 : item.standartYearLsnCnt.toStringAsFixed(1)}节',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                // 完成度
                Text(
                  '完成度: ${((item.totalLsnCnt1 / (item.standartYearLsnCnt == 0 ? 43 : item.standartYearLsnCnt)) * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.totalLsnCnt1 >=
                            (item.standartYearLsnCnt == 0
                                ? 43
                                : item.standartYearLsnCnt)
                        ? Colors.green
                        : widget.knBgColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 课程进度条
            if (item.totalLsnCnt0 > 0)
              _buildLessonBar(
                  '时费课',
                  item.totalLsnCnt0,
                  (item.standartYearLsnCnt == 0 ? 43 : item.standartYearLsnCnt),
                  Colors.green),
            if (item.totalLsnCnt1 > 0)
              _buildLessonBar(
                  '计划课',
                  item.totalLsnCnt1,
                  (item.standartYearLsnCnt == 0 ? 43 : item.standartYearLsnCnt),
                  widget.knBgColor),
            if (item.totalLsnCnt2 > 0)
              _buildLessonBar(
                '加时课',
                item.totalLsnCnt2,
                (item.standartYearLsnCnt == 0 ? 43 : item.standartYearLsnCnt),
                Colors.pink,
                onTap: () {
                  // 跳转到加课消化管理页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExtraToSchePage(
                        stuId: item.stuId,
                        stuName: item.stuName,
                        knBgColor: widget.knBgColor,
                        knFontColor: widget.knFontColor,
                        pagePath: pagePath,
                      ),
                    ),
                  );
                },
              ),
            if (item.totalLsnCnt3 > 0)
              _buildLessonBar(
                '零碎课',
                item.totalLsnCnt3,
                (item.standartYearLsnCnt == 0 ? 43 : item.standartYearLsnCnt),
                Colors.pink,
                onTap: () {
                  // 跳转到零碎加课拼整课页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Kn01L003ExtraPiesesIntoOne(
                        stuId: item.stuId,
                        stuName: item.stuName,
                        knBgColor: widget.knBgColor,
                        knFontColor: widget.knFontColor,
                        pagePath: pagePath,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonBar(
      String label, double count, double maxLessons, Color color,
      {VoidCallback? onTap}) {
    double barWidth = (count / maxLessons).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧：课程标签（固定宽度）
          SizedBox(
            width: 40,
            child: onTap != null
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
          ),
          const SizedBox(width: 2),
          // 中间：进度条（自动伸缩填充）
          Expanded(
            child: Container(
              height: 8,
              child: Stack(
                children: [
                  // 底层：白色进度条（固定长度，代表满额课时）
                  Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  // 上层：彩色进度条
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: barWidth,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          // 右侧：课时标签（固定宽度）
          SizedBox(
            width: 42,
            child: Text(
              '${count.toStringAsFixed(1)}节',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 350,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.knBgColor, // 添加背景颜色
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white), // 白色文字
                    ),
                  ),
                  const Text(
                    '选择年度',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // 白色文字
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 用户选择后进行筛选查询
                      searchWithFilters();
                    },
                    padding: EdgeInsets.zero,
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.white), // 白色文字
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                    initialItem: years.indexOf(selectedYear)),
                children: years
                    .map((int year) => Center(child: Text('${year}年')))
                    .toList(),
                onSelectedItemChanged: (int index) =>
                    setState(() => selectedYear = years[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, bool isFromMonth) {
    int currentMonth = isFromMonth ? selectedMonthFrom : selectedMonthTo;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 350,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.knBgColor, // 添加背景颜色
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white), // 白色文字
                    ),
                  ),
                  Text(
                    isFromMonth ? '选择开始月份' : '选择结束月份',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // 白色文字
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 用户选择后进行筛选查询
                      searchWithFilters();
                    },
                    padding: EdgeInsets.zero,
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.white), // 白色文字
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 40,
                scrollController:
                    FixedExtentScrollController(initialItem: currentMonth - 1),
                children: months
                    .map((int month) => Center(
                        child: Text('${month.toString().padLeft(2, '0')}月')))
                    .toList(),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    if (isFromMonth) {
                      selectedMonthFrom = months[index];
                    } else {
                      selectedMonthTo = months[index];
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
