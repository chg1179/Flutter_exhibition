import 'package:exhibition_project/community/comm_add.dart';
import 'package:exhibition_project/exhibition/search.dart';
import 'package:flutter/material.dart';

import 'comm_mypage.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommMain()
    );
  }
}

class CommMain extends StatefulWidget {
  const CommMain({super.key});

  @override
  State<CommMain> createState() => _CommMainState();
}

class _CommMainState extends State<CommMain> {

  List<String> _tagList = [
    '전체', '설치미술', '온라인전시', '유화',
    '미디어', '사진', '조각', '특별전시',
  ];


  ButtonStyle _pushBtnStyle(){
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Colors.white), // 배경색
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // BorderRadius 설정
          side: BorderSide(color: Colors.black54), // border 색상 및 두께 설정
        ),
      )
    );
  }

  ButtonStyle _unPushBtnStyle(){
    return ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(0, 30)),
        backgroundColor: MaterialStateProperty.all(Color(0xff464D40)), // 배경색
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // BorderRadius 설정
            side: BorderSide(color: Color(0xff464D40)), // border 색상 및 두께 설정
          ),
        )
    );
  }

  Widget _recommendhashTag() {
    return Container(
      padding: EdgeInsets.only(top: 10, right: 50, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('추천 태그✨', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 50,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 5,
              children: _tagList.map((tag) {
                if (tag == '전체') {
                  return ElevatedButton(
                    child: Text(tag, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {},
                    style: _unPushBtnStyle(),
                  );
                } else {
                  return ElevatedButton(
                    child: Text('#$tag', style: TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {},
                    style: _pushBtnStyle(),
                  );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendTab() {
    return Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.bottomRight,
      height: 100,
      child: TabBar(
        indicatorColor: Color(0xff464D40),
        labelColor: Colors.black,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.black45,
        labelPadding: EdgeInsets.symmetric(horizontal: 16),
        tabs: [
          Tab(text: '최신순'),
          Tab(text: '인기순'),
        ],
      ),
    );
  }

  Widget _commList(){
    return Container(

    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                },
                icon: Icon(Icons.search), color: Colors.black),
            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommMyPage()));
              },
              child: Container(
                alignment: Alignment.center,
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xffD4D8C8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('내활동', style: TextStyle(color: Color(0xff464D40)),
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _recommendhashTag(),
            _recommendTab(),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: _commList()),
                  Center(child: _commList()),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommAdd()));
          },
          child: Icon(Icons.edit),
          backgroundColor: Color(0xff464D40),
          mini: true,

        ),
      )
    );
  }
}
