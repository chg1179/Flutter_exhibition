import 'package:exhibition_project/community/comm_detail.dart';
import 'package:flutter/material.dart';
import '../exhibition/search.dart';
import 'comm_add.dart';
import 'comm_mypage.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommMain(),
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
    '전체', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'
  ];

  int selectedButtonIndex = 0;
  String selectedTag = '전체';

  Map<String, List<String>> tagToItems = {
    '전체': ['전체'],
    '설치미술': ['설치미술'],
    '온라인전시' : ['온라인전시 리스트'],
    '유화' : ['유화 리스트'],
    '미디어' : ['미디어']
  };

  ButtonStyle _unPushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.black45;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xff464D40)),
        ),
      ),
    );
  }

  ButtonStyle _pushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xff464D40)),
        ),
      ),
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
          Wrap(
            spacing: 5,
            children: _tagList.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return ElevatedButton(
                child: Text('#$tag'),
                onPressed: () {
                  setState(() {
                    selectedButtonIndex = index;
                    selectedTag = tag;
                  });
                },
                style: selectedButtonIndex == index ? _pushBtnStyle() : _unPushBtnStyle(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _recommendTab() {
    return Container(
      padding: EdgeInsets.all(20),
      height: 80,
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

 /* Widget _commList() {
    final selectedItems = tagToItems[selectedTag];
    return ListView.builder(
      itemCount: selectedItems?.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(selectedItems![index]),
        );
      },
    );
  }*/
  
  // 해시태그, 최신순, 인기순 연결
  Widget _commList(){
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Column(
          children: [
            ListTile(
              title: Text('글 제목'),
              subtitle: Text('글 내용'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommDetail()));
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          elevation: 0,
          automaticallyImplyLeading: false, // 뒤로가기 버튼 자리 차지하지 않음
          title: Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
                },
                icon: Icon(Icons.search),
                color: Colors.black),
            TextButton(
              onPressed: () {
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
      ),
    );
  }
}
