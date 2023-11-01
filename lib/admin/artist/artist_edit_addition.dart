import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/artist.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ArtistEditAdditionPage extends StatelessWidget {
  final Map<String, String> formData;
  final XFile? imageFile; // 이미지 파일 정보
  const ArtistEditAdditionPage({Key? key, required this.formData, required this.imageFile});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ArtistEditAddition(formData: formData, imageFile: imageFile),
    );
  }
}

class ArtistEditAddition extends StatefulWidget {
  final Map<String, String> formData; // 입력한 값을 담는 맵
  final XFile? imageFile; // 이미지 파일 정보
  const ArtistEditAddition({Key? key, required this.formData, required this.imageFile});
  @override
  _ArtistEditAdditionState createState() => _ArtistEditAdditionState();
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
                        Text('Image File: ${widget.imageFile}'),
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
      onPressed: () async {
        await addArtist(
          'artist',
          widget.formData,
        );
        //uploadImage;
        showMoveDialog(context, '작가가 성공적으로 추가되었습니다.', () => ArtistList());
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green)
      ),
      child: boldGreyButtonContainer('추가하기'),
    );
  }
}
