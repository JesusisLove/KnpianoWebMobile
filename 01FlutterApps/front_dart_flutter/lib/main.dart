import 'package:flutter/material.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
import 'HomePage.dart';  // 确保这里正确导入HomePage.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置默认值
  KnConfig.apiBaseUrl = "http://10.8.0.10:8080";

  // 尝试加载配置（带超时）
  try {
    await KnConfig.load().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        print('配置加载超时，使用默认值');
      },
    );
  } catch (e) {
    print('配置加载失败: $e，使用默认值');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '一对一教学管理系统',
      home: HomePage(currentNavIndex: 0),
    );
  }
}

