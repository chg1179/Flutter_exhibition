import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/comm_main.dart';
import 'package:exhibition_project/exhibition/ex_list.dart';
import 'package:exhibition_project/main/main_add_view.dart';
import 'package:exhibition_project/exhibition/search.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'main/first.dart';
import 'main/second.dart';
import 'myPage/mypage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home()
    )
  );
}

class Home extends StatefulWidget {
  Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  bool _isSearchVisible = false;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // 탭 수
        child: Scaffold(
          appBar: AppBar(
            leading: Image.asset('main/logo_green.png'),
            elevation: 0,
            backgroundColor:Color(0xff464D40),
            title: null, // title 숨기기
            actions: [
              IconButton(
                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Search()));
                },
                icon: Icon(Icons.search, color: Colors.white),
              )
            ],
            flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight), // AppBar 높이 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TabBar(
                      tabs: [
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('추천', style: TextStyle(color: Color(0xffD4D8C8)),),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('팔로잉', style: TextStyle(color: Color(0xffD4D8C8))),
                            ),
                          ),
                        ),
                      ],
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      indicator: null,
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
            extendBodyBehindAppBar: true,
          body: Container(
            constraints: BoxConstraints(maxWidth: 500), // 최대넓이제한
            child: _isSearchVisible
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '전시 검색',
                  prefixIcon: Icon(Icons.search, color: Color(0xffD4D8C8)),
                  contentPadding: EdgeInsets.all(8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            )
                : TabBarView(
              children: [
                FirstPage(),
                SecondPage(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                    },
                    icon : Icon(Icons.home),
                    color: Colors.black
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                    },
                    icon : Icon(Icons.account_balance, color: Colors.black)
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                    },
                    icon : Icon(Icons.comment),
                    color: Colors.black
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                  },
                  icon : Icon(Icons.library_books),
                  color: Colors.black
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                    },
                    icon : Icon(Icons.account_circle),
                    color: Colors.black
                ),
                label: '',
              ),
            ],
          ),
        ),

    );
  }
}

