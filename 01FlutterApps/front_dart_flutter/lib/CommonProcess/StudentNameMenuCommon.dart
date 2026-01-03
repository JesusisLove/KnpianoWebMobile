// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig/KnApiConfig.dart';
import 'customUI/KnAppBar.dart';
import 'customUI/KnLoadingIndicator.dart';
import 'pageIdMapping.dart';

class StudentNameMenuCommon extends StatefulWidget {
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  final String pagePath;
  // 子画面迁移Id
  final String pageId;
  // 接受各业务画面传递过来的uri
  final String strUri;

  const StudentNameMenuCommon({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
    required this.pageId,
    required this.strUri,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StudentNameMenuCommonState createState() => _StudentNameMenuCommonState();
}

class _StudentNameMenuCommonState extends State<StudentNameMenuCommon>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> students = [];
  DisplayMode _displayMode = DisplayMode.medium;
  bool _isLoading = true; // 添加加载状态变量
  late AnimationController _animationController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 年度选择器相关
  int selectedYear = DateTime.now().year;
  List<int> years = List.generate(
    DateTime.now().year - 2024 + 1,
    (index) => 2024 + index,
  ).reversed.toList(); // 从当前年到2024年，降序排列

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    fetchStudents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStudents() async {
    setState(() {
      _isLoading = true; // 开始加载
    });
    // 将选择的年度作为参数传递给后台
    final String apiUrl = '${KnConfig.apiBaseUrl}${widget.strUri}/$selectedYear';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // 直接转换数据而不去重
        final List<Map<String, dynamic>> studentsList = data.map((item) {
          return {
            'id': item['stuId'].toString(),
            'name':
                item['nikName'] != null && item['nikName'].toString().isNotEmpty
                    ? item['nikName']
                    : (item['stuName'] ?? '未知姓名'),
          };
        }).toList();

        setState(() {
          students = studentsList;
          _isLoading = false; // 加载完成
        });

        // 启动动画
        _animationController.forward();
      } else {
        print('Failed to load students: ${response.statusCode}');
        setState(() {
          _isLoading = false; // 请求失败时结束加载状态
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false; // 出错也要结束加载状态
      });
    }
  }

