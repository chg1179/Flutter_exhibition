import 'package:flutter/material.dart';

class Pwchange extends StatefulWidget {
  @override
  _PwchangeState createState() => _PwchangeState();
}

class _PwchangeState extends State<Pwchange> {
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _pwdController2 = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "비밀번호 변경",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: [
              SizedBox(height: 100,),
              Row(
                children: [
                  Text(
                    '비밀번호',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              passwordInput(),
              const SizedBox(height:30),
              Row(
                children: [
                  Text(
                    '비밀번호 확인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              passwordInput2(),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_key.currentState!.validate()) {
                    if (_pwdController.text != _pwdController2.text) {
                      _showAlertDialog(context, '알림', '비밀번호와 비밀번호 확인이 일치하지 않습니다. 다시 확인해주세요.');
                    } else {
                      print("예림아 부탁해!");
                    }
                  }
                },
                child: const Text(
                  "확인",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // 버튼 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 가로 길이를 화면의 최대 넓이로 설정
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      validator: (val) {
        if (val!.isEmpty) {
          return '비밀번호 확인이 입력되지 않았습니다';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: '특수 문자를 포함하는 8자 이상의 비밀번호를 입력해주세요.',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextFormField passwordInput2() {
    return TextFormField(
      controller: _pwdController2,
      obscureText: true,
      validator: (val) {
        if (val!.isEmpty) {
          return '비밀번호가 입력되지 않았습니다.';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: '비밀번호를 확인해 주세요.',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Future<void> _showAlertDialog(BuildContext context, String title, String message) async {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(home: Pwchange()));
}
