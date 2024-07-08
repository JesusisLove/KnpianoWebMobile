import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ApiConfig/KnApiConfig.dart';
import '../Constants.dart';
import 'Kn02F002FeeBean.dart';

class LsnFeeDetail extends StatefulWidget {
  const LsnFeeDetail({super.key, required this.stuId, required this.stuName});
  final String stuId;
  final String stuName;

  @override
  _LsnFeeDetailState createState() => _LsnFeeDetailState();
}

class _LsnFeeDetailState extends State<LsnFeeDetail> {
  late int selectedYear;
  late List<int> years;
  late TextEditingController _stuNameController;
  int stuFeeDetailCount = 0;
  final ValueNotifier<List<Kn02F002FeeBean>> stuFeeDetailNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    years = List.generate(currentYear - 2017, (index) => currentYear - index);
    selectedYear = currentYear;
    _stuNameController = TextEditingController(text: widget.stuName);
    fetchFeeDetails();
  }

  @override
  void dispose() {
    _stuNameController.dispose();
    super.dispose();
  }

  Future<void> fetchFeeDetails() async {
    final String apiStuDocUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuFeeDetailByYear}/${widget.stuId}/$selectedYear';
    final responseStuDoc = await http.get(Uri.parse(apiStuDocUrl));
    if (responseStuDoc.statusCode == 200) {
      final decodedBody = utf8.decode(responseStuDoc.bodyBytes);
      List<dynamic> stuDocJson = json.decode(decodedBody);
      setState(() {
        stuFeeDetailNotifier.value = stuDocJson.map((json) => Kn02F002FeeBean.fromJson(json)).toList();
        stuFeeDetailCount = stuFeeDetailNotifier.value.length;
      });
    } else {
      throw Exception('Failed to load archived students');
    }
  }

  void _showYearPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: years.indexOf(selectedYear),
            ),
            onSelectedItemChanged: (int selectedItem) {
              setState(() {
                selectedYear = years[selectedItem];
                fetchFeeDetails();
              });
            },
            children: List<Widget>.generate(years.length, (int index) {
              return Center(
                child: Text(
                  years[index].toString(),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程费用详细'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'prepay') {
                print('预支付学费被选中');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'prepay',
                child: Text('预支付学费'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _stuNameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '学生姓名',
                      labelStyle: TextStyle(
                        color: Colors.red, // 设置字体颜色为红色
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _showYearPicker,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '选择年份',
                        labelStyle: TextStyle(
                          color: Colors.red, // 设置字体颜色为红色
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedYear.toString()),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Kn02F002FeeBean>>(
              valueListenable: stuFeeDetailNotifier,
              builder: (context, feeDetailList, child) {
                if (feeDetailList.isEmpty) {
                  return const Center(child: Text('No fee details available'));
                }
                final months = feeDetailList.map((detail) => detail.month).where((month) => month > 0).toSet().toList()..sort();
                print('Available months: $months');
                
                return ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final monthData = feeDetailList.where((detail) => detail.month == month).toList();
                    return MonthLineItem(month: month, monthData: monthData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MonthLineItem extends StatelessWidget {
  final int month;
  final List<Kn02F002FeeBean> monthData;

  const MonthLineItem({super.key, required this.month, required this.monthData});

  @override
  Widget build(BuildContext context) {
    double totalFee = monthData.fold(0, (sum, item) => sum + item.lsnFee);
    final currentMonth = DateTime.now().month;

    return IntrinsicHeight(
      // ListView控件的一个Cell行
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  '$month月',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // 给系统当前月设置字体颜色
                    color: month == currentMonth ? Colors.red : Colors.black,
                  ),
                ),
                const Expanded(
                  child: VerticalDivider(
                    color: Colors.red,// 时间轴线颜色
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(0.0, 6.0, 28.0, 8.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      color: Colors.red.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '课费总计: \$${totalFee.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, 
                                                   fontWeight: FontWeight.bold,
                                                   color: Colors.red),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'record') {
                                // 迁移至课费记账画面
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'record',
                                child: Text('学费记账'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      color: Colors.blue[100],
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...monthData.map((item) {
                            String lessonTypeText = '';
                            switch (item.lessonType) {
                              case 0:
                                lessonTypeText = '加时课';
                                break;
                              case 1:
                                lessonTypeText = '月计划';
                                break;
                              case 2:
                                lessonTypeText = '月加课';
                                break;
                            }
                            return Text(
                              '${item.subjectName} $lessonTypeText: ${item.lsnCount}节 \$${item.lsnFee.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14,
                                                     color: Colors.blue),
                            );
                          }),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              color: Colors.yellow[50],
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('已支付:', style: TextStyle(fontSize: 14, color: Colors.orange)),
                                Text('未支付:', style: TextStyle(fontSize: 14, color: Colors.orange)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}