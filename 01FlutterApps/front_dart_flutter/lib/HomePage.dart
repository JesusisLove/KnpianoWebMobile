// HomePage.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/%2001LessonMangement/1StudentRegister/StudentInfoScreen.dart';  // 确保导入路径正确
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('上课管理'),
    Text('学费管理'),
    Text('档案管理'),
    Text('综合管理'),
    Text('设置管理'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("主页面"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text("学生入学"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentInfoScreen()),
                );
              },
            ),
            const SizedBox(height: 20), // 添加一些间隔
            _widgetOptions.elementAt(_selectedIndex), // 显示选中的页面文本
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // 添加此属性
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '上课管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '学费管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '档案管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '综合管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置管理',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
