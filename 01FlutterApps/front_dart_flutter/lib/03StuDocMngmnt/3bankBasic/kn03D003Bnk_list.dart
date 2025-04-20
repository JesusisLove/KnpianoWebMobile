// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ApiConfig/KnApiConfig.dart';
import '../../CommonProcess/customUI/KnAppBar.dart';
import '../../Constants.dart';
import 'Kn03D003BnkBean.dart';
import 'kn03D003Bank_add_edit.dart';
import 'kn03D003Stubnk_list.dart';

// ignore: must_be_immutable
class BankViewPage extends StatefulWidget {
  final Color knBgColor;
  final Color knFontColor;
  late String pagePath;
  // titleName を追加
  late final String titleName;
  BankViewPage({
    super.key,
    required this.knBgColor,
    required this.knFontColor,
    required this.pagePath,
  });

  @override
  _BankViewPageState createState() => _BankViewPageState();
}

class _BankViewPageState extends State<BankViewPage> {
  final String titleName = "银行信息一览";
  late String subtitle;
  late Future<List<Kn03D003BnkBean>> futureBanks;

  @override
  void initState() {
    super.initState();
    futureBanks = fetchBanks();
  }

  // 画面初期化：取得所有科目信息
  Future<List<Kn03D003BnkBean>> fetchBanks() async {
    // 上课管理菜单画面，点击“学生科目管理”按钮的url请求
    final String apiUrl = '${KnConfig.apiBaseUrl}${Constants.bankView}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> banksJson = json.decode(decodedBody);
      return banksJson.map((json) => Kn03D003BnkBean.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load banks');
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
        addInvisibleRightButton: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            // 新規”➕”按钮的事件处理函数
            onPressed: () {
              // Navigate to add bank page or handle add operation
              Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BankAddEdit(
                            showMode: '新規',
                            knBgColor: widget.knBgColor,
                            knFontColor: widget.knFontColor,
                            pagePath: subtitle,
                          ))).then((value) => {
                    setState(() {
                      futureBanks = fetchBanks();
                    })
                  });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Kn03D003BnkBean>>(
        future: futureBanks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildBankItem(snapshot.data![index]);
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildBankItem(Kn03D003BnkBean bank) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          // backgroundImage: NetworkImage(student.imageUrl), // 假设每个学生对象有一个imageUrl字段
          // 如果没有图像URL，可以使用一个本地的占位符图像
          backgroundImage: AssetImage('images/student-placeholder.png'),
        ),
        title: Text(bank.bankName),
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
                    builder: (context) => BankAddEdit(
                      bank: bank,
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
                      futureBanks = fetchBanks();
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
                      content: Text('确定要删除【${bank.bankName}】这门科目吗？'),
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
                            deleteBank(bank);
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // 追加银行所属学生按钮
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.blue),
              // 银行所属学生按钮的事件处理函数
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankStuPageView(
                      bankName: bank.bankName,
                      bankId: bank.bankId,
                      knBgColor: widget.knBgColor,
                      knFontColor: widget.knFontColor,
                      pagePath: subtitle,
                    ),
                  ),
                ).then((value) {
                  // 检查返回值，如果为true，则重新加载数据
                  if (value == true) {
                    setState(() {
                      futureBanks = fetchBanks();
                    });
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  deleteBank(Kn03D003BnkBean bank) {
    final String apiUrl =
        '${KnConfig.apiBaseUrl}${Constants.stuBankDelete}/${bank.bankId}';
    try {
      http.delete(
        Uri.parse(apiUrl),
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
    futureBanks = fetchBanks();
    // 更新状态以重建UI
    futureBanks.whenComplete(() {
      setState(() {});
    });
  }
}
