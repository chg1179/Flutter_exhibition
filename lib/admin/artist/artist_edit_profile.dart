import 'package:exhibition_project/firebase_storage/img_upload.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImageSelector selector = ImageSelector();
  late ImageUploader uploader;

  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    uploader = ImageUploader('artist_images');
  }

  Future<void> getImage() async {
    XFile? pickedFile = await selector.selectImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile != null) {
      String downloadURL = await uploader.uploadImage(_imageFile!);
      print('Uploaded to Firebase Storage: $downloadURL');
    } else {
      print('No image selected.');
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
                          onPressed : getImage,
                          child: Text('이미지 선택'),
                        ),
                        ElevatedButton(
                          onPressed : _imageFile != null ? () async{
                            print(_imageFile?.path);
                            //widget.moveToNextTab(formData, _imageFile);
                          } : null,
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