// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../Constants.dart';
import 'Kn02F002FeeBean.dart';
import 'Kn02F003LsnPay.dart';

// ignore: must_be_immutable
class LsnFeeDetail extends StatefulWidget {
  LsnFeeDetail({
    super.key, 
    required this.stuId, 
    required this.stuName,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });
  final String stuId;
  final String stuName;
  // AppBar背景颜色
  final Color knBgColor;
  // 字体颜色
  final Color knFontColor;
  // 画面迁移路径：例如，上课进度管理>>学生姓名一览>> xxx的课程进度状况
  late String pagePath ;


  @override
  _LsnFeeDetailState createState() => _LsnFeeDetailState();
}

class _LsnFeeDetailState extends State<LsnFeeDetail> {
  final String titleName = '课程费用详细';
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
    widget.pagePath = '${widget.pagePath} >> $titleName';
    fetchFeeDetails();
  }

  @override
  void dispose() {
    _stuNameController.dispose();
    super.dispose();
  }

  // 该学生已支付和未支付的账单信息
  Future<void> fetchFeeDetails() async {
    final String apiLsnPaidAndUnpaidDetailUrl = '${KnConfig.apiBaseUrl}${Constants.apiStuFeeDetailByYear}/${widget.stuId}/$selectedYear';
    final responseFeeDetails = await http.get(Uri.parse(apiLsnPaidAndUnpaidDetailUrl));
    if (responseFeeDetails.statusCode == 200) {
      final decodedBody = utf8.decode(responseFeeDetails.bodyBytes);
      List<dynamic> stuDocJson = json.decode(decodedBody);
      setState(() {
        stuFeeDetailNotifier.value = stuDocJson.map((json) => Kn02F002FeeBean.fromJson(json)).toList();
        stuFeeDetailCount = stuFeeDetailNotifier.value.length;
      });
    } else {
      throw Exception('Failed to load archived students');
    }
  }

  // 年度选择器
  void _showYearPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        //点击年份选择器，弹出的滑轮高度
        height: 160,
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
      appBar: KnAppBar(
          title: titleName,
          subtitle: widget.pagePath,
          context: context,
          appBarBackgroundColor: widget.knBgColor, // 自定义AppBar背景颜色
          titleColor: Color.fromARGB(widget.knFontColor.alpha, // 自定义标题颜色
                                     widget.knFontColor.red - 20, 
                                     widget.knFontColor.green - 20, 
                                     widget.knFontColor.blue - 20),

          subtitleBackgroundColor: Color.fromARGB(widget.knFontColor.alpha, // 自定义底部文本框背景颜色
                                     widget.knFontColor.red + 20, 
                                     widget.knFontColor.green + 20, 
                                     widget.knFontColor.blue + 20),

          subtitleTextColor: Colors.white, // 自定义底部文本颜色
          titleFontSize: 20.0, // 自定义标题字体大小
          subtitleFontSize: 12.0, // 自定义底部文本字体大小
                  actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color:widget.knFontColor),
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
          // actions: [
          //   Row(
          //     children: [
          //       // 新增：添加一个 SizedBox 来调整按钮的位置
          //       SizedBox(width: 16),
          //       // 修改：将 PopupMenuButton 包装在 Center 中以垂直居中
          //       Center(
          //         child: PopupMenuButton<String>(
          //           onSelected: (String result) {
          //             if (result == 'prepay') {
          //               print('预支付学费被选中');
          //             }
          //           },
          //           itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //             const PopupMenuItem<String>(
          //               value: 'prepay',
          //               child: Text('预支付学费'),
          //                     ),
          //             ],
          //           ),
          //       ),
          //                     // 新增：添加一个 SizedBox 来平衡左右间距
          //       SizedBox(width: 16),
          //     ],
          //   ),
          // ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _stuNameController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '学生姓名',
                        labelStyle: TextStyle(
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 0.6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 0.6),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 32,
                    child: GestureDetector(
                      onTap: _showYearPicker,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '选择年份',
                          labelStyle: TextStyle(
                            color: Colors.red,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 0.6),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 0.6),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                final months = feeDetailList.map((detail) => detail.month).where((month) 
                                                              => month > 0).toSet().toList()..sort();
                print('Available months: $months');
                
                return ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final monthData = feeDetailList.where((detail) => detail.month == month).toList();
                    monthData.first.stuId = widget.stuId;
                    monthData.first.stuName = widget.stuName;
                    // 修改：传递fetchFeeDetails函数给MonthLineItem
                    return MonthLineItem(month: month, 
                                     monthData: monthData, 
                               fetchFeeDetails: fetchFeeDetails,
                                      pagePath: widget.pagePath, );
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

