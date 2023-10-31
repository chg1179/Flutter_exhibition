import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/user.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArtistEditAdditionPage extends StatelessWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동하는 함수
  final Map<String, String> formData; // 입력한 값을 담는 맵
  const ArtistEditAdditionPage({Key? key, required this.moveToNextTab, required this.formData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEditAddition(moveToNextTab: moveToNextTab, formData: formData)
    );
  }
}

class ArtistEditAddition extends StatefulWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동하는 함수
  final Map<String, String> formData; // 입력한 값을 담는 맵
  const ArtistEditAddition({Key? key, required this.moveToNextTab, required this.formData});

  @override
  State<ArtistEditAddition> createState() => _ArtistEditAdditionState();
}

class _ArtistEditAdditionState extends State<ArtistEditAddition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(15),
        child: Center(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.all(20),
                            child: submitButton(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
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
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green)
      ),
      child: boldGreyButtonContainer('추가하기'),
    );
  }
}
