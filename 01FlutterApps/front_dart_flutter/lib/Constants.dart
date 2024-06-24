
//import 'dart:ffi'; //启用它就不能正常启动chrome
import 'package:flutter/material.dart';

class Constants {
/// 注释规范，为了今后维护方便
/// url请求常量的注释内容，必须与窗体里按钮响应事件的注释内容一致
/// 

// ******* 上课管理模块 *******//





// ******* 档案管理模块 *******//
// 学生科目一览画面，画面初期化的url请求
static const String subjectView = '/liu/mb_kn_sub_001_all';

// 学生科目新规画面，点击“保存”按钮的url请求
static const String subjectInfoAdd = '/liu/mb_kn_sub_001';

// 学生科目编辑画面，点击“保存”按钮的url请求
static const String subjectInfoEdit = '/liu/mb_kn_sub_001';

// 学生科目一览画面，点击“删除”按钮的url请求
static const String subjectInfoDelete = '/liu/mb_kn_sub_001';

// 学生科目级别一览画面，画面初期化的url请求
static const String subjectEdaView = '/liu/mb_kn_05s003_subject_edabn_by_subid';

// 学生科目级别新规画面，点击“保存”按钮的url请求
static const String subjectEdaAdd = '/liu/mb_kn_05s003_subject_edabn';

// 学生科目级别编辑画面，点击“保存”按钮的url请求
static const String subjectEdaEdit = '/liu/mb_kn_05s003_subject_edabn';

// 学生科目级别一览画面，点击“删除”按钮的url请求
static const String subjectEdaDelete = '/liu/mb_kn_05s003_subject_edabn';

// 学生档案菜单画面，点击“学生档案编辑”按钮的url请求
static const String studentInfoView = '/liu/mb_kn_stu_001_all';

// 学生档案菜单画面，点击“保存”按钮的url请求
static const String studentInfoAdd = '/liu/mb_kn_stu_001_add';

// 学生档案编辑画面，点击“保存”按钮的url请求
static const String studentInfoEdit = '/liu/mb_kn_stu_001_edit';

// 银行一览画面，画面初期化的url请求
static const String bankView = '/liu/mb_kn_03d003_bank_all';

// 银行学生新规画面，点击“保存”按钮的url请求
static const String bankAddEdit = '/liu/mb_kn_03d003_bank';

// 银行学生一览画面，点击“删除”按钮的url请求
static const String bankDelete = '/liu/mb_kn_03d003_bank';

// 银行一览画面，画面初期化的url请求
static const String stuBankView = '/liu/mb_kn_03d003_students_by_bankid';

// 银行学生新规画面，点击“保存”按钮的url请求
static const String stuBankAdd = '/liu/mb_kn_03d003_bank_stu';

// 银行学生一览画面，点击“删除”按钮的url请求
static const String stuBankDelete = '/liu/mb_kn_03d003_bank_stu';







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
static const Color lessonThemeColor = Color.fromARGB(255, 37, 205, 191);
static const Color lsnfeeThemeColor = Color.fromARGB(255, 92, 190, 12);
static const Color stuDocThemeColor = Color.fromARGB(255, 240, 150, 30);
static const Color ingergThemeColor = Color.fromARGB(255, 255, 141, 186);
static const Color settngThemeColor = Color.fromARGB(255, 155, 125, 230);

static const double enabledBorderSideWidth = 0.5;
static const double focusedBorderSideWidth = 1.5;
















}