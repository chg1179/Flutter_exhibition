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
  final picker = ImagePicker();
  XFile? _imageFile;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      print('이미지가 선택되지 않았습니다.');
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile != null) {
      Uint8List? imageBytes = await _imageFile!.readAsBytes();

      FirebaseStorage storage = FirebaseStorage.instance;
      String folderName = 'artist_images/';
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = storage.ref().child('$folderName/$fileName.jpg');
      UploadTask uploadTask = storageReference.putData(imageBytes);

      await uploadTask.whenComplete(() async {
        String downloadURL = await storageReference.getDownloadURL();
        print('Firebase Storage에 이미지 업로드 완료: $downloadURL');
      });
    } else {
      print('이미지를 선택하지 않았습니다.');
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
                          onPressed: getImage,
                          child: Text('이미지 선택'),
                        ),
                        ElevatedButton(
                          onPressed: uploadImage,
                          child: Text('이미지 업로드'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //widget.moveToNextTab(formData, file);
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