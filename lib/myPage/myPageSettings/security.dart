import 'package:exhibition_project/myPage/myPageSettings/pwchange.dart';
import 'package:flutter/material.dart';

import 'mypageSettings.dart';

class Security extends StatefulWidget {

  @override
  State<Security> createState() => _State();
}

class _State extends State<Security> {
  var flg = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test123',
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "개인/보안",
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
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('비밀번호 변경'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Pwchange()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('회원탈퇴'),
              onTap: () {
                _confirmDialog(context, '탈퇴 확인', '정말 탈퇴하시겠습니까?', () {
                  // 확인 버튼 눌렀을 때
                  _unRegisterDialog(context, '알림', '정상적으로 탈퇴되었습니다. 이용해주셔서 감사합니다.');
                });
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> _unRegisterDialog(BuildContext context, String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(myPageSettings());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDialog(BuildContext context, String title, String message, Function() onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                onConfirm(); // 확인 버튼을 누르면 onConfirm 함수 호출
                _unRegisterDialog(context, '알림', '정상적으로 탈퇴되었습니다. 이용해주셔서 감사합니다.'); // _unRegisterDialog 호출
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
