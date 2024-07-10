import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ApiConfig/KnApiConfig.dart';
import '../Constants.dart';
import 'Kn02F002FeeBean.dart';
import 'Kn02F004UnpaidBean.dart';

class Kn02F003LsnPay extends StatefulWidget {
  final List<Kn02F002FeeBean> monthData;

  const Kn02F003LsnPay({super.key, required this.monthData});

  @override
  // ignore: library_private_types_in_public_api
  _Kn02F003LsnPayState createState() => _Kn02F003LsnPayState();
}

class _Kn02F003LsnPayState extends State<Kn02F003LsnPay> {
  List<bool> selectedSubjects = [];
  List<Map<String, dynamic>> bankList = [];
  String? selectedBankId;
  DateTime selectedDate = DateTime.now();
  double totalFee = 0;
  double paymentAmount = 0;

  @override
  void initState() {
    super.initState();
    selectedSubjects = List.generate(widget.monthData.length, (index) => false);
    calculateTotalFee();
    fetchBankList();
  }

  void calculateTotalFee() {
    totalFee = widget.monthData.fold(0, (sum, fee) => sum + fee.lsnFee);
  }

  void updatePaymentAmount() {
    paymentAmount = 0;
    for (int i = 0; i < widget.monthData.length; i++) {
      if (selectedSubjects[i]) {
        paymentAmount += widget.monthData[i].lsnFee;
      }
    }
    setState(() {});
  }

  // 取得该学生的银行信息
  Future<void> fetchBankList() async {
    final String apiGetBnkUrl = '${KnConfig.apiBaseUrl}${Constants.stuBankList}/${widget.monthData.first.stuId}';
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
      // Handle error
      // print('Failed to load bank list');
    }
  }

  // 执行学费入账处理
  Future<void> saveLsnPay() async {
    // 往后端发送保存请求
    final String apiLsnSaveUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuPaySave}';
    List<Kn02F004UnpaidBean> selectedFees = [];

    for (int i = 0; i < widget.monthData.length; i++) {
      if (selectedSubjects[i]) {
        selectedFees.add(Kn02F004UnpaidBean(
          lsnFeeId: widget.monthData[i].lsnFeeId,
          lsnPay: widget.monthData[i].lsnFee,
          payMonth: widget.monthData.first.lsnMonth,
          payDate: selectedDate.toString(),
          bankId: selectedBankId!, //如果你确定 selectedBankId 在这里永远不会为 null，你可以使用空断言操作符 '!':
        ));
      }
    }

    // 添加错误处理
    try {
      final response = await http.post(
        Uri.parse(apiLsnSaveUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(selectedFees),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true); // Close current page and refresh previous page
      } else {
        // 使用showErrorDialog显示错误信息
        showErrorDialog('保存学费支付失败。错误码：${response.statusCode}');
      }
    } catch (e) {
      // 捕获并显示网络错误
      showErrorDialog('网络错误：$e');
    }
  }

  // 新增：显示错误提示对话框的方法
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

  // 新增：验证并执行保存操作的方法
  void validateAndSave() {
    if (!selectedSubjects.contains(true)) {
      showErrorDialog('请选择要入账的课程');
    } else if (selectedBankId == null) {
      showErrorDialog('请选择银行名称');
    } else {
      saveLsnPay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich( // XXX M月分的学费账单
          TextSpan(
            children: [
              TextSpan(
                text: '${widget.monthData.first.stuName} ${widget.monthData.first.month}月份',
                style: const TextStyle(decoration: TextDecoration.underline),// 添加下划线
              ),
              const TextSpan(text: '的学费账单'),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                final lessonTypeText = fee.lessonType == 0 ? '结算课' : 
                                       fee.lessonType == 1 ? '月计划' : '月加课';
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Text('课费: \$${fee.lsnFee.toStringAsFixed(2)}'),
                      const SizedBox(width: 16),// 调整文本之间的间距
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${fee.subjectName}($lessonTypeText)',
                              style: const TextStyle(fontSize: 12)),
                          Text('上课节数: ${fee.lsnCount}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  value: selectedSubjects[index],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedSubjects[index] = value!;
                      updatePaymentAmount();
                    });
                  },
                  secondary: const Icon(Icons.payment), // 可选的次要图标
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
                        Text('剩余: \$${(totalFee - paymentAmount).toStringAsFixed(2)}'),
                      ],
                    ),
                    // 添加: 在合计和存入银行之间加一条横线
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
                            items: bankList.map<DropdownMenuItem<String>>((Map<String, dynamic> bank) {
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
                          child: Text('入账日期: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      // 修改：将 onPressed 事件处理程序改为 validateAndSave 方法
                      onPressed: validateAndSave,
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