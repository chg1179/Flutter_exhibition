import 'package:exhibition_project/myPage/myPageSettings/pwd_change.dart';
import 'package:flutter/material.dart';

class Security extends StatefulWidget {
  @override
  State<Security> createState() => _State();
}

class _State extends State<Security> {
  var flg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "개인/보안",
          style: TextStyle(
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
                MaterialPageRoute(builder: (context) => PwdChange()),
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
