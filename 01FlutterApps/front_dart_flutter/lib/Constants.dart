
//import 'dart:ffi'; //启用它就不能正常启动chrome
import 'package:flutter/material.dart';

class Constants {
/// 注释规范，为了今后维护方便
/// url请求常量的注释内容，必须与窗体里按钮响应事件的注释内容一致
/// 

// ******* 上课管理模块 *******//
// 课程表一览页面当前选中日期的这一天课程信息
static const String lsnInfoByDay = '/liu/mb_kn_lsn_info_by_day';

// 新规排课页面获取系统定义的上课时长
static const String apiLsnDruationUrl = '/liu/mb_kn_lsn_duration';

// 新规排课页面，从学生档案表视图中取得该学生正在上的所有科目信息
static const String apiLatestSubjectsnUrl = '/liu/mb_kn_latest_subjects';

// 课程表画面一览，课程签到请求
static const String apiStuLsnSign = '/liu/mb_kn_lsn_001_lsn_sign';

// 课程表画面一览，撤销签到请求
static const String apiStuLsnRestore = '/liu/mb_kn_lsn_001_lsn_undo';

// 编辑排课页面，从学生档案表视图中取得该学生正在上的某一科目信息
static const String apiStuLsnEdit = '/liu/mb_kn_lsn_001';

// 保存排课信息
static const String apiLsnSave = '/liu/mb_kn_lsn_001_save';

// 取消调课请求
static const String apiLsnRescheCancel = '/liu/mb_kn_lsn_resche_cancel';

// 删除排课信息
static const String apiLsnDelete = '/liu/mb_kn_lsn_001_delete';

// 课程进度统计页面的上课完了Tab页（统计指定年度中的每一个已经签到完了的课程（已支付/未支付的课程都算）
static const String apiLsnSignedStatistic = '/liu/mb_kn_lsn_signed_total';


// 课程进度统计页面的还未上课统计Tab页（统计指定年度中已经排课了却还没有上的课程
static const String apiLsnUnSignedStatistic = '/liu/mb_kn_lsn_unsigned_list';


// ******* 課費管理模块 *******//
//.......当前的学生课程费用详细................................................................

static const String apiStuNameByYear = '/liu/mb_kn_lsn_fee_001_all';

static const String apiStuFeeDetailByYear = '/liu/mb_kn_lsn_fee_by_year';

// 点击学费入账按钮，往后端发送学费入账保存请求
static const String apiStuPaySave = '/liu/mb_kn_lsn_pay_save';

// 在学生的学费账单画面里点击撤销按钮，往后端发送学费撤销请求
static const String apiStuPayRestore = '/liu/mb_kn_lsn_pay_undo';


// ******* 档案管理模块 *******//
//.......学生................................................................................
// 学生一览画面，点击“学生基本信息管理”按钮的url请求
static const String studentInfoView = '/liu/mb_kn_studoced_all';

// 学生一览画面，点击“保存”按钮的url请求
static const String studentInfoAdd = '/liu/mb_kn_stu_001_add';

// 学生新规编辑画面，点击“保存”按钮的url请求
static const String studentInfoEdit = '/liu/mb_kn_stu_001_edit';


//.......科目................................................................................
// 科目一览画面，画面初期化的url请求
static const String subjectView = '/liu/mb_kn_sub_001_all';

// 科目新规画面，点击“保存”按钮的url请求
static const String subjectInfoAdd = '/liu/mb_kn_sub_001';

// 科目编辑画面，点击“保存”按钮的url请求
static const String subjectInfoEdit = '/liu/mb_kn_sub_001';

// 科目一览画面，点击“删除”按钮的url请求
static const String subjectInfoDelete = '/liu/mb_kn_sub_001';

// 科目级别一览画面，画面初期化的url请求
static const String subjectEdaView = '/liu/mb_kn_05s003_subject_edabn_by_subid';

// 科目级别新规画面，点击“保存”按钮的url请求
static const String subjectEdaAdd = '/liu/mb_kn_05s003_subject_edabn';

// 科目级别编辑画面，点击“保存”按钮的url请求
static const String subjectEdaEdit = '/liu/mb_kn_05s003_subject_edabn';

// 科目级别一览画面，点击“删除”按钮的url请求
static const String subjectEdaDelete = '/liu/mb_kn_05s003_subject_edabn';


//.......银行................................................................................
// 银行一览画面，画面初期化的url请求
static const String bankView = '/liu/mb_kn_03d003_bank_all';

// 银行学生新规画面，点击“保存”按钮的url请求
static const String bankAddEdit = '/liu/mb_kn_03d003_bank';

// 银行学生一览画面，点击“删除”按钮的url请求
static const String bankDelete = '/liu/mb_kn_03d003_bank';

// 银行一览画面，画面初期化的url请求
static const String stuBankView = '/liu/mb_kn_03d003_students_by_bankid';

// 学费记账的画面初期表示里，用到该生名下ta的银行名称
static const String stuBankList = '/liu/mb_kn_03d003_banks_by_stuid';

// 银行学生新规画面，点击“保存”按钮的url请求
static const String stuBankAdd = '/liu/mb_kn_03d003_bank_stu';

// 银行学生一览画面，点击“删除”按钮的url请求
static const String stuBankDelete = '/liu/mb_kn_03d003_bank_stu';


//.......档案................................................................................
// 学生档案一览画面，点击“学生档案信息管理”按钮的url请求
static const String stuDocInfoView = '/liu/mb_kn_studoced_all';
static const String stuUnDocInfoView = '/liu/mb_kn_undoc_all';

// 当前学生目前所学科目的详细信息的url请求
static const String stuDocDetailView = '/liu/mb_kn_studoc_detail';

// 学生新规，编辑画面，点击“保存”按钮的url请求
static const String stuDocInfoSave = '/liu/mb_kn_studoc_001_save';

// 学生详细一览画面，点击“编辑”按钮的url请求
static const String stuDocInfoEdit = '/liu/mb_kn_studoc_001';

// 取得学生上1节课的分钟时长
static const String stuDocLsnDuration = '/liu/mb_kn_duration';

// 学生档案一览画面，点击“删除”按钮的url请求
static const String stuDocInfoDelete = '/liu/mb_kn_studoc_001_delete';










// ******* 设置管理模块 *******//
// 设置管理菜单画面，点击“固定排课设置”按钮的url请求
static const String fixedLsnInfoView = '/liu/mb_kn_fixlsn_001_all';

//固定排课一览画面，点击LiseView里的“新規”按钮的url请求
static const String fixedLsnInfoAdd = '/liu/mb_kn_fixlsn_001';
static const String fixeDocStuSubInfoGet = '/liu/mb_kn_fixlsn_stusub_get';

//固定排课一览画面，点击LiseView里的“编辑”按钮的url请求
static const String fixedLsnInfoEdit = '/liu/mb_kn_fixlsn_001';

//固定排课一览画面，点击LiseView里的“删除”按钮的url请求
static const String fixedLsnInfoDelete = '/liu/mb_kn_fixlsn_001';


// 主页面button按钮尺寸
static const double homePageButtonWidth = 240.0;  
static const double homePageButtonHeight = 60.0;
// 主页面控件与控件之间的间隔尺寸
static const double homePageControlMargin = 40.0;
// 主页面控件与窗体边界的间隔尺寸
static const double homePageControlPadding = 40.0;

// 画面控件背景颜色主题
static const Color lessonThemeColor = Color.fromARGB(255, 6, 232, 213);
static const Color lsnfeeThemeColor = Color.fromARGB(255, 229, 57, 53);
static const Color stuDocThemeColor = Color.fromARGB(255, 57, 150, 50);
static const Color ingergThemeColor = Color.fromARGB(255, 255, 141, 186);
static const Color settngThemeColor = Color.fromARGB(255, 155, 125, 230);

static const double enabledBorderSideWidth = 0.5;
static const double focusedBorderSideWidth = 1.5;


////////// 画面跳转映射用的 PageIp 定义 ////////////////////////////////////////////////////////////////////////////////////
static const String stuLsnFeeListPage = 'stuFinacialPage';
// 课程进度统计页面的pageId
static const String kn01L002LsnStatistic = 'Kn01L002LsnStatistic';














}