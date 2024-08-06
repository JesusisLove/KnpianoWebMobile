// ignore: file_names
import 'package:flutter/material.dart';
import 'StudentLeaveSettingPage.dart';

class StudentLeaveListPage extends StatefulWidget {
  const StudentLeaveListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentLeaveListPageState createState() => _StudentLeaveListPageState();
}

class _StudentLeaveListPageState extends State<StudentLeaveListPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('学生休学退学名单', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.blue),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: students.length + 1,
          itemBuilder: (context, index) {
            if (index == students.length) {
              return Container(
                alignment: Alignment.center,
                child: const Icon(Icons.add_circle, color: Colors.green, size: 50),
              );
            }
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BA5B6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    students[index],
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentLeaveSettingPage()));
        },
      ),
    );
  }
}