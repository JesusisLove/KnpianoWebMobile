import 'package:flutter/material.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
// [Flutter页面主题改造] 2026-01-17 添加主题系统Provider
import 'package:provider/provider.dart';
import 'theme/providers/theme_provider.dart';
import 'HomePage.dart'; // 确保这里正确导入HomePage.dart

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

  // [Flutter页面主题改造] 2026-01-17 初始化主题Provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    // [Flutter页面主题改造] 2026-01-17 使用ChangeNotifierProvider包装应用
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [Flutter页面主题改造] 2026-01-17 从Provider获取主题数据
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '一对一教学管理系统',
          // [Flutter页面主题改造] 2026-01-17 应用动态主题
          theme: themeProvider.themeData,
          home: HomePage(currentNavIndex: 0),
        );
      },
    );
  }
}
