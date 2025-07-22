import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kn_piano/03StuDocMngmnt/1studentBasic/knstu001_list.dart';
import 'package:kn_piano/03StuDocMngmnt/2subjectBasic/knsub001_list.dart';
import 'package:kn_piano/05SettingMngmnt/4FixedLesson/knfixlsn001_list.dart';
import '01LessonMngmnt/1LessonSchedual/CalendarPage.dart';
import '02LsnFeeMngmnt/Kn02f005FeeMonthlyReportPage.dart';
import '03StuDocMngmnt/3bankBasic/kn03D003Bnk_list.dart';
import '03StuDocMngmnt/4stuDoc/kn03D004StuDoc_list.dart';
import '04IntegratMngmnt/Kn04I003LsnCounting.dart';
import '04IntegratMngmnt/SubSubjectOfStudentsListBySubject.dart';
import '04IntegratMngmnt/3SuspensionOfLesson/StudentLeaveListPage.dart';
import '05SettingMngmnt/5BatchArrangeLessonManual/Kn05S002WeekCalculatorSchedual.dart';
import 'CommonProcess/StudentNameMenuCommon.dart';
import 'Constants.dart' as consts;
import 'Constants.dart'; // 引入包含全局常量的文件

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  late int currentNavIndex;

  HomePage({
    super.key,
    required this.currentNavIndex,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 钢琴Logo Widget
  Widget _buildPianoLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // 钢琴键盘图标
          Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Stack(
              children: [
                // 白键
                Positioned(
                  bottom: 0,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Expanded(child: _PianoKey(isBlack: false)),
                      SizedBox(width: 1),
                      Expanded(child: _PianoKey(isBlack: false)),
                      SizedBox(width: 1),
                      Expanded(child: _PianoKey(isBlack: false)),
                      SizedBox(width: 1),
                      Expanded(child: _PianoKey(isBlack: false)),
                    ],
                  ),
                ),
                // 黑键
                Positioned(
                  bottom: 15,
                  left: 15,
                  right: 15,
                  child: Row(
                    children: [
                      Expanded(child: _PianoKey(isBlack: true)),
                      SizedBox(width: 8),
                      Expanded(child: _PianoKey(isBlack: true)),
                      SizedBox(width: 8),
                      Expanded(child: SizedBox()),
                      SizedBox(width: 8),
                      Expanded(child: _PianoKey(isBlack: true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 标题
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ).createShader(bounds),
            child: const Text(
              'KuanNi Piano Studio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Text(
            '观妮的钢琴课程管理系统',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 获取页面标题和描述
  Map<String, dynamic> _getPageInfo(int index) {
    switch (index) {
      case 0:
        return {
          'title': '上课管理',
          'subtitle': '课程安排与进度跟踪',
          'gradient': [const Color(0xFF56ab2f), const Color(0xFFa8e6cf)],
        };
      case 1:
        return {
          'title': '学费管理',
          'subtitle': '学费收支与财务统计',
          'gradient': [
            const Color(0xFFf093fb),
            const Color(0xFFf5576c)
          ], // 恢复原来的粉紫色
        };
      case 2:
        return {
          'title': '档案管理',
          'subtitle': '学生信息与档案维护',
          'gradient': [
            const Color(0xFF8B4513),
            const Color(0xFFCD853F)
          ], // 保留棕色系
        };
      case 3:
        return {
          'title': '综合管理',
          'subtitle': '统计分析与综合查询',
          'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        };
      case 4:
        return {
          'title': '设置管理',
          'subtitle': '系统配置与个性化设置',
          'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
        };
      default:
        return {
          'title': '管理系统',
          'subtitle': '欢迎使用',
          'gradient': [Colors.blue, Colors.purple],
        };
    }
  }

  // 创建方块按钮
  Widget _buildSquareButton({
    required IconData iconData,
    required String text,
    required String description,
    required VoidCallback onPressed,
    required List<Color> gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        // 确保opacity值在有效范围内
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(
            opacity: clampedValue,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50, // 图标的宽度
                          height: 50, // 图标的高度
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            iconData,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 创建方块网格布局
  Widget _buildGridButtons(
      List<Map<String, dynamic>> buttonData, List<Color> gradient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28), // 左右边距大小调整
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 32, // 方块按钮间的纵向间距
          mainAxisSpacing: 48, // 方块按钮间的横向间距
          childAspectRatio: 1.2,
        ),
        itemCount: buttonData.length,
        itemBuilder: (context, index) {
          final button = buttonData[index];
          return _buildSquareButton(
            iconData: button['icon'],
            text: button['text'],
            description: button['description'],
            onPressed: button['onPressed'],
            gradient: gradient,
            delay: index * 100,
          );
        },
      ),
    );
  }

  List<Widget> getPageWidgets(int index) {
    switch (index) {
      case 0:
        // 上课管理页面
        final lessonButtons = [
          {
            'icon': Icons.schedule,
            'text': "学生课程表",
            'description': "课程表排课签到",
            'onPressed': () {
              DateTime dateTime = DateTime.now();
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CalendarPage(focusedDay: formattedDate)));
            },
          },
          {
            'icon': Icons.timeline,
            'text': "上课进度管理",
            'description': "跟踪课程进度",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentNameMenuCommon(
                            knBgColor: consts.Constants.lessonThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "上课进度管理>>在课学生一览",
                            pageId: Constants.kn01L002LsnStatistic,
                            strUri:
                                '${Constants.lsnInfoStuName}/${DateTime.now().year}',
                          )));
            },
          },
          {
            'icon': Icons.add_circle_outline,
            'text': "加课消化管理",
            'description': "管理补课安排",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentNameMenuCommon(
                            knBgColor: consts.Constants.lessonThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "加课消化管理>>在课学生一览",
                            pageId: Constants.kn01L003ExtraToSche,
                            strUri:
                                '${Constants.lsnExtraInfoStuName}/${DateTime.now().year}',
                          )));
            },
          },
          {
            'icon': Icons.merge_type,
            'text': "碎课拼成整课",
            'description': "整合零散课时",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentNameMenuCommon(
                            knBgColor: consts.Constants.lessonThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "碎课拼成整课>>在课学生一览",
                            pageId: Constants.kn01L003ExtraPiesesIntoOne,
                            strUri:
                                '${Constants.piceseLsnStuName}/${DateTime.now().year}',
                          )));
            },
          },
        ];
        return [
          _buildGridButtons(
              lessonButtons, [const Color(0xFF56ab2f), const Color(0xFFa8e6cf)])
        ];

      case 1:
        // 学费管理页面 - 恢复原来的粉紫色
        final feeButtons = [
          {
            'icon': Icons.payment,
            'text': "学费支付管理",
            'description': "处理学费缴纳",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentNameMenuCommon(
                            knBgColor: consts.Constants.lsnfeeThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "学费支付管理>>在课学生一览",
                            pageId: Constants.stuLsnFeeListPage,
                            strUri:
                                '${Constants.apiStuNameByYear}/${DateTime.now().year}',
                          )));
            },
          },
          {
            'icon': Icons.forward,
            'text': "学费预先支付",
            'description': "提前缴费管理",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentNameMenuCommon(
                            knBgColor: consts.Constants.lsnfeeThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "学费预先支付>>在课学生一览",
                            pageId: Constants.kn02F003AdvcLsnFeePayPage,
                            strUri: Constants.apiCurrentStuName,
                          )));
            },
          },
          {
            'icon': Icons.assessment,
            'text': "学费月度报告",
            'description': "财务统计报告",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MonthlyIncomeReportPage(
                            knBgColor: consts.Constants.lsnfeeThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "学费管理",
                          )));
            },
          },
          {
            'icon': Icons.trending_up,
            'text': "收入趋势",
            'description': "收入变化分析",
            'onPressed': () {
              // 占位按钮，让网格看起来更饱满
            },
          },
        ];
        return [
          _buildGridButtons(feeButtons,
              [const Color(0xFFf093fb), const Color(0xFFf5576c)]) // 恢复原来的粉紫色
        ];

      case 2:
        // 档案管理页面 - 保留棕色系
        final docButtons = [
          {
            'icon': Icons.school,
            'text': "学生基本信息",
            'description': "入学报名登记",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StuEditList(
                            knBgColor: consts.Constants.stuDocThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "档案管理",
                          )));
            },
          },
          {
            'icon': Icons.book,
            'text': "科目基本信息",
            'description': "各课程的科目管理",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubjectViewPage(
                            knBgColor: consts.Constants.stuDocThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "档案管理",
                          )));
            },
          },
          {
            'icon': Icons.account_balance,
            'text': "银行基本信息",
            'description': "支付银行管理",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BankViewPage(
                            knBgColor: consts.Constants.stuDocThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "档案管理",
                          )));
            },
          },
          {
            'icon': Icons.folder_open,
            'text': "学生档案管理",
            'description': "学生课程档案记录",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentDocPage(
                            knBgColor: consts.Constants.stuDocThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "档案管理",
                          )));
            },
          },
        ];
        return [
          _buildGridButtons(docButtons,
              [const Color(0xFF8B4513), const Color(0xFFCD853F)]) // 保留棕色系
        ];

      case 3:
        // 综合管理页面
        final integrationButtons = [
          {
            'icon': Icons.person_off,
            'text': "学生休学退学",
            'description': "学生休学退学处理",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentLeaveListPage(
                            knBgColor: consts.Constants.ingergThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "综合管理",
                          )));
            },
          },
          {
            'icon': Icons.emoji_events,
            'text': "钢琴级别查看",
            'description': "学生钢琴级别查看",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SubSubjectOfStudentsListBySubject(
                            knBgColor: consts.Constants.ingergThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "综合管理",
                          )));
            },
          },
          {
            'icon': Icons.analytics,
            'text': "课时统计查看",
            'description': "课程进度统计分析",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Kn04I003LsnCounting(
                            knBgColor: consts.Constants.ingergThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "学费管理",
                          )));
            },
          },
          {
            'icon': Icons.receipt_long,
            'text': "年度账单明细（尚未实现）",
            'description': "年度财务报表",
            'onPressed': () {},
          },
        ];
        return [
          _buildGridButtons(integrationButtons,
              [const Color(0xFF4facfe), const Color(0xFF00f2fe)])
        ];

      case 4:
        // 设置管理页面
        final settingsButtons = [
          {
            'icon': Icons.calendar_month,
            'text': "周次排课设置",
            'description': "钢琴安排批处理",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Kn05S002WeekCalculatorSchedual(
                            knBgColor: consts.Constants.settngThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "设置管理",
                          )));
            },
          },
          {
            'icon': Icons.language,
            'text': "多国语言切换（尚未实现）",
            'description': "系统语言设置",
            'onPressed': () {},
          },
          {
            'icon': Icons.settings,
            'text': "固定排课设置",
            'description': "固定上课时间配置",
            'onPressed': () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClassSchedulePage(
                            knBgColor: consts.Constants.settngThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "设置管理",
                          )));
            },
          },
          {
            'icon': Icons.backup,
            'text': "选项设置（尚未实现）",
            'description': "系统选项设置",
            'onPressed': () {
              // 占位按钮
            },
          },
        ];
        return [
          _buildGridButtons(settingsButtons,
              [const Color(0xFF667eea), const Color(0xFF764ba2)])
        ];

      default:
        return [const Text("未定义页面")];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageInfo = _getPageInfo(widget.currentNavIndex);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Logo区域
                _buildPianoLogo(),

                // 页面标题区域
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: pageInfo['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: pageInfo['gradient'][0].withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pageInfo['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pageInfo['subtitle'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),

                // 功能按钮区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        bottom: 100, top: 36), // 功能按钮区域与第一行方块按钮的间距 top:10
                    child: Column(
                      children: getPageWidgets(widget.currentNavIndex),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '上课管理'),
            BottomNavigationBarItem(
                icon: Icon(Icons.attach_money), label: '学费管理'),
            BottomNavigationBarItem(
                icon: Icon(Icons.engineering), label: '档案管理'),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '综合管理'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置管理'),
          ],
          currentIndex: widget.currentNavIndex,
          selectedItemColor: _getPageInfo(widget.currentNavIndex)['gradient']
              [0],
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.currentNavIndex = index;
      // 重新播放动画
      _animationController.reset();
      _animationController.forward();
    });
  }
}

// 钢琴键组件
class _PianoKey extends StatelessWidget {
  final bool isBlack;

  const _PianoKey({required this.isBlack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isBlack ? 20 : 30,
      decoration: BoxDecoration(
        color: isBlack ? Colors.black87 : Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: isBlack
            ? null
            : Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
    );
  }
}
