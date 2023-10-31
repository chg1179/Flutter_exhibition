import 'package:exhibition_project/myPage/JTBI/jbti1.dart';
import 'package:exhibition_project/myPage/myPageSettings/individualTerms.dart';
import 'package:exhibition_project/myPage/myPageSettings/security.dart';
import 'package:exhibition_project/myPage/myPageSettings/useTerms.dart';
import 'package:exhibition_project/myPage/myPageSettings/qna.dart';
import 'package:flutter/material.dart';

import '../../myPage/myPageSettings/notice.dart';
import 'alert.dart';

void main() {
  runApp(MySetting());
}

class MySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: myPageSettings(),
    );
  }
}

class myPageSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "설정",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 여기에 뒤로 가기 동작 추가
            Navigator.pop(context);
          },
        ),
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
            title: Text("JBTI 취향분석 하기"),
            leading: Icon(Icons.add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JTBI()),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text("개인/보안"),
            leading: Icon(Icons.lock_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Security()),
              );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Alert()),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UseTerms()),
                );
              },
          ),
          Divider(),
          ListTile(
            title: Text("개인정보취급약관"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IndividualTerms()),
              );
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
    );
  }
}
