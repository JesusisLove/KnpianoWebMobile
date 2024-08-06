import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/03StuDocMngmnt/1studentBasic/knstu001_list.dart';
import 'package:kn_piano/03StuDocMngmnt/2subjectBasic/knsub001_list.dart';
import 'package:kn_piano/05SettingMngmnt/4FixedLesson/knfixlsn001_list.dart';
import '01LessonMngmnt/1LessonSchedual/CalendarPage.dart';
import '02LsnFeeMngmnt/Kn02f005FeeMonthlyReportPage.dart';
import '03StuDocMngmnt/3bankBasic/kn03D003Bnk_list.dart';
import '03StuDocMngmnt/4stuDoc/kn03D004StuDoc_list.dart';
import '04IntegratMngmnt/3SuspensionOfLesson/StudentLeaveListPage.dart';
import '05SettingMngmnt/5BatchArrangeLessonManual/Kn05S002WeekCalculatorSchedual.dart';
import 'CommonProcess/StudentNameMenuCommon.dart';
import 'Constants.dart' as consts;
import 'Constants.dart'; // 引入包含全局常量的文件

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> getPageWidgets(int index) {
    switch (index) {
      case 0:
        // 上课管理页面
        return[
          setButton(iconData: Icons.schedule, text: "学生课程表", onPressed: () {
            DateTime dateTime = DateTime.now(); // 假设这是您的 DateTime 变量
            String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
            Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarPage(focusedDay: formattedDate)));
          }, bgcolor: consts.Constants.lessonThemeColor, ),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔  

          setButton(iconData: Icons.timeline, text: "上课进度管理", onPressed: () {
             Navigator.push(context, MaterialPageRoute(
                builder: (context) =>  StudentNameMenuCommon(
                          knBgColor: consts.Constants.lessonThemeColor,
                          knFontColor: Colors.white,
                          pagePath: "上课进度管理>>在课学生一览",
                          pageId: Constants.kn01L002LsnStatistic,
                          strUri: '${Constants.lsnInfoStuName}/${DateTime.now().year}',)
              ));
          }, bgcolor: consts.Constants.lessonThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.pie_chart, text: "上课历史记录", onPressed: () {}, bgcolor: consts.Constants.lessonThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.pie_chart, text: "课时统计查询", onPressed: () {}, bgcolor: consts.Constants.lessonThemeColor,),
        ];
      case 1:
        // 学费管理页面
        return [
          setButton(iconData: Icons.payment, text: "课费支付管理", onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const StuFinancialPage()));
             Navigator.push(context, MaterialPageRoute(
                builder: (context) => StudentNameMenuCommon(
                          knBgColor: consts.Constants.lsnfeeThemeColor,
                          knFontColor: Colors.white,
                          pagePath: "课费支付管理>>在课学生一览",
                          pageId: Constants.stuLsnFeeListPage,
                          strUri: '${Constants.apiStuNameByYear}/${DateTime.now().year}',)
              ));
          }, bgcolor: consts.Constants.lsnfeeThemeColor, ),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔


          // setButton(iconData: Icons.forward, text: "提前支付学费", onPressed: () {}, bgcolor: consts.Constants.lsnfeeThemeColor,),
          // const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.assessment, text: "学费月度报告", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthlyIncomeReportPage(
                                  knBgColor: consts.Constants.lsnfeeThemeColor,
                                  knFontColor: Colors.white,
                                  pagePath: "学费管理",)

            ));
          }, bgcolor: consts.Constants.lsnfeeThemeColor,),
        ];
      case 2:
        // 档案管理页面
        return [
          setButton(iconData: Icons.school , text: "学生基本信息管理", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StuEditList()));
          }, bgcolor:consts.Constants.stuDocThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔


          setButton(iconData: Icons.book, text: "科目基本信息管理", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectViewPage()));
          }, bgcolor: consts.Constants.stuDocThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔


          setButton(iconData: Icons.food_bank, text: "银行基本信息管理", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BankViewPage()));
          }, bgcolor:consts.Constants.stuDocThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
        
          setButton(iconData: Icons.folder, text: "学生档案信息管理", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentDocPage()));
          }, bgcolor: consts.Constants.stuDocThemeColor,),
        ];
      case 3:
        // 综合管理页面（假设暂无特定按钮）
        return [
          setButton(iconData: Icons.person_off, text: "学生休学退学", onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => StudentLeaveListPage()));
          }, bgcolor: consts.Constants.ingergThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.score, text: "学生考试管理", onPressed: () {}, bgcolor: consts.Constants.ingergThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.calendar_month, text: "年度课程汇报", onPressed: () {}, bgcolor: consts.Constants.ingergThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.receipt, text: "年度账单明细", onPressed: () {}, bgcolor: consts.Constants.ingergThemeColor,),
        ];
      case 4:
        // 设置管理页面
        return [
          // setButton(iconData: Icons.calendar_today, text: "年度周次执行", onPressed: () {}, bgcolor: consts.Constants.settngThemeColor,),
          // const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          setButton(iconData: Icons.calendar_today, text: "周次排课设置", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Kn05S002WeekCalculatorSchedual(
                                  knBgColor: consts.Constants.settngThemeColor,
                                  knFontColor: Colors.white,
                                  pagePath: "设置管理",)
                                ));
          }, bgcolor: consts.Constants.settngThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔

          setButton(iconData: Icons.language, text: "多国语言切换", onPressed: () {}, bgcolor: consts.Constants.settngThemeColor,),
          const SizedBox(height: consts.Constants.homePageControlMargin), // 添加一些间隔
          
          setButton(iconData: Icons.settings, text: "固定排课设置", onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClassSchedulePage(
                                  knBgColor: consts.Constants.settngThemeColor,
                                  knFontColor: Colors.white,
                                  pagePath: "设置管理",)
                                ));



          }, bgcolor: consts.Constants.settngThemeColor,),
        ];
      default:
        return [const Text("未定义页面")];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("主页面"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getPageWidgets(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '上课管理'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: '学费管理'),
          BottomNavigationBarItem(icon: Icon(Icons.engineering), label: '档案管理'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '综合管理'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置管理'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  // 创建主页面Button按钮共通
  Widget setButton({
    required IconData iconData, // 图标
    required String text, // 按钮文本
    required VoidCallback onPressed, // 按钮点击事件回调
    required Color bgcolor,
  }) {
    return Container(
      width: consts.Constants.homePageButtonWidth,
      height: consts.Constants.homePageButtonHeight,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgcolor,// 设置按钮背景颜色
          foregroundColor: Colors.white, // 设置文字和图标颜色
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData), // 使用传入的图标
            const SizedBox(width: 8),
            Text(
              text, // 使用传入的文本
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
