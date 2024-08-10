// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';
import 'Kn05S003SubjectEdabnBean.dart';
import 'kn05S003SubEda_add_edit.dart';

// ignore: must_be_immutable
class Kn05S003SubEdaView extends StatefulWidget {
  final String subjectName;
  final String subjectId;
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;

  Kn05S003SubEdaView({
    super.key,
    required this.subjectName,
    required this.subjectId,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  _Kn05S003SubEdaListState createState() => _Kn05S003SubEdaListState();
}

class _Kn05S003SubEdaListState extends State<Kn05S003SubEdaView> {
  final String titleName = "科目级别一览";
  late  String subtitle;
  List<dynamic> subjectEdaBanBean = [];
  late Future<List<Kn05S003SubjectEdabnBean>> futureSubjectsEda;

  @override
  void initState() {
    super.initState();

    // 从DB取得该科目的科目级别信息，做画面初期化
    futureSubjectsEda = fetchSubjectsEda();
  }

  // 画面初期化：取得所有科目信息
  Future<List<Kn05S003SubjectEdabnBean>> fetchSubjectsEda() async {
    // 上课管理菜单画面，点击“学生科目管理”按钮的url请求
    final String apiUrl =
        '${KnConfig.apiBaseUrl}${Constants.subjectEdaView}/${widget.subjectId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> subjectsJson = json.decode(decodedBody);
      return subjectsJson
          .map((json) => Kn05S003SubjectEdabnBean.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  @override
  Widget build(BuildContext context) {
    subtitle = "${widget.pagePath} >> $titleName";
    return Scaffold(
      appBar: KnAppBar(
        title: titleName,
        subtitle: subtitle,
        context: context,
        appBarBackgroundColor: widget.knBgColor,
        titleColor: Color.fromARGB(
            widget.knFontColor.alpha,
            widget.knFontColor.red - 20,
            widget.knFontColor.green - 20,
            widget.knFontColor.blue - 20),
        subtitleBackgroundColor: Color.fromARGB(
            widget.knFontColor.alpha,
            widget.knFontColor.red + 20,
            widget.knFontColor.green + 20,
            widget.knFontColor.blue + 20),
        subtitleTextColor: Colors.white,
        titleFontSize: 20.0,
        subtitleFontSize: 12.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            // 新規”➕”按钮的事件处理函数
            onPressed: () {
              // Navigate to add subjectEda page or handle add operation
              Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubjectEdaAddEdit(
                            subjectId: widget.subjectId,
                            showMode: '新規',
                            knBgColor: widget.knBgColor,
                            knFontColor: widget.knFontColor,
                            pagePath: subtitle,
                          ))).then((value) => {
                    setState(() {
                      futureSubjectsEda = fetchSubjectsEda();
                    })
                  });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上一级画面传过来的科目名称
            TextField(
              controller: TextEditingController(text: widget.subjectName),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '科目名称',
                // 页面上划一条线
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            const Divider(color: Color.fromARGB(255, 12, 140, 116)),
            const SizedBox(height: 16.0),

            // FutureBuilder 显示科目级别信息的数据列表
            Expanded(
              child: FutureBuilder<List<Kn05S003SubjectEdabnBean>>(
                future: futureSubjectsEda,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _buildSubjectEdaItem(snapshot.data![index]);
                      },
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectEdaItem(Kn05S003SubjectEdabnBean subjectEda) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          // backgroundImage: NetworkImage(student.imageUrl), // 假设每个学生对象有一个imageUrl字段
          // 如果没有图像URL，可以使用一个本地的占位符图像
          backgroundImage: AssetImage('images/student-placeholder.png'),
        ),
        // title: Text(subjectEda.subjectName),
        subtitle: Text(
            '${subjectEda.subjectSubName} ¥ ${subjectEda.subjectPrice.toStringAsFixed(2)}'), // 科目价格保留两位小数
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
                    builder: (context) => SubjectEdaAddEdit(
                      subjectEda: subjectEda,
                      showMode: '編集',
                      knBgColor: widget.knBgColor,
                      knFontColor: widget.knFontColor,
                      pagePath: subtitle,
                    ),
                  ),
                ).then((value) {
                  // 检查返回值，如果为true，则重新加载数据
                  if (value == true) {
                    setState(() {
                      futureSubjectsEda = fetchSubjectsEda();
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
                      content: Text('确定要删除【${subjectEda.subjectName}】这门科目吗？'),
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
                            _deleteSubjectEdaBan(
                                subjectEda.subjectId, subjectEda.subjectSubId);
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

  // 科目级别一览里的删除按钮按下事件
  void _deleteSubjectEdaBan(String subjectId, String subjectSubId) async {
    final String deleteUrl =
        '${KnConfig.apiBaseUrl}${Constants.subjectEdaDelete}/$subjectId/$subjectSubId';

    try {
      http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Content-Type': 'application/json', // 添加内容类型头
        },
      ).then((response) {
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
    futureSubjectsEda = fetchSubjectsEda();
    // 更新状态以重建UI
    futureSubjectsEda.whenComplete(() {
      setState(() {});
    });
  }
}
