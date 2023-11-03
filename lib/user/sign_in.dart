import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dialog/show_message.dart';
import 'home.dart';
import 'sign_up.dart';
import '../model/user_model.dart';
import '../hash/hash_password.dart';
import '../style/button_styles.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color.fromRGBO(70, 77, 64, 1.0), // 커서 색상
        ),
      ),
      home: SignInCheck(),
    );
  }
}

class SignInCheck extends StatefulWidget {
  const SignInCheck({super.key});

  @override
  State<SignInCheck> createState() => _SignInCheckState();
}

class _SignInCheckState extends State<SignInCheck> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스 가져옴
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool pwdHide = true; //패스워드 감추기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
    body: SingleChildScrollView( // SingleChildScrollView 추가
    child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 50),
                    padding: EdgeInsets.all(10),
                    child: Center(
                        child: Text('로그인', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                    )
                ),
                _TextField(_emailController, '이메일', 'email'),
                SizedBox(height: 20),
                _TextField(_pwdController, '비밀번호', 'pwd'),
                SizedBox(height: 80),
                Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            style: fullGreenButtonStyle(),
                            child: boldGreyButtonContainer('로그인'),
                          ),
                          SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            style: fullLightGreenButtonStyle(),
                            child: boldGreenButtonContainer('회원가입'),
                          ),
                        ]
                    )
                ),
              ],
            ),
          )
      )
    );
  }

  Widget _TextField(TextEditingController ctr, String txt, String kind) {
    return TextField(
      controller: ctr,
      obscureText: kind == 'pwd' ? pwdHide : false,
      decoration: InputDecoration(
        labelText: txt,
        suffixIcon: kind == 'pwd' || kind == 'pwdCheck'
            ? IconButton(
          icon: Icon(pwdHide ? Icons.visibility_off : Icons.visibility),
          color: Color.fromRGBO(70, 77, 64, 1.0),
          onPressed: () {
            setState(() {
              pwdHide = !pwdHide;
            });
          },
        )
            : null,
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
              width: 1.8,
            )
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
          ),
        ),
        labelStyle: TextStyle(
          color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 텍스트 색상
        ),
      ),
    );
  }

  void _login() async {
    String email = _emailController.text;
    String password = _pwdController.text;
    if (email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 주소를 입력해 주세요.'))
      );
      return null;
    }
    if (password!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀 번호를 입력해 주세요.'))
      );
      return null;
    }
    final userEmail = await _fs.collection('user')
        .where('email', isEqualTo: email)
        .get();
    if (userEmail.docs.isNotEmpty) {
      final userDocument = userEmail.docs.first;
      final userHashPassword = userDocument.get('password');
      final userRandomSalt = userDocument.get('randomSalt');
      bool pwdCheck = isPasswordValid(password, userHashPassword, userRandomSalt);
      print(pwdCheck);
      if (pwdCheck) {
        Provider.of<UserModel>(context, listen: false).signIn(userDocument.id, userDocument.get('status')); //세션 값 부여
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 되었습니다.'))
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        showMessageDialog(context, '비밀번호를 확인해 주세요.');
      }
    } else {
      showMessageDialog(context, '일치하는 아이디가 없습니다.');
    }
  }
}