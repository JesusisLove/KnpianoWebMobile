import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
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
  _UnpaidFeesPageState createState() => _UnpaidFeesPageState();
}

class _UnpaidFeesPageState extends State<UnpaidFeesPage> {
  late String selectedYearMonth;
  List<Kn02f005FeeMonthlyReportBean> feeList = [];
  double totalUnpaid = 0;
  final String titleName = '未缴纳学费明细';
  late String pagePath;

  @override
  void initState() {
    super.initState();
    selectedYearMonth = widget.initialYearMonth;
    pagePath = '${widget.pagePath} >> $titleName';
    fetchFeeDetails();
  }

  Future<void> fetchFeeDetails() async {
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.apiFeeUnpaidReport}/$selectedYearMonth';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = json.decode(decodedBody);
      setState(() {
        feeList = jsonList.map((json) => Kn02f005FeeMonthlyReportBean.fromJson(json)).toList();
        calculateTotalUnpaid();
      });
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  void calculateTotalUnpaid() {
    totalUnpaid = feeList.fold(0, (sum, fee) => sum + fee.unpaidLsnFee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: titleName,
        subtitle: pagePath,
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
        addInvisibleRightButton: false, // 显示Home按钮返回主菜单
        currentNavIndex: 1,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildFeeTable(),
              ],
            ),
          ),
          _buildTotalUnpaid(),
          _buildMonthPicker(),
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
      DataCell(Text(fee.stuName)),
      DataCell(Text(fee.shouldPayLsnFee.toStringAsFixed(1))),
      DataCell(Text(fee.hasPaidLsnFee.toStringAsFixed(1))),
      DataCell(Text(
        fee.unpaidLsnFee.toStringAsFixed(1),
        style: TextStyle(color: fee.unpaidLsnFee > 0 ? Colors.red : Colors.green),
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

  Widget _buildMonthPicker() {
    int initialItem = widget.availableMonths.indexOf(selectedYearMonth.substring(5));
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoPicker(
        itemExtent: 32,
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        children: widget.availableMonths.map((month) => Text('$month月份')).toList(),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedYearMonth = '${selectedYearMonth.substring(0, 5)}${widget.availableMonths[index]}';
            fetchFeeDetails();
          });
        },
      ),
    );
  }
}