import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hash_password.dart';
import 'home.dart';
import 'sign_up.dart';
import '../model/user_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스를 가져옵니다.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _TextField(_emailController, '이메일', 'email'),
            SizedBox(height: 8),
            _TextField(_pwdController, '비밀번호', 'pwd'),
            SizedBox(height: 16),
            Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('로그인'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text('회원 가입'),
                      ),
                    ]
                )
            ),
          ],
        ),
      ),
    );
  }

  _TextField(final ctr, String txt, String kind){
    return TextField(
      controller: ctr,
      obscureText: kind == 'pwd' ? true : false,
      decoration: InputDecoration(labelText: txt),
    );
  }

  void _login() async {
    String email = _emailController.text;
    String password = _pwdController.text;
    final salt = 'salt';

    final userEmail = await _fs.collection('user')
        .where('email', isEqualTo: email)
        .get();
    if (userEmail.docs.isNotEmpty) {

        final userDocument = userEmail.docs.first;
        final userHashPassword = userDocument.get('password');
        bool pwdCheck = isPasswordValid(password, salt, userHashPassword);
        print(pwdCheck);
        if (pwdCheck) {
          Provider.of<UserModel>(context, listen: false).signIn(userDocument.id);
          _showMessageDialog('성공적으로 로그인 되었습니다!', true);
        } else {
          _showMessageDialog('비밀번호를 확인해 주세요.', false);
        }
    } else {
      _showMessageDialog('일치하는 아이디가 없습니다.', false);
    }
  }

  // 비밀번호 일치 여부 확인 함수
  bool isPasswordValid(String inputPassword, String salt, String storedHashedPassword) {
    // 사용자가 입력한 비밀번호를 해시화
    // 비밀번호 해시화
    final hashFunction = HashFunction(); // HashFunction 클래스의 인스턴스 생성
    final hashedPassword = hashFunction.hashPassword(inputPassword, salt);
    print(hashedPassword);
    // 저장된 해시된 비밀번호와 사용자가 입력한 해시된 비밀번호를 비교
    return hashedPassword == storedHashedPassword;
  }

  void _showMessageDialog(String message, bool flg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('로그인 메세지'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if(flg) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

}