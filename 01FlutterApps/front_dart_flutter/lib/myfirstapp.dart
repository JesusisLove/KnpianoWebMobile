import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

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
  String? response; // 假设 response 是一个字符串
  void _search() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.3.5:8080/liu/student?name=${_controller.text}'),
      );

      if (response.statusCode == 200) {
        final student = json.decode(response.body);
        setState(() {
          _studentInfo = '学生番号: ${student['stuId']}, 名前: ${student['stuName']}, 誕生日: ${student['birthday']}';
        });
      } else {
        // 当状态码不是 200 时处理错误
        setState(() {
          _studentInfo = '学生信息未找到';
        });
 //   _studentInfo= "wer werwe we werwer ";
      }
    } catch (e) {
      // 处理网络请求异常
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
