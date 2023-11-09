import 'package:exhibition_project/dialog/show_message.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import '../style/button_styles.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => chooseMessageDialog(context, '종료하시겠습니까?', '종료'),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Image.asset(
              'assets/sign/login_back.png', // 배경 이미지
              fit: BoxFit.cover, // 이미지를 화면에 맞게 늘리기
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/sign/clearLogo.png', width: 280,),
                    SizedBox(height: 180),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      style: fullGreenButtonStyle(),
                      child: boldGreyButtonContainer('로 그 인'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      style: fullLightGreenButtonStyle(),
                      child: boldGreenButtonContainer('회 원 가 입'),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}