import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'UnpaidFeesPage.dart';

class MonthlyIncomeReportPage extends StatefulWidget {
  const MonthlyIncomeReportPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MonthlyIncomeReportPageState createState() => _MonthlyIncomeReportPageState();
}

class _MonthlyIncomeReportPageState extends State<MonthlyIncomeReportPage> {
  int selectedYear = DateTime.now().year;
  List<int> years = List.generate(DateTime.now().year - 2017, (index) => DateTime.now().year - index).toList();

  final List<Map<String, dynamic>> incomeData = [
    {'month': '01', 'expected': 12065.0, 'actual': 11740.0, 'difference': 325.0},
    {'month': '02', 'expected': 12055.0, 'actual': 11240.0, 'difference': 815.0},
    {'month': '03', 'expected': 11750.0, 'actual': 10900.0, 'difference': 850.0},
    {'month': '04', 'expected': 12070.0, 'actual': 11050.0, 'difference': 1020.0},
    {'month': '05', 'expected': 10640.0, 'actual': 8950.0, 'difference': 1690.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('综合管理', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '2024年度月收入报告',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTableHeader(),
          Expanded(
            child: _buildIncomeList(),
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
          Expanded(flex: 1, child: Text('月份', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('应收入', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('实收入', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('平账结果', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildIncomeList() {
    return ListView.builder(
      itemCount: incomeData.length,
      itemBuilder: (context, index) {
        var item = incomeData[index];
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Row(
              children: [
                Expanded(flex: 1, child: Text(item['month'])),
                Expanded(flex: 2, child: Text(item['expected'].toStringAsFixed(1))),
                Expanded(flex: 2, child: Text(item['actual'].toStringAsFixed(1))),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['difference'].toStringAsFixed(1)}欠', style: const TextStyle(color: Colors.red)),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        onPressed: () => _navigateToUnpaidFeesPage(context, item['month']),
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
  Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) => const UnpaidFeesPage(),
    ),
  );
}

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHints(),
          const SizedBox(height: 10),
          _buildTotalAmounts(),
          const SizedBox(height: 10),
          _buildYearPicker(),
        ],
      ),
    );
  }

  Widget _buildHints() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pan_tool, color: Colors.orange, size: 16),
            SizedBox(width: 4),
            Expanded(child: Text('提示：双击行，可查看该月都有谁的课费没付清', style: TextStyle(fontSize: 12))),
          ],
        ),
        Row(
          children: [
            Icon(Icons.pan_tool, color: Colors.orange, size: 16),
            SizedBox(width: 4),
            Expanded(child: Text('课时结算的未支付不在此统计，请在他们的课费支付明细那里查看。', style: TextStyle(fontSize: 12))),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalAmounts() {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('应支付总额：'), Text('0.00')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('已支付总额：'), Text('0.00')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('未支付总额：'), Text('0.00')],
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
        child: Center(child: Text('$selectedYear年', style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(child: const Text('取消'), onPressed: () => Navigator.of(context).pop()),
                  CupertinoButton(child: const Text('确定'), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(initialItem: years.indexOf(selectedYear)),
                children: years.map((int year) => Center(child: Text('$year年'))).toList(),
                onSelectedItemChanged: (int index) => setState(() => selectedYear = years[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}