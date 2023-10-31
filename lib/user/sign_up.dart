import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dialog/show_message.dart';
import '../firestore_connect/user.dart';
import '../hash/hash_password.dart';
import 'sign_in.dart';
import '../style/button_styles.dart';
import '../widget/text_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _pwdCheckController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String emailText = "";//입력한 이메일 내용 저장하여 입력값이 바뀌었는지를 확인. 인풋 조건에 안맞는지 중복인지를 다시 출력하기 위해 사용
  String nickNameText = "";
  String phoneText = "";
  List<bool> _termsChecked = [false, false]; //약관 동의. 미동의로 초기값 설정
  bool eventChecked = false; //이벤트 수신 동의. 미동의로 초기값 설정
  bool pwdHide = true; //비밀번호 감추기
  bool pwdCheckHide = true; //비밀번호 확인 감추기
  bool duplicateEmail = false; //중복을 체크했는지 확인하여 메시지를 변경할 변수
  bool duplicatePhone = false;
  bool duplicateNickName = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Color.fromRGBO(70, 77, 64, 1.0), // 커서 색상
          ),
      ),
      home: Scaffold(
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
        body: Container(
          margin: EdgeInsets.all(30),
          padding: EdgeInsets.all(15),
          child: Center(
            child: Form(
              key: _key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                      padding: EdgeInsets.all(10),
                      child: Text('회원 정보를 입력해 주세요.', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                    ),
                    Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textFieldLabel('이메일 주소'),
                          textFieldInput(_emailController, "이메일 주소", "email"),
                          if (duplicateEmail) SizedBox(height: 10),
                          if (duplicateEmail) duplicateText('중복된 이메일 주소입니다.'),
                          SizedBox(height: 30),
                          textFieldLabel('비밀번호'),
                          textFieldInput(_pwdController,"특수 문자를 포함하는 8자 이상의 비밀번호를 입력해 주세요.", "pwd"),
                          SizedBox(height: 30),
                          textFieldLabel('비밀번호 확인'),
                          textFieldInput(_pwdCheckController, "비밀번호를 확인해 주세요.", "pwdCheck"),
                          SizedBox(height: 30),
                          textFieldLabel('닉네임'),
                          textFieldInput(_nickNameController,"한글이나 영어로 구성된 닉네임을 입력해 주세요.","nickName"),
                          if (duplicateNickName) SizedBox(height: 10),
                          if (duplicateNickName) duplicateText('중복된 닉네임입니다.'),
                          SizedBox(height: 30),
                          textFieldLabel('핸드폰 번호'),
                          textFieldInput(_phoneController,"'-'을 제외한 핸드폰 번호를 입력해 주세요.","phone"),
                          if (duplicatePhone) SizedBox(height: 10),
                          if (duplicatePhone) duplicateText('중복된 핸드폰 번호입니다.'),
                          SizedBox(height: 30),
                        ],
                      )
                    ),
                    // 이벤트 수신 동의
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _checkboxTile('개인정보 수집·이용 (필수)', _termsChecked[0], '0'),
                          SizedBox(height: 10),
                          _checkboxTile('서비스 이용을 위한 필수 약관 (필수)', _termsChecked[1], '1'),
                          SizedBox(height: 10),
                          _checkboxTile('이벤트 수신 동의 (선택)', eventChecked, 'event')
                        ],
                      )
                    ),
                    SizedBox(height: 30),
                    // 회원가입
                    Container(
                      margin: EdgeInsets.all(20),
                      child: submitButton()
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  TextFormField textFieldInput(final ctr, String hintTxt, String kind) {
    return TextFormField(
      controller: ctr,
      autofocus: true,
      keyboardType: kind == 'phone' ? TextInputType.phone : TextInputType.text,
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
        }else if(kind == 'email'){
          String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
          regExp = new RegExp(pattern);
          if(!regExp.hasMatch(val))
            return '올바르지 않은 이메일 주소입니다.';
        } else if(kind == 'phone'){
          String pattern = r'^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$';
          regExp = new RegExp(pattern);
          if(!regExp.hasMatch(val))
            return "올바르지 않은 핸드폰 번호입니다.";
        } else if(kind == "pwd"){
          // 8자 이상 입력
          if (val.length < 8)
            return '비밀번호를 8자 이상 입력해 주세요.';
          // 특수문자 1개 이상 포함
          String pattern = r'[!@#\$%^&*(),.?":{}|<>]';
          regExp = RegExp(pattern);
          if(!regExp.hasMatch(val))
            return '특수 문자를 1개 이상 포함해 주세요.';
        } else if(kind == 'nickName'){
          String pattern = r'[가-힣a-zA-Z]';
          regExp = new RegExp(pattern);
          if(!regExp.hasMatch(val))
            return '올바르지 않은 닉네임입니다.';
        }else if(kind == "pwdCheck" && val != _pwdController.text){
          return '비밀번호가 일치하지 않습니다.';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: hintTxt, //입력란에 나타나는 텍스트
        labelStyle: TextStyle(
          fontSize: 18,
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
                color: Color.fromRGBO(70, 77, 64, 1.0),
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

  _checkboxTile(String message, bool checked, String kind) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
          InkWell(
            onTap: () {
              setState(() {
                if(kind == '0')
                  _termsChecked[0] = !_termsChecked[0];
                else if(kind == '1')
                  _termsChecked[1] = !_termsChecked[1];
                else if(kind == 'event')
                  eventChecked = !eventChecked;
              });
            },
            child: Container(
              child: checked
                  ? Icon(Icons.check, size: 30, color: Color.fromRGBO(70, 77, 64, 1.0)) // 체크 시 체크 아이콘
                  : Icon(Icons.check, size: 30, color: Color.fromRGBO(212, 216, 200, 1.0)), // 체크되지 않은 경우
            ),
          )
        ],
      ),
      onTap: (){
        setState(() { //텍스트를 누를 때도 약관 동의 체크 상태 변경
          if(kind == '0')
            _termsChecked[0] = !_termsChecked[0];
          else if(kind == '1')
            _termsChecked[1] = !_termsChecked[1];
          else if(kind == 'event')
            eventChecked = !eventChecked;
        });
      },
    );
  }

  //중복체크
  Future<bool> checkDuplicateField(String fieldName, String value) async {
    final FirebaseFirestore _fs = FirebaseFirestore.instance;
    final checkData = await _fs.collection('user').where(fieldName, isEqualTo: value).get();
    return checkData.docs.isNotEmpty;
  }
  Future<void> checkAndSetDuplicates() async {
    bool isEmailDuplicate = await checkDuplicateField('email', _emailController.text);
    bool isPhoneDuplicate = await checkDuplicateField('phone', _phoneController.text);
    bool isNickNameDuplicate = await checkDuplicateField('nickName', _nickNameController.text);

    setState(() {
      duplicateEmail = isEmailDuplicate;
      duplicatePhone = isPhoneDuplicate;
      duplicateNickName = isNickNameDuplicate;
    });
  }

  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          //조건을 만족한 입력값 저장. 버튼을 누르고 입력 값이 바뀌었는지 확인하기 위해 사용
          setState(() {
            emailText = _emailController.text;
            phoneText = _phoneController.text;
            nickNameText = _nickNameController.text;
          });
          // 중복 체크
          await checkAndSetDuplicates();
          if(duplicateEmail || duplicatePhone || duplicateNickName) return null;

          // 모든 약관에 동의해야 회원 가입 가능
          for(var checked in _termsChecked) {
            if(!checked) return showMessageDialog(context, '필수 약관에 동의해 주세요.');
          }
          try {
            // 입력한 비밀번호 해시화
            final randomSalt = generateRandomSalt();
            final password = _pwdController.text;
            final hashedPassword = hashPassword(password, randomSalt);

            // Firestore에 사용자 정보 추가
            await addUserFirestore(
                'user',
                _emailController.text,
                hashedPassword,
                randomSalt,
                _nickNameController.text,
                _phoneController.text,
                eventChecked
            );
            showMoveDialog(context, '회원가입이 성공적으로 완료되었습니다.', () => SignInPage());
          } on FirebaseAuthException catch (e) {
            firebaseException(e);
          } catch (e) {
            print(e.toString());
          }
        } else {
          // 중복 메세지가 뜬 뒤 값을 수정하여 추가 메세지가 나올 때 중복으로 메세지가 출력되지 않도록 false으로 설정
          if(!(_key.currentState!.validate())) {
            await checkAndSetDuplicates();
            setState(() {
              if ((_emailController.text != "" && emailText != _emailController.text)) //입력 값이 바뀌었을 때 이미 중복체크되어 true로 바뀌었다면 바꾸지 않음
                duplicateEmail = false;
              if ((_phoneController.text != "" && phoneText != _phoneController.text))
                duplicatePhone = false;
              if ((_nickNameController.text != "" && nickNameText != _nickNameController.text))
                duplicateNickName = false;
            });
          }
        }
      },
      style: fullGreenButtonStyle(),
      child: boldGreyButtonContainer('가입 하기')
    );
  }
}