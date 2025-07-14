import 'package:flutter/material.dart';

import '../../HomePage.dart';
// ignore: non_constant_identifier_names
PreferredSizeWidget KnAppBar({
  required String title,
  required String subtitle,
  required BuildContext context,
  Color appBarBackgroundColor = const Color.fromRGBO(220, 237, 200, 1.0),
  Color titleColor = Colors.black,
  Color subtitleBackgroundColor = Colors.blue,
  Color subtitleTextColor = Colors.white,
  double titleFontSize = 18.0,
  double subtitleFontSize = 9.0,
  List<Widget>? actions,
  bool refreshPreviousPage = false,
  TabBar? bottom, // 修改为可选参数
  bool addInvisibleRightButton = false, // 新增参数：是否添加不可见的右侧按钮，使AppBar的布局左右对称
  int currentNavIndex = 0,
}) {
  final double topPadding = MediaQuery.of(context).padding.top;
  const double sidePadding = 16.0; // 侧边距

  return PreferredSize(
    preferredSize: Size.fromHeight(kToolbarHeight +
        kToolbarHeight / 3 +
        (bottom?.preferredSize.height ?? 0)),
    child: Container(
      padding: EdgeInsets.only(top: topPadding),
      child: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // 禁用自动生成的返回按钮
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: sidePadding),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: titleColor),
                    onPressed: () {
                      if (refreshPreviousPage) {
                        Navigator.of(context).pop(true); // 返回并刷新上一页
                      } else {
                        Navigator.of(context).pop(); // 普通返回
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          color: titleColor,
                          // fontWeight: FontWeight.bold,
                          fontWeight: FontWeight.w700, // 比 FontWeight.bold 还粗一点
                        ),
                      ),
                    ),
                  ),
                  if (actions != null) ...actions,
                  // 此处是在KnAppBar右侧添加了隐藏的按钮，为了使Title内容的布局可以在Bar里剧中显示。
                  if (!addInvisibleRightButton)
                    IconButton(
                      icon: Icon(Icons.home,
                          color: titleColor), // 将透明图标改为可见的Home图标
                      onPressed: () {
                        // 使用Navigator.pushAndRemoveUntil来清除所有路由历史并返回到主页
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => HomePage(currentNavIndex: currentNavIndex,)),
                          (route) => false, // 这会清除所有路由历史
                        );
                      },
                    ),
                  const SizedBox(width: sidePadding),
                ],
              ),
            ),
            Container(
              height: kToolbarHeight / 3,
              color: subtitleBackgroundColor,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: sidePadding),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: subtitleFontSize, color: subtitleTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottom: bottom, // 添加 bottom 参数
      ),
    ),
  );
}
