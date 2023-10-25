import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'hash_password.dart';
import 'home.dart';
import 'sign_in.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _pwdCheckController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String eventYn = 'N'; //이벤트 수신 동의. 미동의로 초기값 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 텍스트 필드 입력
                textFieldInput(_emailController, "이메일 주소", "email"),
                SizedBox(height: 15),
                textFieldInput(_pwdController, "비밀 번호", "pwd"),
                SizedBox(height: 15),
                textFieldInput(_pwdCheckController, "비밀 번호 확인", "pwdCheck"),
                SizedBox(height: 15),
                textFieldInput(_nickNameController, "닉네임", "nickName"),
                SizedBox(height: 15),
                textFieldInput(_phoneController, "핸드폰 번호", "phone"),
                SizedBox(height: 15),
                // 이벤트 수신 동의
                _listTile('이벤트 수신에 동의합니다.', 'Y'),
                SizedBox(height: 15),
                _listTile('이벤트 수신에 동의하지 않습니다.', 'N'),
                SizedBox(height: 15),
                // 회원가입
                submitButton(),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField textFieldInput(final ctr, String txt, String kind) {
    return TextFormField(
      controller: ctr,
      autofocus: true,
      obscureText: kind == 'pwd' || kind == 'pwdCheck' ? true : false,
      validator: (val) { // 인풋창에 입력된 값 필터
        if (val!.isEmpty) { // 비었을때 뜨는 Error
          return '$txt를 입력해 주세요.';
        } else if(kind == "pwd" && val.length <=8){ // 8글자 이하일때 Error
          return '$txt를 8자 이상 입력해 주세요.';
        } else if(kind == "pwdCheck" && val != _pwdController.text){
          return '비밀 번호가 일치하지 않습니다.';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: txt,
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _listTile(String message, String val){
    return ListTile(
      title: Text(message),
      leading: Radio<String>(
        value: val,
        groupValue: eventYn,
        onChanged: (String? value) {
          setState(() {
            eventYn = value!;
          });
        },
      ),
      onTap: (){
        setState(() {
          eventYn = val;
        });
      },
    );
  }

  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            final password = _pwdController.text;
            final salt = 'salt';

            // 비밀번호 해시화
            final hashFunction = HashFunction(); // HashFunction 클래스의 인스턴스 생성
            final hashedPassword = hashFunction.hashPassword(password, salt);

            FirebaseFirestore fs = FirebaseFirestore.instance; //싱글톤으로 구성된 객체
            CollectionReference user = fs.collection("user"); //user 테이블

            await user.add({
              'email': _emailController.text,
              'password': hashedPassword,
              'nickName': _nickNameController.text,
              'phone': _phoneController.text,
              'eventYn': eventYn,
              'joinDate': FieldValue.serverTimestamp(),
              'heat' : '36.5'
            });

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('회원가입 성공!'),
                  content: Text('회원가입이 성공적으로 완료되었습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: Text("확인"),
                    ),
                  ],
                );
              },
            );
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              print('The account already exists for that email.');
            }
          } catch (e) {
            print(e.toString());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Text(
          "가입 하기",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}