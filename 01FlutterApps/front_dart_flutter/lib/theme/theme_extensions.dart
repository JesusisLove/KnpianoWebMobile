// [Flutter页面主题改造] 2026-01-17 新增主题扩展辅助类
// 提供便捷的BuildContext扩展方法，方便页面访问主题配置

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_config.dart';
import 'providers/theme_provider.dart';

/// BuildContext扩展 - 便捷访问主题配置
extension ThemeContextExtension on BuildContext {
  /// 获取ThemeProvider
  ThemeProvider get themeProvider => Provider.of<ThemeProvider>(this);

  /// 获取ThemeProvider（不监听变化）
  ThemeProvider get themeProviderRead =>
      Provider.of<ThemeProvider>(this, listen: false);

  /// 获取当前主题配置
  ThemeConfig get themeConfig => themeProvider.currentConfig;

  /// 获取当前主题颜色
  ThemeColors get themeColors => themeConfig.colors;

  /// 获取模块颜色
  ModuleColors get moduleColors => themeColors.modules;

  /// 获取状态颜色
  StatusColors get statusColors => themeColors.status;

  /// 获取间距配置
  ThemeSpacing get themeSpacing => themeConfig.spacing;

  /// 获取形状配置
  ThemeShapes get themeShapes => themeConfig.shapes;

  /// 获取阴影配置
  ThemeShadows get themeShadows => themeConfig.shadows;

  /// 获取动画配置
  ThemeAnimations get themeAnimations => themeConfig.animations;

  /// 获取图标配置
  ThemeIcons get themeIcons => themeConfig.icons;

  /// 根据模块名称获取颜色
  ModuleColor getModuleColor(String moduleName) {
    return themeProvider.getModuleColor(moduleName);
  }
}

/// 模块颜色枚举 - 用于类型安全的模块颜色获取
enum KnModule {
  lesson,
  fee,
  archive,
  summary,
  setting,
}

/// KnModule扩展
extension KnModuleExtension on KnModule {
  String get name {
    switch (this) {
      case KnModule.lesson:
        return 'lesson';
      case KnModule.fee:
        return 'fee';
      case KnModule.archive:
        return 'archive';
      case KnModule.summary:
        return 'summary';
      case KnModule.setting:
        return 'setting';
    }
  }

  /// 获取模块颜色
  ModuleColor getColor(BuildContext context) {
    return context.getModuleColor(name);
  }
}
