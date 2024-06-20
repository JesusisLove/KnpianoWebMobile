// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'KnSub001Bean.dart';
import 'knsub001_add_edit.dart';

class SubjectViewPage extends StatefulWidget {
  const SubjectViewPage({super.key});

  @override
  _SubjectViewPageState createState() => _SubjectViewPageState();
}

class _SubjectViewPageState extends State<SubjectViewPage> {
  late Future<List<KnSub001Bean>> futureSubjects;

  @override
  void initState() {
    super.initState();
    futureSubjects = fetchSubjects();
  }

  // 画面初期化：取得所有学科信息
  Future<List<KnSub001Bean>> fetchSubjects() async {
    // 上课管理菜单画面，点击“学生学科管理”按钮的url请求
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.subjectView}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> subjectsJson = json.decode(decodedBody);
      return subjectsJson.map((json) => KnSub001Bean.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('科目信息一览'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            // 新規”➕”按钮的事件处理函数
            onPressed: () {
              // Navigate to add subject page or handle add operation
              Navigator.push<bool>(
                context, 
                MaterialPageRoute(
                  builder: (context) => const SubjectAddEdit(showMode: '新規')
                )
              ).then((value) => {
                setState(() {
                futureSubjects = fetchSubjects();
              })});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<KnSub001Bean>>(
        future: futureSubjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildSubjectItem(snapshot.data![index]);
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildSubjectItem(KnSub001Bean subject) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
        // backgroundImage: NetworkImage(student.imageUrl), // 假设每个学生对象有一个imageUrl字段
        // 如果没有图像URL，可以使用一个本地的占位符图像
          backgroundImage: AssetImage('images/student-placeholder.png'),
        ), 
        title: Text(subject.subjectName),
        // subtitle: Row(
        //     children: <Widget>[
        //       // 为科目编号设置像素的左间距
        //       const SizedBox(width: 10 ), 
        //       Expanded(
        //         child: Text(
        //           subject.subjectId,
        //           style: const TextStyle(fontSize: 14),
        //         ),
        //       ),
        //       Container(
        //         // 为科目名称设置像素的右间距
        //         padding: const EdgeInsets.only(right: 16), 
        //         child: Text(
        //           '科目名称: ${subject.subjectName}',
        //           style: const TextStyle(fontSize: 14),
        //         ),
        //       ),
        //     ],
        //   ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 编辑按钮
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              // 编辑按钮的事件处理函数
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectAddEdit(subject: subject, showMode: '編集'),
                  ),
                ).then((value) {
                  // 检查返回值，如果为true，则重新加载数据
                  if (value == true) {
                    setState(() {
                        futureSubjects = fetchSubjects();
                    });
                  }
                });
              },
            ),

            // 删除按钮
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('删除确认'),
                      content: Text('确定要删除【${subject.subjectName}】这门科目吗？'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),

                        TextButton(
                          child: const Text('确定'),
                          onPressed: () {
                            deleteSubject(subject);
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  deleteSubject(KnSub001Bean subject) {
  final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.subjectInfoDelete}/${subject.subjectId}'; // 替换为实际的API地址和id
    try {
      http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json', // 添加内容类型头
        },
      )
      .then((response) {
        if (response.statusCode == 200) {
          reloadData();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('删除失败'),
                content: Text(response.body),
                actions: <Widget>[
                  TextButton(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('网络异常'),
            content: const Text('无法连接到服务器'),
            actions: <Widget>[
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void reloadData() {
    // 重新加载数据
    futureSubjects = fetchSubjects();
    // 更新状态以重建UI
    futureSubjects.whenComplete(() {
      setState(() {
        
      });
    });
  }
}