import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter/services.dart'; // 确保导入了这个库
import 'config.dart'; // 导入Config类


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 初始化Flutter绑定
  await Config.load(); // 加载配置
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('学生信息查询'),
        ),
        body: StudentSearchWidget(),
      ),
    );
  }
}

class StudentSearchWidget extends StatefulWidget {
  @override
  _StudentSearchWidgetState createState() => _StudentSearchWidgetState();
}

class _StudentSearchWidgetState extends State<StudentSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  String _studentInfo = '';

  void _search() async {
    final String apiUrl = '${Config.apiBaseUrl}/liu/student?stuid=${_controller.text}';// 修改：使用 Config 中的基础URL
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final student = json.decode(decodedBody);
        setState(() {
          _studentInfo = '学生番号: ${student['stuId']}, 名前: ${student['stuName']}, 誕生日: ${student['birthday']}';
        });
      } else {
        setState(() {
          _studentInfo = '学生信息未找到';
        });
      }
    } catch (e) {
      setState(() {
        _studentInfo = '请求失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: '输入学号',
          ),
        ),
        ElevatedButton(
          onPressed: _search,
          child: Text('查询'),
        ),
        Text(_studentInfo),
      ],
    );
  }
}
