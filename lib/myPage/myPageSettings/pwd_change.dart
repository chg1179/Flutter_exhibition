import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/user_query.dart';
import 'package:exhibition_project/hash/hash_password.dart';
import 'package:exhibition_project/model/user_model.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/user/sign_in.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PwdChange extends StatefulWidget {
  @override
  _PwdChangeState createState() => _PwdChangeState();
}

class _PwdChangeState extends State<PwdChange> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _pwdCheckController = TextEditingController();
  bool pwdHide = true; //비밀번호 감추기
  bool pwdCheckHide = true; //비밀번호 확인 감추기
  bool pwdMatch = false; // 비밀번호가 일치하는지 확인

  @override
  void initState() {
    super.initState();
    _init();
  }

  // 동기 맞추기
  void _init() async{
    setState(() {
      _pwdController.addListener(pwdMathCheck);
      _pwdCheckController.addListener(pwdMathCheck);
    });
  }

  // 텍스트 필드 값이 변경될 때마다 allFieldsFilled를 다시 계산하여 버튼의 활성화 상태를 업데이트
  void pwdMathCheck() async {
    setState(() {
      if(_pwdController.text == _pwdCheckController.text && _pwdController.text != '' && _pwdController.text != null){
        pwdMatch = true;
      } else{
        pwdMatch = false;
      }
    });
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textFieldLabel('비밀번호'),
              textFieldInput(_pwdController,"특수 문자 포함한 8자 이상의 비밀번호를 입력해 주세요.", "pwd"),
              SizedBox(height: 30),
              textFieldLabel('비밀번호확인'),
              textFieldInput(_pwdCheckController, "비밀번호를 입력해 주세요.", "pwdCheck"),
              SizedBox(height: 30),
              Container(
                  margin: EdgeInsets.all(20),
                  child: submitButton()
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField textFieldInput(final ctr, String hintTxt, String kind) {
    return TextFormField(
      controller: ctr,
      autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20), // 최대 길이 설정. 최대 길이가 화면에 출력되지 않도록 설정
      ],
      obscureText: kind == 'pwd'
          ? pwdHide
          : (kind == 'pwdCheck' ? pwdCheckHide : false),
      validator: (val) { // 인풋 창에 입력된 값 필터
        RegExp regExp = new RegExp(r'\s'); //공백 정규식
        if (val!.isEmpty) { // 입력 값이 없을 때
          return '필수 입력 값입니다.';
        } else if(regExp.hasMatch(val)){
          return '공백을 제외하고 입력해 주세요.';
        }else if(kind == "pwd"){
          // 8자 이상 입력
          if (val.length < 8)
            return '비밀번호를 8자 이상 입력해 주세요.';
          // 특수문자 1개 이상 포함
          String pattern = r'[!@#\$%^&*(),.?":{}|<>]';
          regExp = RegExp(pattern);
          if(!regExp.hasMatch(val))
            return '특수 문자를 1개 이상 포함해 주세요.';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: hintTxt, //입력란에 나타나는 텍스트
        hintStyle: TextStyle(fontSize: 13),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
        suffixIcon: kind == 'pwd' || kind == 'pwdCheck'
            ? IconButton(
          icon: Icon(kind == 'pwd'
              ? (pwdHide ? Icons.visibility_off : Icons.visibility)
              : (pwdCheckHide ? Icons.visibility_off : Icons.visibility),
            color: Color.fromRGBO(70, 77, 64, 1.0), size: 20,
          ),
          onPressed: () {
            setState(() {
              if (kind == 'pwd')
                pwdHide = !pwdHide;
              else
                pwdCheckHide = !pwdCheckHide;
            });
          },
        )
            : null,
      ),
    );
  }

  ElevatedButton submitButton() {
    return ElevatedButton(
        onPressed: pwdMatch ? () async {
          if (_key.currentState!.validate()) {
            try {
              final user = Provider.of<UserModel>(context, listen: false); // 세션. UserModel 프로바이더에서 값을 가져옴.
              final FirebaseFirestore _fs = FirebaseFirestore.instance;
              DocumentSnapshot<Map<String, dynamic>> gallerySnapshot = await _fs.collection('user').doc(user.userNo).get();
              Map<String, dynamic> userData = gallerySnapshot.data()!;
              final randomSalt = userData['randomSalt']; // 고유한 해시값을 받아와 해싱에 이용
              final password = _pwdController.text;
              final hashedPassword = hashPassword(password, randomSalt); // 입력한 비밀번호 해시화

              // Firestore에 사용자 정보 추가
              await updateUserPassword('user', user.userNo!, hashedPassword);
              Navigator.of(context).pop();
              user.signOut();
              showMoveDialog(context, '비밀번호가 변경되었습니다. 다시 로그인해주세요.', () => SignInPage());
            } on FirebaseAuthException catch (e) {
              firebaseException(e);
            } catch (e) {
              print(e.toString());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('입력 조건을 확인해 주세요.'))
            );
          }
        } : null,
        style: pwdMatch ? fullGreenButtonStyle() : fullGreyButtonStyle(),
        child: boldGreyButtonContainer('비밀번호 변경')
    );
  }
}