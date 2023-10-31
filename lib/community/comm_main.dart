import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/comm_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../exhibition/ex_list.dart';
import '../exhibition/search.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../myPage/mypage.dart';
import '../review/review_list.dart';
import 'comm_add.dart';
import 'comm_mypage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
      padding: EdgeInsets.only(top: 10, right: 50, bottom: 10),
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
              final isAllTag = tag == '전체';
              final tagText = isAllTag ? tag : '#$tag';
              return ElevatedButton(
                child: Text(tagText),
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
      height: 50,
      child: TabBar(
        indicatorColor: Color(0xff464D40),
        labelColor: Colors.black,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.black45,
        tabs: [
          Tab(text: '최신순'),
          Tab(text: '인기순'),
        ],
      ),
    );
  }

  Widget buildIcons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility, '0'),
              SizedBox(width: 5),
              buildIconsItem(Icons.chat_bubble_rounded, '0'),
              SizedBox(width: 5),
            ],
          ),
          GestureDetector(
              onTap: (){
                // 좋아요 카운트 증가 코드 작성
              },
              child: buildIconsItem(Icons.favorite, '0')
          ),
        ],
      ),
    );
  }

  Widget buildIconsItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Color(0xff464D40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _commList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .orderBy('write_date', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}'));
        }
        if (!snap.hasData) {
          return Center(child: Text('데이터 없음'));
        }

        return ListView.separated(
          itemCount: snap.data!.docs.length,
          separatorBuilder: (context, index) {
            return Divider(color: Colors.grey, thickness: 0.8);
          },
          itemBuilder: (context, index) {
            final doc = snap.data!.docs[index];
            final title = doc['title'] as String;
            final content = doc['content'] as String;
            Timestamp timestamp = doc['write_date'] as Timestamp;
            DateTime dateTime = timestamp.toDate();

            String? imagePath;

            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('imagePath')) {
              imagePath = data['imagePath'] as String;
            } else {
              // 'imagePath' 필드가 문서 데이터에 존재하지 않는 경우, 이곳에서 처리할 수 있습니다
              imagePath = null;
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommDetail(document: doc.id),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            // 사용자 프로필 이미지를 여기에 표시할 수 있습니다.
                          ),
                          SizedBox(width: 5),
                          Text('userNickname', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        content,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    if (imagePath != null)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePath),
                            width: 400,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    buildIcons()
                  ],
                ),
              ),
            );
          },
        );
      },
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
          automaticallyImplyLeading: false,
          title: Text('커뮤니티️', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
              },
              icon: Icon(Icons.search),
              color: Colors.black,
            ),
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
                child: Text('내활동', style: TextStyle(color: Color(0xff464D40))),
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