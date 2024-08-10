import 'package:flutter/material.dart';
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
  // ignore: library_private_types_in_public_api
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

    ////////////  调试代码 //////////////
    // for (var fee in widget.monthData) {
    //   print('Fee: ${fee.lsnFee}, PayDate: ${fee.payDate}, OwnFlg: ${fee.ownFlg}');
    // }
    ////////////////////////////////////
  }

  void calculateTotalFee() {
    // totalFee = widget.monthData.fold(0, (sum, fee) => sum + fee.lsnFee);
    totalFee = widget.monthData.fold(
        0,
        (sum, fee) =>
            sum + (fee.lessonType == 1 ? (fee.subjectPrice! * 4) : fee.lsnFee));
  }

  void updatePaymentAmount() {
    paymentAmount = 0;
    for (int i = 0; i < widget.monthData.length; i++) {
      if (selectedSubjects[i]) {
        // paymentAmount += widget.monthData[i].lsnFee;
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
      // print('Failed to load bank list');
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

  @override
  Widget build(BuildContext context) {
    ////////////  调试代码 //////////////
    // print('Building Kn02F003LsnPay widget');
    // widget.monthData.forEach((fee) {
    //   print('Fee: ${fee.lsnFee}, PayDate: ${fee.payDate}, OwnFlg: ${fee.ownFlg}');
    // });
    ////////////////////////////////////
    return Scaffold(
      appBar: KnAppBar(
        title:
            '${widget.monthData.first.stuName} ${widget.monthData.first.month}月份的学费账单',
        subtitle: "${widget.pagePath} >> $titleName",
        context: context,
        appBarBackgroundColor: widget.knBgColor, // 自定义AppBar背景颜色
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义标题颜色
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),

        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义底部文本框背景颜色
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        addInvisibleRightButton: true,
        subtitleTextColor: Colors.white, // 自定义底部文本颜色
        titleFontSize: 20.0, // 自定义标题字体大小
        subtitleFontSize: 12.0, // 自定义底部文本字体大小
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.lightBlue[100],
            child: ListView.builder(
              itemCount: widget.monthData.length,
              itemBuilder: (context, index) {
                final fee = widget.monthData[index];
                final lessonTypeText = fee.lessonType == 0
                    ? '结算课'
                    : fee.lessonType == 1
                        ? '月计划'
                        : '月加课';
                // 修改：检查支付日期是否等于系统当前日期
                bool isPaymentToday = false;
                if (fee.payDate != null && fee.payDate!.isNotEmpty) {
                  try {
                    final paymentDate = DateTime.parse(fee.payDate!);
                    isPaymentToday =
                        DateFormat('yyyy-MM-dd').format(paymentDate) ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                  } catch (e) {
                    print('Invalid date format: ${fee.payDate}');
                    // 可以在这里添加更多的错误处理逻辑
                  }
                }
                return ListTile(
                  title: Row(
                    children: [
                      Checkbox(
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
                      Text('课费: \$${fee.lsnFee.toStringAsFixed(2)}'),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${fee.subjectName}($lessonTypeText:${fee.subjectPrice}/节)',
                              style: const TextStyle(fontSize: 12)),
                          Text('上课节数: ${fee.lsnCount}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  // 修改：根据支付日期控制PopupMenuButton的可见性
                  trailing: fee.ownFlg == 1 && isPaymentToday
                      ? PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'restore') {
                              showConfirmDialog(fee.lsnPayId, fee.lsnFeeId);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'restore',
                              child: Text('撤销'),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    const Divider(thickness: 1, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            hint: const Text('存入银行'),
                            value: selectedBankId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedBankId = newValue;
                              });
                            },
                            items: bankList.map<DropdownMenuItem<String>>(
                                (Map<String, dynamic> bank) {
                              return DropdownMenuItem<String>(
                                value: bank['bankId'],
                                child: Text(bank['bankName']),
                              );
                            }).toList(),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2025),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                              '入账日期: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: !widget.allPaid ? validateAndSave : null,
                      child: const Text('学费入账'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
