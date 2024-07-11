import 'package:flutter/material.dart';

PreferredSizeWidget KnAppBar({
  required String title,
  required String subtitle,
  required BuildContext context,
  Color appBarBackgroundColor = const Color.fromRGBO(220, 237, 200, 1.0),
  Color titleColor = Colors.black,
  Color subtitleBackgroundColor = Colors.blue,
  Color subtitleTextColor = Colors.white,
  double titleFontSize = 18.0,
  double subtitleFontSize = 14.0,
  List<Widget>? actions,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight * 1.3),
    child: AppBar(
      backgroundColor: appBarBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: titleColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 56.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(fontSize: titleFontSize, color: titleColor),
                ),
              ),
            ),
          ),
          Container(
            height: kToolbarHeight / 3,
            color: subtitleBackgroundColor,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0), // 与返回箭头对齐
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: subtitleFontSize, color: subtitleTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    ),
  );
}