// 修改：MonthLineItem类的定义，添加fetchFeeDetails参数
class MonthLineItem extends StatelessWidget {
  final int month;
  final List<Kn02F002FeeBean> monthData;
  final Future<void> Function() fetchFeeDetails;
  final String pagePath;

  const MonthLineItem({
    super.key, 
    required this.month, 
    required this.monthData, 
    required this.fetchFeeDetails,
    required this.pagePath, // LsnFeeDetail调用MonthLineItem时，把LsnFeeDetail的pagePath传递过来
  });


  @override
  Widget build(BuildContext context) {
    double totalFee = monthData.fold(0, (sum, item) => sum + item.lsnFee);
    final currentMonth = DateTime.now().month;

    // 计算蓝色边框的高度
    double recordHeight = 15.0; // 每条记录的高度
    double spaceHeight = 15.0;
    double orangeAreaHeight = 30.0; // 橙色区域的高度
    double blueContainerHeight = monthData.length * recordHeight + spaceHeight + orangeAreaHeight + 16.0; // 16.0 for padding

    // 修改：检查是否所有的ownFlg都是1
    bool allPaid = monthData.every((item) => item.ownFlg == 1);

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
                    thickness: 0.5, // 线条调细至原来的一半
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
                  // 🔸课费总计区域
                  Container(
                    height: 30, // 固定红色边框容器的高度
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 0.4), // 调整为原来的60%
                      color: Colors.red.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '课费总计: \$${totalFee.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, 
                                                   fontWeight: FontWeight.bold,
                                                   color: Colors.red),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'record') {
                                // 迁移至课费记账画面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Kn02F003LsnPay(monthData: monthData, 
                                                                           allPaid: allPaid,
                                                                         knBgColor: Constants.lsnfeeThemeColor,
                                                                       knFontColor: Colors.white,
                                                                          pagePath: pagePath,
                                                                           ),
                                  ),
                                ).then((value) {
                                  // 在此处执行页面刷新（画面重现加载处理）
                                  fetchFeeDetails();
                                });
                              } 
                              // 新增：处理查看学费按钮
                              else if (result == 'view') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Kn02F003LsnPay(monthData: monthData, 
                                                                           allPaid: allPaid,
                                                                         knBgColor: Constants.lsnfeeThemeColor,
                                                                       knFontColor: Colors.white,
                                                                          pagePath: pagePath,
                                                                           ),
                                  ),
                                ).then((value) {
                                  // 在此处执行页面刷新（画面重现加载处理）
                                  fetchFeeDetails();
                                });;
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              // 修改：根据allPaid的值决定显示哪个按钮
                              if (!allPaid)
                                const PopupMenuItem<String>(
                                  value: 'record',
                                  child: Text('学费记账'),
                                ),
                              if (allPaid)
                                const PopupMenuItem<String>(
                                  value: 'view',
                                  child: Text('学费查看'),
                                ),
                            ],
                            icon: const Icon(Icons.more_vert, size: 20),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 🔸各科明显区域 + 【已支付和未支付区域】
                  Container(
                    height: blueContainerHeight, // 动态设置蓝色边框容器的高度
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 0.4), // 调整为原来的60%
                      color: Colors.blue[10],
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: monthData.map((item) {
                              String lessonTypeText = '';
                              switch (item.lessonType) {
                                case 0:
                                  lessonTypeText = '课结算';
                                  break;
                                case 1:
                                  lessonTypeText = '月计划';
                                  break;
                                case 2:
                                  lessonTypeText = '月加课';
                                  break;
                              }
                              // 修改：根据ownFlg决定文本样式
                              TextStyle textStyle = TextStyle(
                                fontSize: 12,
                                color: item.ownFlg == 1 ? Colors.black : Colors.blue,
                                decoration: item.ownFlg == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                              );
                              return SizedBox(
                                height: recordHeight,
                                child: Text(
                                  '${item.subjectName}   $lessonTypeText: ${item.lsnCount}节     课费：\$${item.lsnFee.toStringAsFixed(2)}',
                                  style: textStyle,
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            height: orangeAreaHeight,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange, width: 0.2),
                              color: Colors.yellow[50],
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '已支付: \$${monthData.where((item) => item.ownFlg == 1).fold(0.0, (sum, item) => sum + item.lsnFee).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.orange)
                                ),
                                Text(
                                  '未支付: \$${monthData.where((item) => item.ownFlg == 0).fold(0.0, (sum, item) => sum + item.lsnFee).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.orange)
                                ),
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