import 'package:flutter/material.dart';

class KnLoadingIndicator extends StatelessWidget {
  const KnLoadingIndicator({
    Key? key,
    required this.color,
    this.text = '正在加载数据...',
    this.size = 36.0,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  final Color color;
  final String text;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: strokeWidth,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 静态方法，可以直接调用
  static Widget show({
    required Color color,
    String text = '正在加载数据...',
    double size = 36.0,
    double strokeWidth = 4.0,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: strokeWidth,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
