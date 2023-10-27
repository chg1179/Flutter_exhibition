import 'package:exhibition_project/user/mypagefolder/qna.dart';
import 'package:flutter/material.dart';

import 'notice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyBoard(),
    );
  }
}

class MyBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("설정"),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20,),
          ListTile(
            title: Text(
              "나의정보",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            title: Text("프로필변경",),
            leading: Icon(Icons.person_outline_rounded),
            onTap: () {
              print("게시물 2을 선택했습니다.");
            },
          ),
          Divider(),
          ListTile(
            title: Text("취향분석 하기"),
            leading: Icon(Icons.add),
            onTap: () {
              print("게시물 3을 선택했습니다.");
            },
          ),
          Divider(),
          ListTile(
            title: Text("개인/보안"),
            leading: Icon(Icons.lock_outline),
            onTap: () {
              print("게시물 4을 선택했습니다.");
            },
          ),
          Divider(),
          SizedBox(height: 20,),
            ListTile(
            title: Text(
              "더보기",
              style: TextStyle(
              fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ListTile(
            title: Text("알림설정"),
            leading: Icon(Icons.add_alert_outlined),
            onTap: () {
              print("게시물 6을 선택했습니다.");
            },
          ),
          Divider(),
          ListTile(
            title: Text("공지사항"),
            leading: Icon(Icons.density_medium_outlined),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notice()),
                );
              },
          ),
          Divider(),
          ListTile(
            title: Text("자주하는 질문"),
            leading: Icon(Icons.question_answer_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QnaScreen()),
              );
            },
          ),
          Divider(),
          SizedBox(height: 20,)
          ,
          ListTile(
              title: Text("SNS" , style: TextStyle(
                fontWeight: FontWeight.bold,
              )
          ),
          ),
          ListTile(
            title: Text("이용약관"),
            onTap: () {
              print("이용약관");
            },
          ),
          Divider(),
          ListTile(
            title: Text("개인정보취급약관"),
            onTap: () {
              print("개인정보취급약관");
            },
          ),
          Divider(),
          ListTile(
            title: Text("로그아웃"),
            onTap: () {
              print("로그아웃.");
            },
          ),
          Divider(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새로운 게시물 추가
          // 여기서는 간단하게 "새로운 게시물"로 고정
          // 원하는 내용으로 수정 가능
          print("새로운 게시물을 추가했습니다.");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
