import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../CommonProcess/customUI/KnLoadingIndicator.dart';
import '../Constants.dart';
import 'Kn02f005FeeMonthlyReportBean.dart';

class UnpaidFeesPage extends StatefulWidget {
  final String initialYearMonth;
  final List<String> availableMonths;
  final Color knBgColor;
  final Color knFontColor;
  final String pagePath;

  const UnpaidFeesPage({
    super.key,
    required this.initialYearMonth,
    required this.availableMonths,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UnpaidFeesPageState createState() => _UnpaidFeesPageState();
}

class _UnpaidFeesPageState extends State<UnpaidFeesPage> {
  late String selectedYearMonth;
  List<Kn02f005FeeMonthlyReportBean> feeList = [];
  double totalUnpaid = 0;
  final String titleName = '未缴纳学费明细';
  late String pagePath;
  // 添加加载状态变量
  bool _isLoading = false;
  // 当前显示的月份
  String currentDisplayMonth = '';
  // 临时选择的月份索引
  int tempSelectedMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedYearMonth = widget.initialYearMonth;
    currentDisplayMonth =
        widget.availableMonths.contains(selectedYearMonth.substring(5))
            ? selectedYearMonth.substring(5)
            : widget.availableMonths.isNotEmpty
                ? widget.availableMonths[0]
                : '';
    pagePath = '${widget.pagePath} >> $titleName';
    fetchFeeDetails();
  }

  Future<void> fetchFeeDetails() async {
    // 开始加载时设置状态
    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiFeeUnpaidReport}/$selectedYearMonth';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(decodedBody);
        if (mounted) {
          setState(() {
            feeList = jsonList
                .map((json) => Kn02f005FeeMonthlyReportBean.fromJson(json))
                .toList();
            calculateTotalUnpaid();
            // 数据加载完成，结束加载状态
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        throw Exception('Failed to load fee details');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  void calculateTotalUnpaid() {
    totalUnpaid = feeList.fold(0, (sum, fee) => sum + fee.unpaidLsnFee);
  }

  // 显示月份选择器
  void _showMonthPicker() {
    // 默认选中当前显示的月份
    tempSelectedMonthIndex =
        widget.availableMonths.indexOf(currentDisplayMonth);
    if (tempSelectedMonthIndex < 0) {
      tempSelectedMonthIndex = 0;
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(bottom: 34), // 为底部安全区域留出空间
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: widget.knBgColor, // 使用与AppBar相同的背景色
                border: const Border(
                  bottom: BorderSide(color: CupertinoColors.separator),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    '选择月份',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // 确认选择后更新月份并获取数据
                      if (tempSelectedMonthIndex >= 0 &&
                          tempSelectedMonthIndex <
                              widget.availableMonths.length) {
                        setState(() {
                          currentDisplayMonth =
                              widget.availableMonths[tempSelectedMonthIndex];
                          selectedYearMonth =
                              '${selectedYearMonth.substring(0, 5)}$currentDisplayMonth';
                        });
                        // 获取新选择月份的数据
                        fetchFeeDetails();
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: tempSelectedMonthIndex,
                ),
                children: widget.availableMonths
                    .map((month) => Text('$month月份'))
                    .toList(),
                onSelectedItemChanged: (index) {
                  // 只记录临时选择的索引，不立即执行数据获取
                  tempSelectedMonthIndex = index;
                },
              ),
            ),
          ],
        ),
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
        addInvisibleRightButton: false, // 显示Home按钮返回主菜单
        currentNavIndex: 1,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
      ),
      body: Stack(
        children: [
          // 主内容
          Column(
            children: [
              Expanded(
                child: feeList.isEmpty && !_isLoading
                    ? const Center(
                        child: Text(
                          '没有未缴费记录',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          _buildFeeTable(),
                        ],
                      ),
              ),
              // 底部显示合计和月份选择按钮
              Column(
                children: [
                  _buildTotalUnpaid(),
                  _buildMonthSelectionButton(),
                  const SizedBox(height: 34), // 为底部安全区域留出空间
                ],
              ),
            ],
          ),
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1), // 半透明背景
              child: Center(
                child: KnLoadingIndicator(color: widget.knBgColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeeTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('学生姓名')),
          DataColumn(label: Text('应支付额')),
          DataColumn(label: Text('实支付额')),
          DataColumn(label: Text('未支付额')),
        ],
        rows: feeList.map((fee) => _buildDataRow(fee)).toList(),
      ),
    );
  }

  DataRow _buildDataRow(Kn02f005FeeMonthlyReportBean fee) {
    return DataRow(cells: [
      DataCell(
          Text(fee.nikName.isNotEmpty == true ? fee.nikName : fee.stuName)),
      DataCell(Text(fee.shouldPayLsnFee.toStringAsFixed(1))),
      DataCell(Text(fee.hasPaidLsnFee.toStringAsFixed(1))),
      DataCell(Text(
        fee.unpaidLsnFee.toStringAsFixed(1),
        style:
            TextStyle(color: fee.unpaidLsnFee > 0 ? Colors.red : Colors.green),
      )),
    ]);
  }

  Widget _buildTotalUnpaid() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerRight,
      child: Text(
        '未支付额合计: ${totalUnpaid.toStringAsFixed(1)}',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 新的月份选择按钮，一个按钮撑满屏幕宽度，留出4像素间距
  Widget _buildMonthSelectionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // 左右各留4像素间距
      child: SizedBox(
        width: double.infinity, // 让按钮宽度撑满父容器
        height: 50, // 设置按钮高度
        child: ElevatedButton(
          onPressed: _showMonthPicker,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 232, 232, 232), // 浅灰色背景
            foregroundColor: Colors.black, // 文字颜色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // 圆角
            ),
          ),
          child: Text(
            '$currentDisplayMonth月份',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
