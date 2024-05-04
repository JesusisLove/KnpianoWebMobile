
//import 'dart:ffi'; //启用它就不能正常启动chrome
import 'package:flutter/material.dart';

class Constants {
/// 注释规范，为了今后维护方便
/// url请求常量的注释内容，必须与窗体里按钮响应事件的注释内容一致
/// 
/// 

// 学生档案菜单画面，点击“保存”按钮的url请求
static const String studentInfoAdd = '/liu/mb_kn_stu_001_add';
// 学生档案菜单画面，点击“学生档案编辑”按钮的url请求
static const String studentInfoView = '/liu/mb_kn_stu_001_all';



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