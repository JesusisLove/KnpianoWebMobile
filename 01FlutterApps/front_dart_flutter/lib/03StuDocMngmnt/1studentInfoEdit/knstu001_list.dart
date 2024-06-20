// 学生档案编辑
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import '../../Constants.dart';
import '../1studentBasic/KnStu001Bean.dart';
import '../1studentBasic/knstu001_add.dart';
import 'knstu001_edit.dart';
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

  // var logger = Logger();
  // 画面初期化：取得所有学生信息
  Future<List<KnStu001Bean>> fetchStudents() async {
    // 学生档案菜单画面，点击“学生档案编辑”按钮的url请求
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.studentInfoView}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(decodedBody);
      jsonList.map((json) => KnStu001Bean.fromJson(json)).toList();
      List<KnStu001Bean> stuLst = jsonList.map((json) => KnStu001Bean.fromJson(json)).cast<KnStu001Bean>().toList();
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
      actions: [
          IconButton(
            icon: const Icon(Icons.add),
            // 新規”➕”按钮的事件处理函数
            onPressed: () {
              Navigator.push<bool>(
                context, 
                MaterialPageRoute(
                  builder: (context) => const StudentAdd(),
                )
              ).then((value){
                  // 检查返回值，如果为true，则重新加载数据
                  if (value == true) {
                    setState(() {
                      futureStudents = fetchStudents();
                    });
                  }
                }
              );
            },
          ),
        ],
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
        subtitle: Row(
          children: <Widget>[
            // 为学生编号设置像素的左间距
            // const SizedBox(width: 28 ), 
            // Expanded(
            //   child: Text(
            //     student.stuId,
            //     style: const TextStyle(fontSize: 14),
            //   ),
            // ),

            // const Spacer(), // 先不要删除，留着学习：这会填充所有可用空间
            Container(
              // 设置像素的右间距
              padding: const EdgeInsets.only(left: 40), 
              child: Text(
                student.gender == 1 ? '男' : '女',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            Container(
              // 设置像素的右间距
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                student.birthday,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Row的宽度只足够包含子控件
          children: <Widget>[
            // 编辑按钮的事件处理函数
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentEdit(student: student),
                  ),
                ).then((value) {
                  // 检查返回值，如果为true，则重新加载数据
                  if (value == true) {
                    setState(() {
                      futureStudents = fetchStudents();
                    });
                  }
                });
              },
            ),
          ]
        ),
      ),
    );
  }
}