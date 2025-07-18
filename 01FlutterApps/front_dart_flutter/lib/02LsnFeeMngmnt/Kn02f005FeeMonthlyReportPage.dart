import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../CommonProcess/customUI/KnLoadingIndicator.dart';
import '../Constants.dart';
import 'Kn02f005FeeMonthlyUnpaidPage.dart';
import 'Kn02f005FeeMonthlyReportBean.dart';

class MonthlyIncomeReportPage extends StatefulWidget {
  const MonthlyIncomeReportPage({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径
  final String pagePath;

  @override
  _MonthlyIncomeReportPageState createState() =>
      _MonthlyIncomeReportPageState();
}

class _MonthlyIncomeReportPageState extends State<MonthlyIncomeReportPage> {
  int selectedYear = DateTime.now().year;
  List<int> years = List.generate(
          DateTime.now().year - 2017, (index) => DateTime.now().year - index)
      .toList();
  List<Kn02f005FeeMonthlyReportBean> monthlyReports = [];
  double totalShouldPay = 0;
  double totalHasPaid = 0;
  double totalUnpaid = 0;
  bool isLoading = true;
  final String titleName = '学费月度报告';
  late String pagePath;

  @override
  void initState() {
    super.initState();
    pagePath = '${widget.pagePath} >> $titleName';
    fetchMonthlyReport();
  }

  Future<void> fetchMonthlyReport() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String apiUrl =
          '${KnConfig.apiBaseUrl}${Constants.apiFeeMonthlyReport}/$selectedYear';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonData = json.decode(decodedBody);
        setState(() {
          monthlyReports = jsonData
              .map((json) => Kn02f005FeeMonthlyReportBean.fromJson(json))
              .toList();
          calculateTotals();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load monthly report');
      }
    } catch (e) {
      print('Error fetching monthly report: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateTotals() {
    totalShouldPay =
        monthlyReports.fold(0, (sum, item) => sum + item.shouldPayLsnFee);
    totalHasPaid =
        monthlyReports.fold(0, (sum, item) => sum + item.hasPaidLsnFee);
    totalUnpaid =
        monthlyReports.fold(0, (sum, item) => sum + item.unpaidLsnFee);
  }

  List<String> collectMonths() {
    return monthlyReports
        .map((report) => report.lsnMonth.substring(5, 7))
        .toSet()
        .toList()
      ..sort();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '$selectedYear年度月收入报告',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTableHeader(),
          Expanded(
            child: isLoading
                ? Center(
                    child: KnLoadingIndicator(
                    color: widget.knBgColor,
                  ))
                : _buildIncomeList(),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 1,
              child: Text('月份', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child:
                  Text('应收入', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child:
                  Text('实收入', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child:
                  Text('平账结果', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildIncomeList() {
    return ListView.builder(
      itemCount: monthlyReports.length,
      itemBuilder: (context, index) {
        var item = monthlyReports[index];
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Row(
              children: [
                Expanded(flex: 1, child: Text(item.lsnMonth.substring(5, 7))),
                Expanded(
                    flex: 2,
                    child: Text(item.shouldPayLsnFee.toStringAsFixed(1))),
                Expanded(
                    flex: 2,
                    child: Text(item.hasPaidLsnFee.toStringAsFixed(1))),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.unpaidLsnFee.toStringAsFixed(1)}欠',
                          style: const TextStyle(color: Colors.red)),
                      IconButton(
                        icon:
                            const Icon(Icons.info_outline, color: Colors.blue),
                        onPressed: () =>
                            _navigateToUnpaidFeesPage(context, item.lsnMonth),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToUnpaidFeesPage(BuildContext context, String month) {
    String yearMonth = '$selectedYear-${month.substring(5, 7)}';
    List<String> availableMonths = collectMonths();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnpaidFeesPage(
          initialYearMonth: yearMonth,
          availableMonths: availableMonths,
          knBgColor: Constants.lsnfeeThemeColor,
          knFontColor: Colors.white,
          pagePath: "学费月度报告",
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalAmounts(),
          const SizedBox(height: 10),
          _buildYearPicker(),
        ],
      ),
    );
  }

  Widget _buildTotalAmounts() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('应支付总额：'),
            Text(totalShouldPay.toStringAsFixed(2))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('已支付总额：'),
            Text(totalHasPaid.toStringAsFixed(2))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('未支付总额：'),
            Text(totalUnpaid.toStringAsFixed(2))
          ],
        ),
      ],
    );
  }

  Widget _buildYearPicker() {
    return GestureDetector(
      onTap: () => _showYearPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
            child:
                Text('$selectedYear年', style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 350,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      fetchMonthlyReport();
                    },
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
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
                    .map((int year) => Center(child: Text('$year年')))
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
}
