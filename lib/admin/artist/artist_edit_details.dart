import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/user.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistEditDatailsPage extends StatelessWidget {
  const ArtistEditDatailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEditDatails()
    );
  }
}

class ArtistEditDatails extends StatefulWidget {
  const ArtistEditDatails({super.key});

  @override
  State<ArtistEditDatails> createState() => _ArtistEditDatailsState();
}

class _ArtistEditDatailsState extends State<ArtistEditDatails> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  Country? _country;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _englishNameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();
  bool allFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async{ //동기 맞추기
    final country = await getDefaultCountry(context);
    setState(() {
      _country = country;
    });
  }

  void _countrySelect() async {
    final selectedCountry = await showCountryPickerSheet(
      context,
      cancelWidget: Center(
        child: Container(),
      ),
    );

    if (selectedCountry != null) {
      setState(() {
        _country = selectedCountry;
        _nationalityController.text = _country!.name; // 예시로 국가의 이름을 표시합니다.
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      margin: EdgeInsets.fromLTRB(10, 20, 10, 50),
                      padding: EdgeInsets.all(10),
                      child: Center(
                          child: Text('작가추가', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                      )
                  ),
                  Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textFieldInput(_nameController, "작가명" , 'name'),
                          SizedBox(height: 30),
                          textFieldLabel('영어명'),
                          textFieldInput(_englishNameController,"영어명", 'englishName'),
                          SizedBox(height: 30),
                          textFieldLabel('국적'),
                          textFieldInput(_nationalityController, "국적", 'nationality'),
                          ElevatedButton(
                              onPressed: () => _countrySelect(),
                              child: Text("국가선택")
                          ),
                          SizedBox(height: 30),
                          textFieldLabel('전문 분야'),
                          textFieldInput(_expertiseController, "전문 분야", 'expertise'),
                          SizedBox(height: 30),
                          textFieldLabel('소개'),
                          textFieldInput(_introduceController, "소개", 'introduce'),
                          SizedBox(height: 30)
                        ],
                      )
                  ),

                  // 추가
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
    );
  }


  TextFormField textFieldInput(final ctr, String hintTxt, String kind) {
    return TextFormField(
        enabled: kind != 'nationality',
        controller: ctr,
        autofocus: true,
        inputFormatters: [
          kind != 'introduce' ? LengthLimitingTextInputFormatter(30) : LengthLimitingTextInputFormatter(1000), // 최대 길이 설정
        ],
        decoration: InputDecoration(
          hintText: hintTxt, //입력란에 나타나는 텍스트
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
                width: 1.8,
              )
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
            ),
          ),
        )
    );
  }

  Widget submitButton() {
    // 모든 값을 입력했는지 확인
    bool allFieldsFilled = _nameController.text.isNotEmpty &&
        _englishNameController.text.isNotEmpty &&
        _nationalityController.text.isNotEmpty &&
        _expertiseController.text.isNotEmpty &&
        _introduceController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: allFieldsFilled ? () async { // 모든 값을 입력하지 않으면 비활성화
        try {
          // Firestore에 작가 정보 추가
          /*
        await addArtistFirestore(
          'artist',
          _nameController.text,
          _englishNameController.text,
          _nationalityController.text,
          _expertiseController.text,
          _introduceController.text,
        );*/
          showMoveDialog(context, '작가가 성공적으로 추가되었습니다.', () => ArtistList());
        } on FirebaseAuthException catch (e) {
          firebaseException(e);
        } catch (e) {
          print(e.toString());
        }
      } : null, // 버튼이 비활성 상태인 경우 onPressed를 null로 설정
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(allFieldsFilled ? Colors.green : Colors.grey), // 모든 값을 입력했다면 그린 색상으로 활성화
      ),
      child: boldGreyButtonContainer('추가하기'),
    );
  }
}
