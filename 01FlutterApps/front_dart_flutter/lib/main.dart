import 'package:flutter/material.dart';
import 'package:my_first_app/ConfigAPI/config.dart';
import 'HomePage.dart';  // 确保这里正确导入HomePage.dart

// import 'myfirstapp.dart';
//  export 'myfirstapp.dart';

Future<void> main() async {
  runApp(const MaterialApp(
    title: 'Flutter Demo',
    home: HomePage(),  // 使用HomePage作为启动页面
  ));
}

