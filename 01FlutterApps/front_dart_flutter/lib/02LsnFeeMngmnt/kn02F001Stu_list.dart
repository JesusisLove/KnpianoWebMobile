import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kn_piano/03StuDocMngmnt/4stuDoc/Kn03D004StuDocBean.dart';
import 'dart:convert';

import 'package:kn_piano/Constants.dart';

import '../../ApiConfig/KnApiConfig.dart';
import 'kn02F002LsnFeeDetail.dart';

class StuFinancialPage extends StatefulWidget {
  const StuFinancialPage({super.key,});

  

  @override
  _StuFinancialPageState createState() => _StuFinancialPageState();
}

class _StuFinancialPageState extends State<StuFinancialPage> with SingleTickerProviderStateMixin {
  int archivedCount = 0;
  int unarchivedCount = 0;

  // 使用 ValueNotifier 来管理状态
  final ValueNotifier<List<Kn03D004StuDocBean>> stuDocNotifier = ValueNotifier([]);
  final ValueNotifier<List<Kn03D004StuDocBean>> stuUnDocNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      // 获取已入档案学生
      final String apiStuDocUrl = '${KnConfig.apiBaseUrl}${Constants.stuDocInfoView}';
      final responseStuDoc = await http.get(Uri.parse(apiStuDocUrl));

      if (responseStuDoc.statusCode == 200) {
        final decodedBody = utf8.decode(responseStuDoc.bodyBytes);
        List<dynamic> stuDocJson = json.decode(decodedBody);
        stuDocNotifier.value = stuDocJson.map((json) => Kn03D004StuDocBean.fromJson(json)).toList();
        archivedCount = stuDocNotifier.value.length;  // 更新已入档案人数
      } else {
        throw Exception('Failed to load archived students');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Kn03D004StuDocBean>>(
      valueListenable: stuDocNotifier,
      builder: (context, stuDocNotifierdents, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text( '学生账簿（$archivedCount人）'),
          ),
          body:  _buildStudentList(stuDocNotifier),
        );
      },
    );
  }

  Widget _buildStudentList(ValueNotifier<List<Kn03D004StuDocBean>> notifier) {
    return ValueListenableBuilder<List<Kn03D004StuDocBean>>(
      valueListenable: notifier,
      builder: (context, students, child) {
        if (students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('images/student-placeholder.png'),
              ),
              title: Text(student.stuName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${student.subjectCount} 科', 
                          style: const TextStyle(fontSize: 16.0)),
                          const SizedBox(width: 48.0), // 调整 Text 和 PopupMenuButton 之间的间距
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'detail':
                          Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  LsnFeeDetail(stuId:student.stuId, stuName:student.stuName),
                            ),
                          )
                          .then((value) {
                            _fetchStudentData();
                          });
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'detail',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('记账'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    stuDocNotifier.dispose();
    stuUnDocNotifier.dispose();
    super.dispose();
  }
}
