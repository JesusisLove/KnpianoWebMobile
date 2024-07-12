import 'package:flutter/material.dart';
import '../02LsnFeeMngmnt/kn02F002LsnFeeDetail.dart';
import '../Constants.dart';

class PageIdMapping extends StatelessWidget {
  final String pageId;
  final String stuId;
  final String stuName;

  const PageIdMapping({
    super.key,
    required this.pageId,
    required this.stuId,
    required this.stuName,
  });

  @override
  Widget build(BuildContext context) {

    // 立即调用导航方法，不能使用 FutureBuilder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToPage(context);
    });

    // 返回一个空的容器，因为这个 widget 不应该被渲染
    return Container();
  }

  Future<void> _navigateToPage(BuildContext context) async {
    late Widget page;
    switch (pageId) {
      case 'page1':
        // TODO: Define page1 Widget
        page = const Scaffold(body: Center(child: Text('Page 1')));
        break;

      case Constants.stuLsnFeeListPage:
        page = LsnFeeDetail(stuId:stuId, 
                            stuName:stuName,
                            knBgColor: Constants.lsnfeeThemeColor,
                            knFontColor: Colors.white,
                            pagePath: "学费支付管理 >> 在课学生一览",
                            );
        break;
        
      default:
        page = const Scaffold(body: Center(child: Text('未定义页面')));
        break;
    }

    // 使用 pushReplacement 而不是 push,因为pageIdMapping不是窗体页面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}