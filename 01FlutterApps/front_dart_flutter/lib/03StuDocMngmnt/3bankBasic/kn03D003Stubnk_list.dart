// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../Constants.dart';
import 'Kn03D003StubnkBean.dart';
import 'kn03D003BankStu_add_edit.dart';

class BankStuPageView extends StatefulWidget {
  final String bankName;
  final String bankId;

  const BankStuPageView(
    {super.key, required this.bankName, required this.bankId}
    );

  @override
  _BankStuPageViewState createState() => _BankStuPageViewState();
}

class _BankStuPageViewState extends State<BankStuPageView> {
  List<dynamic> bankStuBanBean = [];
   late Future<List<Kn03D003StubnkBean>> futureBanStu;

  @override
  void initState() {
    super.initState();

    // 从DB取得该学生的银行信息，做画面初期化
    futureBanStu = fetchBnkStu();
  }

  // 画面初期化：取得使用该银行的所有学生信息一览
  Future<List<Kn03D003StubnkBean>> fetchBnkStu() async {
    // 上课管理菜单画面，点击“学生银行信息管理”按钮的url请求
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.stuBankView}/${widget.bankId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> banksJson = json.decode(decodedBody);
      return banksJson.map((json) => Kn03D003StubnkBean.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load banks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用该银行的学生一览'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            // 新規”➕”按钮的事件处理函数
            onPressed: () {
              // Navigate to add bankStu page or handle add operation
              Navigator.push<bool>(
                context, 
                MaterialPageRoute(
                  builder: (context) => BankStuAddEdit(bankId: widget.bankId, showMode: '新規')
                )
              ).then((value) => {
                setState(() {
                futureBanStu = fetchBnkStu();
              })});
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
              controller: TextEditingController(text: widget.bankName),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '银行名称',
                // 页面上划一条线
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            const Divider(color: Color.fromARGB(255, 12, 140, 116)),
            const SizedBox(height: 16.0),

            // FutureBuilder 显示学生的银行信息的数据列表
            Expanded(
              child: FutureBuilder<List<Kn03D003StubnkBean>>(
                future: futureBanStu,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _buildbankStuItem(snapshot.data![index]);
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

  Widget _buildbankStuItem(Kn03D003StubnkBean bankStu) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
        // backgroundImage: NetworkImage(student.imageUrl), // 假设每个学生对象有一个imageUrl字段
        // 如果没有图像URL，可以使用一个本地的占位符图像
          backgroundImage: AssetImage('images/student-placeholder.png'),
        ), 
        title: Text(bankStu.stuName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 删除按钮
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('删除确认'),
                      content: Text('确定要删除【${bankStu.stuName}】吗？'),
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
                            _deletebankStuBan(bankStu.bankId, bankStu.stuId);
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

  // 学生的银行一览里的删除按钮按下事件
  void _deletebankStuBan(String bankId, String stuId) async {
    final String deleteUrl = '${KnConfig.apiBaseUrl}${Constants.stuBankDelete}/$stuId/$bankId';

 try {
      http.delete(
        Uri.parse(deleteUrl),
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
    futureBanStu = fetchBnkStu();
    // 更新状态以重建UI
    futureBanStu.whenComplete(() {
      setState(() {
        
      });
    });
  }
}
