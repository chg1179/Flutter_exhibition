import 'package:exhibition_project/admin/management_page.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/model/user_model.dart';
import 'package:exhibition_project/myPage/JTBI/jbti1.dart';
import 'package:exhibition_project/myPage/myPageSettings/individualTerms.dart';
import 'package:exhibition_project/myPage/myPageSettings/profile_change.dart';
import 'package:exhibition_project/myPage/myPageSettings/security.dart';
import 'package:exhibition_project/myPage/myPageSettings/useTerms.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../myPage/myPageSettings/notice.dart';


class MySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyPageSettings();
  }
}
class MyPageSettings extends StatefulWidget {
  const MyPageSettings({Key? key}) : super(key: key);

  @override
  State<MyPageSettings> createState() => _MyPageSettingsState();
}

class _MyPageSettingsState extends State<MyPageSettings> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context); // 세션. UserModel 프로바이더에서 값을 가져옴.
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
          if(user.status == 'A') 
            ListTile(
              title: Text(
                "관리",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if(user.status == 'A') Divider(),
          if(user.status == 'A')
            ListTile(
              title: Text("관리자 페이지"),
              leading: Icon(Icons.admin_panel_settings_outlined),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManagementPage()),
                );
              },
            ),
          SizedBox(height: 20),
          ListTile(
            title: Text(
              "나의정보",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          ListTile(
            title: Text("프로필변경",),
            leading: Icon(Icons.person_outline_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileChange()),
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
            title: Text("공지사항"),
            leading: Icon(Icons.density_medium_outlined),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notice(kind: 'notice')),
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
                MaterialPageRoute(builder: (context) => Notice(kind: 'qna')),
              );
            },
          ),
          Divider(),
          SizedBox(height: 20,),
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
            onTap: () async {
              bool logoutConfirmed = await chooseMessageDialog(context, "로그아웃 하시겠습니까?", "로그아웃");
              if (logoutConfirmed) {
                user.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                print("로그아웃.");
              }
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
