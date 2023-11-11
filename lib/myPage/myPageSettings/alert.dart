import 'package:flutter/material.dart';

class Alert extends StatefulWidget {
  Alert({Key? key});

  @override
  State<Alert> createState() => _State();
}

class _State extends State<Alert> {
  var flg = false;
  var flgExhibition = false;
  var flgAppPush = false;
  var flgEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "알림설정",
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
          ListTile(
            title: Text('활동알림',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),),
          ),
          ListTile(
            title: Text('전시정보'),
            trailing: Switch(
              value: flgExhibition,
              onChanged: (value) {
                setState(() {
                  print(value);
                  flgExhibition = value;
                });
              },
            ),
          ),
          Divider(),
          SizedBox( height:20),
          ListTile(
            title: Text('광고성 정보수신',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),),
          ),
          ListTile(
            title: Text('앱 푸시'),
            trailing: Switch(
              value: flgAppPush,
              onChanged: (value) {
                setState(() {
                  print(value);
                  flgAppPush = value;
                });
              },
            ),
          ),
          Divider(), // 콤마(,) 추가
          ListTile(
            title: Text('이메일'),
            trailing: Switch(
              value: flgEmail,
              onChanged: (value) {
                setState(() {
                  print(value);
                  flgEmail = value;
                });
              },
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
