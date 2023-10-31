import 'dart:io';

import 'package:exhibition_project/widget/tab_wigets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ArtistEditProfilePage extends StatelessWidget {
  final Function moveToNextTab;
  final Map<String, String> formData;

  const ArtistEditProfilePage({
    Key? key,
    required this.moveToNextTab,
    required this.formData,
  });

  @override
  Widget build(BuildContext context) {
    return ArtistEditProfile(
      moveToNextTab: moveToNextTab,
      formData: formData,
    );
  }
}

class ArtistEditProfile extends StatefulWidget {
  final Function moveToNextTab;
  final Map<String, String> formData;

  const ArtistEditProfile({
    Key? key,
    required this.moveToNextTab,
    required this.formData,
  });

  @override
  _ArtistEditProfileState createState() => _ArtistEditProfileState();
}

class _ArtistEditProfileState extends State<ArtistEditProfile> {
  final ImagePicker _picker = ImagePicker();
  File? savedImage; // 변수를 null로 초기화

  Future<void> saveSelectedImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String destPath = '${appDocDir.path}/images';

      Directory(destPath).create(recursive: true).then((Directory directory) {
        String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = 'file_$currentTime.png';

        File newImage = File('${directory.path}/$fileName');
        File(pickedImage.path).copy(newImage.path).then((File newFile) {
          if (newFile.existsSync()) {
            setState(() {
              savedImage = newFile;
            });
            print('이미지 저장 완료. 경로: ${newFile.path}');
          } else {
            print('이미지 저장 실패.');
          }
        }).catchError((e) {
          print('에러: $e');
        });
      });
    }
  }

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
                        ElevatedButton(
                          onPressed: saveSelectedImage,
                          child: Text('프로필 이미지 선택 및 저장'),
                        ),
                        if (savedImage != null) Image.file(savedImage!),
                        ElevatedButton(
                          onPressed: () {
                            widget.moveToNextTab(widget.formData);
                          },
                          child: Text('다음'),
                        ),
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
}