// [Flutter页面主题改造] 2026-01-18 新增主题切换页面
// 用户可以在此页面选择不同的UI风格主题

import 'package:flutter/material.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../theme/providers/theme_provider.dart';
import '../../theme/models/theme_config.dart';
import '../../theme/kn_theme_colors.dart';
import 'package:provider/provider.dart';

class ThemeSettingPage extends StatelessWidget {
  final Color knBgColor;
  final Color knFontColor;
  final String pagePath;

  const ThemeSettingPage({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KnAppBar(
        title: '主题风格设置',
        subtitle: '$pagePath >> 主题风格设置',
        context: context,
        appBarBackgroundColor: knBgColor.withOpacity(0.2),
        subtitleBackgroundColor: knBgColor,
        titleColor: KnThemeColors.getPrimaryTextColor(context),
        currentNavIndex: 4, // 设置管理
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final currentThemeId = themeProvider.currentThemeId;
          final availableThemes = themeProvider.availableThemes;

          return Container(
            color: themeProvider.currentConfig.colors.background,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 当前主题提示
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: themeProvider.currentConfig.colors.cardBackground,
                    borderRadius: BorderRadius.circular(
                        themeProvider.currentConfig.shapes.cardRadius),
                    border: Border.all(
                      color: themeProvider.currentConfig.colors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: knBgColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前主题',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider
                                    .currentConfig.colors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              themeProvider.currentConfig.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider
                                    .currentConfig.colors.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 主题列表标题
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '选择主题风格',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.currentConfig.colors.primaryText,
                    ),
                  ),
                ),

                // 主题选项卡片
                ...availableThemes.map((theme) => _buildThemeCard(
                      context,
                      theme,
                      isSelected: theme.id == currentThemeId,
                      onTap: () async {
                        await themeProvider.switchTheme(theme.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已切换到「${theme.name}」主题'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeConfig theme, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeProvider.currentConfig.colors;
    final shapes = themeProvider.currentConfig.shapes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(shapes.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(shapes.cardRadius),
              border: Border.all(
                color: isSelected ? knBgColor : colors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: knBgColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // 主题颜色预览
                _buildColorPreview(theme),
                const SizedBox(width: 16),

                // 主题信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            theme.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryText,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: knBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '使用中',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'v${theme.version} · ${theme.author}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.hintText,
                        ),
                      ),
                    ],
                  ),
                ),

                // 选中指示
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? knBgColor : colors.hintText,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建主题颜色预览块
  Widget _buildColorPreview(ThemeConfig theme) {
    final moduleColors = [
      theme.colors.modules.lesson.primary,
      theme.colors.modules.fee.primary,
      theme.colors.modules.archive.primary,
      theme.colors.modules.summary.primary,
      theme.colors.modules.setting.primary,
    ];

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          children: [
            // 上半部分显示5个模块颜色
            Expanded(
              child: Row(
                children: moduleColors
                    .map((color) => Expanded(
                          child: Container(color: color),
                        ))
                    .toList(),
              ),
            ),
            // 下半部分显示背景色
            Expanded(
              child: Container(
                color: theme.colors.cardBackground,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colors.primaryText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