  void _onStudentTap(String stuId, String stuName, String pageId) {
    // 修复：注释掉触觉反馈，避免编译问题
    // HapticFeedback.lightImpact();
    // 导航到页面ID的Mapping文件，根据相应的PageId跳转至PageId对应的业务画面。
    // 传递选择的年度参数
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PageIdMapping(
                  pageId: pageId,
                  stuId: stuId,
                  stuName: stuName,
                  selectedYear: selectedYear,
                )));
  }

  List<Map<String, dynamic>> get filteredStudents {
    if (_searchQuery.isEmpty) {
      return students;
    }
    return students.where((student) {
      return student['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: '在课学生一览',
        subtitle: widget.pagePath,
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
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: widget.knFontColor),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          PopupMenuButton<DisplayMode>(
            icon: Icon(Icons.view_module, color: widget.knFontColor),
            onSelected: (DisplayMode result) {
              setState(() {
                _displayMode = result;
                _animationController.reset();
                _animationController.forward();
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<DisplayMode>>[
              const PopupMenuItem<DisplayMode>(
                value: DisplayMode.small,
                child: Row(
                  children: [
                    Icon(Icons.view_comfy, size: 18),
                    SizedBox(width: 8),
                    Text('小网格'),
                  ],
                ),
              ),
              const PopupMenuItem<DisplayMode>(
                value: DisplayMode.medium,
                child: Row(
                  children: [
                    Icon(Icons.view_module, size: 18),
                    SizedBox(width: 8),
                    Text('中网格'),
                  ],
                ),
              ),
              const PopupMenuItem<DisplayMode>(
                value: DisplayMode.large,
                child: Row(
                  children: [
                    Icon(Icons.view_agenda, size: 18),
                    SizedBox(width: 8),
                    Text('大网格'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: null, // 修复：这里改回原来的简单写法，避免复杂的条件判断导致编译错误
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KnLoadingIndicator(color: widget.knBgColor),
                  ],
                ),
              )
            : Column(
                children: [
                  _buildStudentCount(),
                  Expanded(child: _buildStudentGrid()),
                ],
              ),
      ),
    );
  }

  Widget _buildStudentCount() {
    if (_isLoading) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
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
          Expanded(
            child: Text(
              _searchQuery.isEmpty
                  ? '共 ${students.length} 名在课学生'
                  : '找到 ${filteredStudents.length} 名学生',
              style: TextStyle(
                color: widget.knBgColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 年度选择器
          GestureDetector(
            onTap: () => _showYearPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: widget.knBgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.knBgColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: widget.knBgColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$selectedYear年',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.knBgColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: widget.knBgColor, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildStudentGrid() {
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    switch (_displayMode) {
      case DisplayMode.small:
        crossAxisCount = 4;
        childAspectRatio = 1.1;
        spacing = 8;
        break;
      case DisplayMode.medium:
        crossAxisCount = 3;
        childAspectRatio = 1.2;
        spacing = 12;
        break;
      case DisplayMode.large:
        crossAxisCount = 2;
        childAspectRatio = 1.8;
        spacing = 16;
        break;
    }

    final studentsToShow = filteredStudents;

    if (studentsToShow.isEmpty && _searchQuery.isNotEmpty) {
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

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: studentsToShow.length,
        itemBuilder: (context, index) {
          final student = studentsToShow[index];
          return _buildStudentCard(student, index);
        },
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    // 修复：颜色反转设计 - 白色背景，彩色边框和文字
    final cardColor = _getCardColor(index);

    return Card(
      elevation: 3,
      shadowColor: cardColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () =>
            _onStudentTap(student['id'], student['name'], widget.pageId),
        borderRadius: BorderRadius.circular(16),
        splashColor: cardColor.withOpacity(0.1),
        highlightColor: cardColor.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // 修复：反转色彩 - 白色背景
            color: Colors.white,
            // 修复：彩色边框
            border: Border.all(
              color: cardColor,
              width: 1, // 设置边框粗细
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 头像 - 彩色背景，白色图标
              Container(
                width: _displayMode == DisplayMode.large ? 48 : 36,
                height: _displayMode == DisplayMode.large ? 48 : 36,
                decoration: BoxDecoration(
                  // 修复：头像用彩色背景
                  gradient: LinearGradient(
                    colors: [
                      cardColor.withOpacity(0.8),
                      cardColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  // 修复：头像图标保持白色
                  color: Colors.white,
                  size: _displayMode == DisplayMode.large ? 24 : 18,
                ),
              ),
              SizedBox(height: _displayMode == DisplayMode.large ? 12 : 8),
              // 姓名 - 彩色文字
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  student['name']!,
                  textAlign: TextAlign.center,
                  maxLines: _displayMode == DisplayMode.large ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _displayMode == DisplayMode.large ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    // 修复：文字改为彩色
                    color: cardColor,
                  ),
                ),
              ),
              if (_displayMode == DisplayMode.large) ...[
                const SizedBox(height: 4),
                Text(
                  'ID: ${student['id']}',
                  style: TextStyle(
                    fontSize: 12,
                    // 修复：ID文字也改为彩色，但透明度低一些
                    color: cardColor.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 修复：简化颜色选择，直接返回主题色
  Color _getCardColor(int index) {
    // 根据索引交替使用不同透明度的主题色，营造变化感
    final colorVariations = [
      widget.knBgColor,
      widget.knBgColor.withOpacity(0.8),
      widget.knBgColor.withOpacity(0.9),
      widget.knBgColor.withOpacity(0.7),
    ];
    return colorVariations[index % colorVariations.length];
  }

  // 显示年度选择器（滚轮式）
  void _showYearPicker(BuildContext context) {
    int tempSelectedYear = selectedYear;
    final initialIndex = years.indexOf(selectedYear);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 顶部标题栏
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.knBgColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消', style: TextStyle(fontSize: 16)),
                        ),
                        Text(
                          '选择年度',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.knBgColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (tempSelectedYear != selectedYear) {
                              setState(() {
                                selectedYear = tempSelectedYear;
                              });
                              // 刷新数据，将年度作为参数传递给后台
                              fetchStudents();
                            }
                          },
                          child: Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.knBgColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 滚轮选择器
                  Expanded(
                    child: Stack(
                      children: [
                        // 中间选中区域的背景
                        Center(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: widget.knBgColor.withOpacity(0.1),
                              border: Border(
                                top: BorderSide(color: widget.knBgColor.withOpacity(0.3)),
                                bottom: BorderSide(color: widget.knBgColor.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ),
                        // 滚轮
                        ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(initialItem: initialIndex >= 0 ? initialIndex : 0),
                          itemExtent: 50,
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              tempSelectedYear = years[index];
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: years.length,
                            builder: (context, index) {
                              final year = years[index];
                              final isSelected = year == tempSelectedYear;
                              return Center(
                                child: Text(
                                  '$year年',
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 20,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? widget.knBgColor : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum DisplayMode { small, medium, large }
