import 'package:flutter/material.dart';

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
  bool refreshPreviousPage = false, // 新增参数，控制是否刷新上一页
}) {
  final double topPadding = MediaQuery.of(context).padding.top;
  final double sidePadding = 16.0; // 侧边距

  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + kToolbarHeight / 3),
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
                  SizedBox(width: sidePadding),
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
                        style: TextStyle(fontSize: titleFontSize, color: titleColor),
                      ),
                    ),
                  ),
                  if (actions != null) ...actions,
                  SizedBox(width: sidePadding),
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
                  padding: EdgeInsets.only(left: sidePadding),
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: subtitleFontSize, color: subtitleTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}