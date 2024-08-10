// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ApiConfig/KnApiConfig.dart';
import '../CommonProcess/customUI/KnAppBar.dart';
import '../Constants.dart';
import 'Kn02F002FeeBean.dart';
import 'Kn02F003AdvcLsnFeePayPage.dart';
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
  late String pagePath;

  @override
  // ignore: library_private_types_in_public_api
  _LsnFeeDetailState createState() => _LsnFeeDetailState();
}

class _LsnFeeDetailState extends State<LsnFeeDetail> {
  final String titleName = '课程费用详细';
  late int selectedYear;
  late List<int> years;
  late TextEditingController _stuNameController;
  int stuFeeDetailCount = 0;
  final ValueNotifier<List<Kn02F002FeeBean>> stuFeeDetailNotifier =
      ValueNotifier([]);

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
    final String apiLsnPaidAndUnpaidDetailUrl =
        '${KnConfig.apiBaseUrl}${Constants.apiStuFeeDetailByYear}/${widget.stuId}/$selectedYear';
    final responseFeeDetails =
        await http.get(Uri.parse(apiLsnPaidAndUnpaidDetailUrl));
    if (responseFeeDetails.statusCode == 200) {
      final decodedBody = utf8.decode(responseFeeDetails.bodyBytes);
      List<dynamic> stuDocJson = json.decode(decodedBody);
      setState(() {
        stuFeeDetailNotifier.value =
            stuDocJson.map((json) => Kn02F002FeeBean.fromJson(json)).toList();
        stuFeeDetailCount = stuFeeDetailNotifier.value.length;
      });
    } else {
      throw Exception('Failed to load archived students');
    }
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Center(
                  child: Text(
                    '选择年份',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
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
                  children: years
                      .map((year) => Center(
                          child: Text(year.toString(),
                              style: const TextStyle(color: Colors.red))))
                      .toList(),
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
      appBar: KnAppBar(
        title: titleName,
        subtitle: "${widget.pagePath} >> $titleName",
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义AppBar背景颜色
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha, // 自定义标题颜色
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white, // 自定义底部文本颜色
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: widget.knFontColor),
            onSelected: (String result) async {
              if (result == 'prepay') {
                final bool? success = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Kn02F003AdvcLsnFeePayPage(
                              stuId: widget.stuId,
                              stuName: widget.stuName,
                              knBgColor: widget.knBgColor,
                              knFontColor: widget.knFontColor,
                              pagePath: widget.pagePath,
                            )));
                if (success == true) {
                  // 如果预支付成功，刷新页面数据
                  fetchFeeDetails();
                }
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                            borderSide:
                                BorderSide(color: Colors.red, width: 0.6),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 0.6),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                final months = feeDetailList
                    .map((detail) => detail.month)
                    .where((month) => month > 0)
                    .toSet()
                    .toList()
                  ..sort();

                return ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final monthData = feeDetailList
                        .where((detail) => detail.month == month)
                        .toList();
                    monthData.first.stuId = widget.stuId;
                    monthData.first.stuName = widget.stuName;
                    // 修改：传递fetchFeeDetails函数给MonthLineItem
                    return MonthLineItem(
                      month: month,
                      monthData: monthData,
                      fetchFeeDetails: fetchFeeDetails,
                      pagePath: widget.pagePath,
                    );
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
    final bool isAdvancePay = monthData.any((item) => item.advcFlg == 0);

    // 计算蓝色边框的高度
    double recordHeight = 15.0; // 每条记录的高度
    double spaceHeight = 15.0;
    double orangeAreaHeight = 30.0; // 橙色区域的高度
    // 修改：减少高度计算，因为我们不再需要额外的空间来容纳单独的预付费标签行
    double blueContainerHeight = monthData.length * recordHeight +
        spaceHeight +
        orangeAreaHeight +
        16.0; // 16.0 for padding

    // 修改：检查是否所有的ownFlg都是1
    bool allPaid = monthData.every((item) => item.ownFlg == 1);

    Color monthColor;
    Color backgroundColorTotal;
    Color textColorTotal;

    if (month < currentMonth) {
      if (isAdvancePay) {
        monthColor = Colors.black;
        backgroundColorTotal = Colors.lightBlue[100]!;
        textColorTotal = Colors.blue[800]!;
      } else {
        monthColor = Colors.red;
        backgroundColorTotal = Colors.red[100]!;
        textColorTotal = Colors.red;
      }
    } else if (month == currentMonth) {
      monthColor = Colors.green;
      backgroundColorTotal = Colors.green[800]!;
      textColorTotal = Colors.white;
    } else {
      if (isAdvancePay) {
        monthColor = Colors.blue[800]!;
        backgroundColorTotal = Colors.lightBlue[100]!;
        textColorTotal = Colors.blue[800]!;
      } else {
        monthColor = Colors.red;
        backgroundColorTotal = Colors.red[100]!;
        textColorTotal = Colors.red;
      }
    }

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
                    color: monthColor,
                  ),
                ),
                const Expanded(
                  child: VerticalDivider(
                    color: Colors.red, // 时间轴线颜色
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
                      border: Border.all(
                          color: Colors.red, width: 0.4), // 调整为原来的60%
                      color: backgroundColorTotal,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '课费总计: \$${totalFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColorTotal,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'record' || result == 'view') {
                                // 迁移至课费记账
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Kn02F003LsnPay(
                                      monthData: monthData,
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
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
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
                  // 🔸各科明细区域 + 【已支付和未支付区域】
                  Container(
                    height: blueContainerHeight, // 动态设置蓝色边框容器的高度
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.blue, width: 0.4), // 调整为原来的60%
                      color: Colors.blue[10],
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10)),
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
                              String lsnFeeText = '时课费';
                              switch (item.lessonType) {
                                case 0:
                                  lessonTypeText = '课结算';
                                  break;
                                case 1:
                                  lessonTypeText = '月计划';
                                  lsnFeeText = '月课费';
                                  break;
                                case 2:
                                  lessonTypeText = '月加课';
                                  break;
                              }
                              // 修改：根据ownFlg和advcFlg决定文本样式
                              TextStyle textStyle = TextStyle(
                                fontSize: 12,
                                color: item.advcFlg == 0
                                    ? Colors.blue
                                    : (item.ownFlg == 1
                                        ? Colors.black
                                        : Colors.blue),
                                decoration: item.advcFlg == 0
                                    ? TextDecoration.none
                                    : (item.ownFlg == 1
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none),
                              );
                              // 修改：将科目信息和预付费标签放在同一行
                              return SizedBox(
                                height: recordHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.subjectName}   $lessonTypeText: ${item.lsnCount}节     $lsnFeeText：\$${item.lessonType == 1 ? (item.subjectPrice! * 4).toStringAsFixed(2) : item.lsnFee.toStringAsFixed(2)}',
                                        style: textStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (item.advcFlg == 0)
                                      const Text(
                                        '【预付费】',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            height: orangeAreaHeight,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.orange, width: 0.2),
                              color: Colors.yellow[50],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '已支付: \$${monthData.where((item) => item.ownFlg == 1).fold(0.0, (sum, item) => sum + item.lsnFee).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.orange)),
                                Text(
                                    '未支付: \$${monthData.where((item) => item.ownFlg == 0).fold(0.0, (sum, item) => sum + item.lsnFee).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.orange)),
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
