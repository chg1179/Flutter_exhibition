import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2, // 탭 수
        child: Scaffold(
          appBar: AppBar(
            title: null, // title 숨기기
            flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight), // AppBar 높이 설정
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'NOW'),
                      Tab(text: 'EXHIBITION'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              FirstPage(),
              SecondPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Tab 1',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Tab 2',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is Tab 1'),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is Tab 2'),
    );
  }
}
