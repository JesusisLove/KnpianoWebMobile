// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../ApiConfig/KnApiConfig.dart';
import '../Constants.dart';
import 'Kn02F003AdvcLsnFeePayBean.dart';

class Kn02F003AdvcLsnFeePayPage extends StatefulWidget {
  final String stuId;
  final String stuName;

  const Kn02F003AdvcLsnFeePayPage({super.key, required this.stuId, required this.stuName});

  @override
  _Kn02F003AdvcLsnFeePayPageState createState() => _Kn02F003AdvcLsnFeePayPageState();
}

class _Kn02F003AdvcLsnFeePayPageState extends State<Kn02F003AdvcLsnFeePayPage> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<Kn02F003AdvcLsnFeePayBean> stuFeeDetailList = [];
  int stuFeeDetailCount = 0;
  List<Map<String, dynamic>> bankList = [];
  String? selectedBank;

  List<int> years = List.generate(7, (index) => DateTime.now().year - 3 + index);
  List<int> months = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    fetchBankList();
  }

  // 获取银行列表
  Future<void> fetchBankList() async {
    final String apiGetBnkUrl = '${KnConfig.apiBaseUrl}${Constants.stuBankList}/${widget.stuId}';
    final response = await http.get(Uri.parse(apiGetBnkUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      setState(() {
        bankList = data.map((item) => {
          'bankId': item['bankId'],
          'bankName': item['bankName'],
        }).toList();
      });
    } else {
      print('Failed to load bank list');
    }
  }

  // 获取费用详情
  Future<void> fetchAdvcLsnInfoDetails() async {
    final String yearMonth = '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}';
    final String apiAdvcLsnFeePayInfo = '${KnConfig.apiBaseUrl}${Constants.apiAdvcLsnFeePayInfo}/${widget.stuId}/$yearMonth';
    final responseFeeDetails = await http.get(Uri.parse(apiAdvcLsnFeePayInfo));
    if (responseFeeDetails.statusCode == 200) {
      final decodedBody = utf8.decode(responseFeeDetails.bodyBytes);
      List<dynamic> stuDocJson = json.decode(decodedBody);
      setState(() {
        stuFeeDetailList = stuDocJson.map((json) => Kn02F003AdvcLsnFeePayBean.fromJson(json)).toList();
        stuFeeDetailCount = stuFeeDetailList.length;
      });
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  // 显示年份选择器
  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Container(
                height: 40,
                color: Colors.grey[200],
                child: const Center(
                  child: Text(
                    '选择年份',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedYear = years[index];
                    });
                  },
                  children: years.map((year) => Center(child: Text(year.toString()))).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示月份选择器
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Container(
                height: 40,
                color: Colors.grey[200],
                child: const Center(
                  child: Text(
                    '选择月份',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedMonth = months[index];
                    });
                  },
                  children: months.map((month) => Center(child: Text(month.toString().padLeft(2, '0')))).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stuName}的课费预支付'),
      ),
      body: Column(
        children: [
          // 年月选择和检索按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _showYearPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Text('$selectedYear年'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Text('${selectedMonth.toString().padLeft(2, '0')}月'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: fetchAdvcLsnInfoDetails,
                child: const Text('检索'),
              ),
            ],
          ),
          // 费用详情列表
          Expanded(
            child: ListView.separated(
              itemCount: stuFeeDetailCount,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(color: Colors.grey),
              ),
              itemBuilder: (context, index) {
                final item = stuFeeDetailList[index];
                return FeeDetailItem(item: item);
              },
            ),
          ),
          // 银行选择和支付按钮
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedBank,
                    items: bankList.map((bank) => DropdownMenuItem<String>(
                      value: bank['bankId'],
                      child: Text(bank['bankName']),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value;
                      });
                    },
                    hint: const Text('请选择银行名称'),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 实现课费预支付逻辑
                  },
                  child: const Text('课费预支付'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeeDetailItem extends StatefulWidget {
  final Kn02F003AdvcLsnFeePayBean item;

  const FeeDetailItem({super.key, required this.item});

  @override
  _FeeDetailItemState createState() => _FeeDetailItemState();
}

class _FeeDetailItemState extends State<FeeDetailItem> {
  bool isChecked = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // 检查日期是否小于当前日期
  bool isDatePassed() {
    if (widget.item.schedualDate.isEmpty) {
      return false;
    }
    try {
      DateTime scheduleDate = DateFormat('yyyy-MM-dd HH:mm').parse(widget.item.schedualDate!);
      return scheduleDate.isBefore(DateTime.now());
    } catch (e) {
      print('日期解析错误: ${widget.item.schedualDate}');
      return false;
    }
  }

  // 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _selectTime(context); // 在选择日期后立即选择时间
    }
  }

  // 选择时间
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool datePassed = isDatePassed();
    String displayDate = widget.item.schedualDate.isNotEmpty 
        ? widget.item.schedualDate 
        : (selectedDate != null && selectedTime != null 
            ? "${DateFormat('yyyy-MM-dd').format(selectedDate!)} ${selectedTime!.format(context)}"
            : "");

    return CheckboxListTile(
      value: isChecked,
      onChanged: (value) {
        setState(() {
          isChecked = value!;
          if (isChecked && displayDate.isEmpty) {
            _selectDate(context);
          } else if (!isChecked) {
            selectedDate = null;
            selectedTime = null;
          }
        });
      },
      title: Text('${widget.item.subjectName} ${widget.item.subjectSubName}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(text: '¥${widget.item.subjectPrice}　${widget.item.lessonType == 1 ? '月计划' : ''}　${widget.item.minutesPerLsn}分钟　'),
                if (displayDate.isNotEmpty)
                  TextSpan(
                    text: displayDate,
                    style: TextStyle(
                      color: widget.item.schedualDate.isEmpty ? Colors.blue : (datePassed ? Colors.red : null),
                    ),
                  ),
              ],
            ),
          ),
          if (displayDate.isEmpty && isChecked)
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('选择日期和时间'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}