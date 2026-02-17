import 'package:flutter/material.dart';
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';
// [Flutter页面主题改造] 2026-01-17 添加主题系统Provider
import 'package:provider/provider.dart';
import 'theme/providers/theme_provider.dart';
import 'HomePage.dart'; // 确保这里正确导入HomePage.dart
// [应用锁定功能] 2026-02-17 添加锁定功能相关导入
import 'security/app_lock_provider.dart';
import 'security/app_lock_screen.dart';
import 'security/pin_setup_screen.dart';

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

  // [应用锁定功能] 2026-02-17 初始化锁定Provider
  final appLockProvider = AppLockProvider();
  await appLockProvider.initialize();

  runApp(
    // [应用锁定功能] 2026-02-17 改为MultiProvider，同时提供ThemeProvider和AppLockProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: appLockProvider),
      ],
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
          // [应用锁定功能] 2026-02-17 使用GestureDetector检测用户操作以重置超时计时器
          home: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () =>
                Provider.of<AppLockProvider>(context, listen: false).onUserActivity(),
            onPanDown: (_) =>
                Provider.of<AppLockProvider>(context, listen: false).onUserActivity(),
            child: Consumer<AppLockProvider>(
              builder: (context, lockProvider, child) {
                return Stack(
                  children: [
                    // 主画面
                    HomePage(currentNavIndex: 0),
                    // PIN设置画面（首次启动，未设置PIN时显示）
                    if (!lockProvider.isPinSet)
                      const PinSetupScreen(mode: PinSetupMode.setup),
                    // PIN输入画面（已锁定时显示）
                    if (lockProvider.isPinSet && lockProvider.isLocked)
                      const AppLockScreen(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
