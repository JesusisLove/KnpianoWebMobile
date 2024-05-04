// 学生档案编辑
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../Constants.dart';
import 'student.dart'; // 导入Student模型
import 'package:http/http.dart' as http;
import 'dart:convert';
// 确保Student模型已经导入
import 'package:kn_piano/ApiConfig/KnApiConfig.dart';

class StuEditList extends StatefulWidget {
  const StuEditList({super.key});

  @override
  StuEditListState createState() => StuEditListState();
}

class StuEditListState extends State<StuEditList> {
  late Future<List<KnStu001Bean>> futureStudents;

  @override
  void initState() {
    super.initState();
    futureStudents = fetchStudents();
  }

  var logger = Logger();
  
  Future<List<KnStu001Bean>> fetchStudents() async {
    // 学生档案菜单画面，点击“学生档案编辑”按钮的url请求
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.studentInfoView}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(decodedBody);
      jsonList.map((json) => KnStu001Bean.fromJson(json)).toList();
      List<KnStu001Bean> stuLst = jsonList.map((json) => KnStu001Bean.fromJson(json)).cast<KnStu001Bean>().toList();
      // 使用logger输出jsonList
      // logger.d(jsonList);
      return stuLst;

    } else {
      throw Exception('Failed to load students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学生一覧画面'),
      ),
      body: FutureBuilder<List<KnStu001Bean>>(
        future: futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //加载显示器，就是在转的小圈圈，通知用户数据正在加载中。
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildStudentItem(snapshot.data![index]);
                },
              );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget _buildStudentItem(KnStu001Bean student) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
        // backgroundImage: NetworkImage(student.imageUrl), // 假设每个学生对象有一个imageUrl字段
        // 如果没有图像URL，可以使用一个本地的占位符图像
        backgroundImage: AssetImage('images/student-placeholder.png'),
      ),
        title: Text(student.stuName),
        subtitle: Text(
          "学生番号: ${student.stuId}"
          // "性别: ${student.gender}\n"
          // "出生日: ${student.birthday}\n"
          // "电话1: ${student.tel1}\n"
          // "电话2: ${student.tel2}\n"
          // "电话3: ${student.tel3}\n"
          // "电话4: ${student.tel4}\n"
          // "住址: ${student.address}\n"
          // "邮政编号: ${student.postCode}\n"
          // "介绍人: ${student.introducer}"
        ),
      ),
    );
  }
}