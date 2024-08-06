import 'package:flutter/material.dart';

class StudentLeaveSettingPage extends StatefulWidget {
  const StudentLeaveSettingPage({super.key});

  @override
  _StudentLeaveSettingPageState createState() => _StudentLeaveSettingPageState();
}

class _StudentLeaveSettingPageState extends State<StudentLeaveSettingPage> {
  List<String> students = [
    'Ashley Cha', 'Chen Guo', 'Chen Yi Zhou', 'Chen Yifan',
    'Clare Won', 'Erin Fidela', 'Faith Lim X', 'Guo Yu Qi',
    'Hannah Ch', 'Hong Chen', 'Jaishree', 'Kai En',
    'Lee Kang Yu', 'Li Jen', 'Lim Huai Kai', 'Lim Tian R',
    'Loh Yi Bang', 'Loh Yi Han', 'Loh Yi Ting', 'Ma Xinyu',
    'Ma Xinyue', 'Melissa', 'Michael Liu', 'Natasha Ta',
    'Ni Yue Er L', 'Raina Lim', 'Rishav by I', 'Sakura Mik',
    'Sue En', 'Tan Cher Hui'
  ];
  
  Set<String> selectedStudents = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('他(她)要休学或退学', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              // 处理保存操作
            },
          ),
        ],
      ),
      body: AlphabetScrollView(
        list: students,
        selectedStudents: selectedStudents,
        onStudentSelected: (String student, bool selected) {
          setState(() {
            if (selected) {
              selectedStudents.add(student);
            } else {
              selectedStudents.remove(student);
            }
          });
        },
      ),
    );
  }
}

class AlphabetScrollView extends StatelessWidget {
  final List<String> list;
  final Set<String> selectedStudents;
  final Function(String, bool) onStudentSelected;

  const AlphabetScrollView({
    super.key, 
    required this.list,
    required this.selectedStudents,
    required this.onStudentSelected,
  });

  @override
  Widget build(BuildContext context) {
    list.sort();
    final groupedStudents = groupStudents(list);
    
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: groupedStudents.length,
            itemBuilder: (context, index) {
              final letter = groupedStudents.keys.elementAt(index);
              final students = groupedStudents[letter]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10.5),
                            ),
                            child: Text(
                              letter,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  ...students.map((student) => buildStudentItem(student)),
                ],
              );
            },
          ),
        ),
        Container(
          width: 20,
          color: Colors.grey[200],
          child: ListView.builder(
            itemCount: 26,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 处理字母索引点击
                },
                child: Container(
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildStudentItem(String student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 72, // 设置cell行的高度
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            // 添加一个 SizedBox 来创建 60 像素的左侧间距，每一行有checkBox的学生信息距离画面错边距60像素。
            const SizedBox(width: 60),
            Checkbox(
              value: selectedStudents.contains(student),
              onChanged: (bool? value) {
                onStudentSelected(student, value ?? false);
              },
            ),
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(student[0], style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Text(student),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<String>> groupStudents(List<String> students) {
    final grouped = <String, List<String>>{};
    for (final student in students) {
      final letter = student[0].toUpperCase();
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(student);
    }
    return grouped;
  }
}