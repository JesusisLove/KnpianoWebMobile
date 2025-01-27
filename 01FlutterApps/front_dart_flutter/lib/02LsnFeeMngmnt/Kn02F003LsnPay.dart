// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../Constants.dart';
import 'Kn02F002FeeBean.dart';
import 'Kn02F004UnpaidBean.dart';

// ignore: must_be_immutable
class Kn02F003LsnPay extends StatefulWidget {
  final List<Kn02F002FeeBean> monthData;
  bool allPaid;
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  late String pagePath;

  Kn02F003LsnPay(
      {super.key,
      required this.monthData,
      required this.allPaid,
      required this.knBgColor,
      required this.knFontColor,
      required this.pagePath});

  @override
  _Kn02F003LsnPayState createState() => _Kn02F003LsnPayState();
}

class _Kn02F003LsnPayState extends State<Kn02F003LsnPay> {
  final String titleName = '学费账单';
  List<bool> selectedSubjects = [];
  List<Map<String, dynamic>> bankList = [];
  String? selectedBankId;
  DateTime selectedDate = DateTime.now();
  double totalFee = 0;
  double paymentAmount = 0;

  @override
  void initState() {
    super.initState();
    widget.pagePath = '${widget.pagePath} >> $titleName';
    selectedSubjects = List.generate(widget.monthData.length,
        (index) => widget.monthData[index].ownFlg == 1);
    calculateTotalFee();
    fetchBankList();
  }

  void calculateTotalFee() {
    totalFee = widget.monthData.fold(
        0,
        (sum, fee) =>
            sum + (fee.lessonType == 1 ? (fee.subjectPrice! * 4) : fee.lsnFee));
  }

  void updatePaymentAmount() {
    paymentAmount = 0;
    for (int i = 0; i < widget.monthData.length; i++) {
      if (selectedSubjects[i]) {
        paymentAmount += widget.monthData[i].lessonType == 1
            ? (widget.monthData[i].subjectPrice! * 4)
            : widget.monthData[i].lsnFee;
      }
    }
    setState(() {});
  }

