import 'package:flutter/material.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'HomePage.dart';  // 确保这里正确导入HomePage.dart

// import 'myfirstapp.dart';
//  export 'myfirstapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保Flutter绑定初始化
  await KnConfig.load(); // 加载SpringBoot端的ip地址及端口
  runApp(const MaterialApp(
    title: 'Flutter Demo',
    home: HomePage(),  // 使用HomePage作为启动页面
  ));
}

