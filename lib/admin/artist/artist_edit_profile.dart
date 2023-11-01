import 'dart:io';
import 'dart:typed_data';

import 'package:exhibition_project/firebase_storage/img_upload.dart';
import 'package:exhibition_project/firebase_storage/permission_status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ArtistEditProfilePage extends StatelessWidget {
  final Function moveToNextTab;

  const ArtistEditProfilePage({
    Key? key,
    required this.moveToNextTab,
  });

  @override
  Widget build(BuildContext context) {
    return ArtistEditProfile(
      moveToNextTab: moveToNextTab,
    );
  }
}

class ArtistEditProfile extends StatefulWidget {
  final Function moveToNextTab;

  const ArtistEditProfile({
    Key? key,
    required this.moveToNextTab,
  });

  @override
  _ArtistEditProfileState createState() => _ArtistEditProfileState();
}

class _ArtistEditProfileState extends State<ArtistEditProfile> {
  Map<String, String> formData = {};  // 다음 탭으로 값을 보내는 맵
  late FilePickerResult? file;

  Future<void> saveSelectedImage() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles();
    if (pickedFile != null) {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        String downloadURL = await uploadImageToFirebaseStorage(image);

        setState(() {
          file = pickedFile;
          print('Image uploaded. URL: $downloadURL');
        });
      } else {
        print('파일을 선택하지 않았습니다.');
      }
    } else {
      print('파일을 선택하지 않았습니다.');
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
                          child: Text('프로필 이미지 선택'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            widget.moveToNextTab(formData, file);
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