  Future<void> fetchBankList() async {
    final String apiGetBnkUrl =
        '${KnConfig.apiBaseUrl}${Constants.stuBankList}/${widget.monthData.first.stuId}';
    final response = await http.get(Uri.parse(apiGetBnkUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      setState(() {
        bankList = data
            .map((item) => {
                  'bankId': item['bankId'],
                  'bankName': item['bankName'],
                })
            .toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> saveLsnPay() async {
    final String apiLsnSaveUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiStuPaySave}';
    List<Kn02F004UnpaidBean> selectedFees = [];

    for (int i = 0; i < widget.monthData.length; i++) {
      if (selectedSubjects[i] && widget.monthData[i].ownFlg == 0) {
        selectedFees.add(Kn02F004UnpaidBean(
          lsnFeeId: widget.monthData[i].lsnFeeId,
          lsnPay: widget.monthData[i].lsnFee,
          payMonth: widget.monthData.first.lsnMonth,
          payDate: selectedDate.toString(),
          bankId: selectedBankId!,
        ));
      }
    }

    try {
      final response = await http.post(
        Uri.parse(apiLsnSaveUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(selectedFees),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        showErrorDialog('保存学费支付失败。错误码：${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog('网络错误：$e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void validateAndSave() {
    if (!selectedSubjects.contains(true)) {
      showErrorDialog('请选择要入账的课程');
    } else if (selectedBankId == null) {
      showErrorDialog('请选择银行名称');
    } else {
      saveLsnPay();
    }
  }

  // 修改：添加确认对话框
  Future<void> showConfirmDialog(String lsnPayId, String lsnFeeId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认'),
          content: const Text('您确定要撤销这笔支付吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                Navigator.of(context).pop();
                restorePayment(lsnPayId, lsnFeeId);
                widget.allPaid = false;
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> restorePayment(String lsnPayId, String lsnFeeId) async {
    final String apiStuPayRestoreUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiStuPayRestore}/$lsnPayId/$lsnFeeId';
    try {
      final response = await http.delete(Uri.parse(apiStuPayRestoreUrl));
      if (response.statusCode == 200) {
        setState(() {
          int index = widget.monthData
              .indexWhere((element) => element.lsnFeeId == lsnFeeId);
          if (index != -1) {
            widget.monthData[index].ownFlg = 0;
            selectedSubjects[index] = false;
          }
        });
        updatePaymentAmount();
      } else {
        showErrorDialog('撤销支付失败。错误码：${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog('网络错误：$e');
    }
  }

  // 修改: 添加显示银行选择器的方法
  void _showBankPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: widget.knBgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child:
                        Text('取消', style: TextStyle(color: widget.knFontColor)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text('选择银行',
                      style: TextStyle(
                          color: widget.knFontColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  CupertinoButton(
                    child:
                        Text('确定', style: TextStyle(color: widget.knFontColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedBankId = bankList[index]['bankId'];
                  });
                },
                children:
                    bankList.map((bank) => Text(bank['bankName'])).toList(),
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
        title:
            '${widget.monthData.first.stuName} ${widget.monthData.first.month}月份的学费账单',
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
        addInvisibleRightButton: true,
        subtitleTextColor: Colors.white,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
      ),
      // 修改: 更新body部分的布局和样式
      body: Column(
        children: [
          // 修改: 调整课程列表的样式
          Expanded(
            child: ListView.builder(
              itemCount: widget.monthData.length,
              itemBuilder: (context, index) {
                final fee = widget.monthData[index];
                final lessonTypeText = fee.lessonType == 0
                    ? '结算课'
                    : fee.lessonType == 1
                        ? '月计划'
                        : '月加课';
                bool isPaymentToday = false;
                if (fee.payDate != null && fee.payDate!.isNotEmpty) {
                  try {
                    final paymentDate = DateTime.parse(fee.payDate!);
                    isPaymentToday =
                        DateFormat('yyyy-MM-dd').format(paymentDate) ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                  } catch (e) {
                    print('Invalid date format: ${fee.payDate}');
                  }
                }
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Checkbox(
                      value: selectedSubjects[index],
                      onChanged: fee.ownFlg == 0
                          ? (bool? value) {
                              setState(() {
                                selectedSubjects[index] = value!;
                                updatePaymentAmount();
                              });
                            }
                          : null,
                    ),
                    title: Text('${fee.subjectName} ($lessonTypeText)'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('课费: \$${fee.lsnFee.toStringAsFixed(2)}'),
                        Text('单价: \$${fee.subjectPrice}/节'),
                        Text('上课节数: ${fee.lsnCount}'),
                      ],
                    ),
                    trailing: fee.ownFlg == 1 && isPaymentToday
                        ? IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              showConfirmDialog(fee.lsnPayId, fee.lsnFeeId);
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          // 修改: 调整底部结算区域的样式
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('合计: \$${totalFee.toStringAsFixed(2)}'),
                    Text('支付: \$${paymentAmount.toStringAsFixed(2)}'),
                    Text(
                        '剩余: \$${(totalFee - paymentAmount).toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 16),
                // 修改: 使用GestureDetector来触发银行选择器
                GestureDetector(
                  onTap: _showBankPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedBankId != null
                            ? bankList.firstWhere((bank) =>
                                bank['bankId'] == selectedBankId)['bankName']
                            : '选择银行'),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 修改: 调整日期选择器的样式
                GestureDetector(
                  onTap: () async {
                    // 获取当前时间
                    DateTime now = DateTime.now();
                    // 设置可选时间范围为当前年份的全年
                    DateTime firstDate = DateTime(now.year, 1, 1);
                    DateTime lastDate = DateTime(now.year, 12, 31);

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      selectableDayPredicate: (DateTime date) {
                        // 判断这个日期在这个月的第几天
                        int dayOfMonth = date.day;
                        // 只要是这个月的日期就返回true
                        return dayOfMonth >= 1 && dayOfMonth <= 31;
                      },
                      initialEntryMode:
                          DatePickerEntryMode.calendarOnly, // 直接显示日历视图
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '入账日期: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 修改: 调整学费入账按钮的样式
                ElevatedButton(
                  onPressed: !widget.allPaid ? validateAndSave : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: widget.knFontColor,
                    backgroundColor: widget.knBgColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('学费入账'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
