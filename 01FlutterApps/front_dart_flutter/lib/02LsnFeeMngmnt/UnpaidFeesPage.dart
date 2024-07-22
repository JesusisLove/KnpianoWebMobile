import 'package:flutter/material.dart';

class UnpaidFeesPage extends StatelessWidget {
  const UnpaidFeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('2024/01 未缴纳学费明细'),
        centerTitle: true,
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
          _buildMonthButtons(),
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
          DataColumn(label: Text('差额')),
        ],
        rows: [
          _buildDataRow('Javier Ong Hao Zhe', 595.0, 400.0, -195.0),
          _buildDataRow('Jovie Ling Jia Xin', 635.0, 700.0, 65.0),
          _buildDataRow('Kaelyn Mok Ziqi', 300.0, 360.0, 60.0),
          _buildDataRow('Melanie Koh Xinyue', 635.0, 700.0, 65.0),
          _buildDataRow('Tan E-Ton', 320.0, 0.0, -320.0),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String name, double due, double paid, double diff) {
    return DataRow(cells: [
      DataCell(Text(name)),
      DataCell(Text(due.toStringAsFixed(1))),
      DataCell(Text(paid.toStringAsFixed(1))),
      DataCell(Text(
        diff.toStringAsFixed(1),
        style: TextStyle(color: diff < 0 ? Colors.red : Colors.green),
      )),
    ]);
  }

  Widget _buildTotalUnpaid() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerRight,
      child: const Text(
        '未支付额合计:325.0',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMonthButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(12, (index) {
          final month = (index + 1).toString().padLeft(2, '0');
          final isActive = index < 5;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.grey,
            ),
            onPressed: isActive ? () {} : null,
            child: Text('$month月份'),
          );
        }),
      ),
    );
  }
}