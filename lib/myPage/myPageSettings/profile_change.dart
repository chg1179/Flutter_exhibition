import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firebase_storage/image_upload.dart';
import 'package:exhibition_project/model/user_model.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileChange extends StatefulWidget {
  const ProfileChange({super.key});

  @override
  State<ProfileChange> createState() => _ProfileChangeState();
}

class _ProfileChangeState extends State<ProfileChange> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  late UserModel user;
  late Map<String, dynamic> userData;
  final ImageSelector selector = ImageSelector();//이미지
  late ImageUploader uploader;
  XFile? _imageFile;
  String? imageURL;
  String? imgPath;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    uploader = ImageUploader('user_images');
    getOriginalData();
  }

  Future<void> getOriginalData() async {
    user = Provider.of<UserModel>(context, listen: false);
    DocumentSnapshot<Map<String, dynamic>> gallerySnapshot = await _fs.collection('user').doc(user.userNo).get();
    userData = gallerySnapshot.data()!;

    setState(() {
      profileImage = userData['profileImage']; // 기존에 선택했던 이미지 출력
    });
  }

  // 이미지 가져오기
  Future<void> getImage() async {
    XFile? pickedFile = await selector.selectImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        imgPath = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  // 이미지 추가
  Future<void> uploadImage() async {
    if (_imageFile != null) {
      imageURL = await uploader.uploadImage(_imageFile!);
      print('Uploaded to Firebase Storage: $imageURL');
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "프로필 이미지 변경",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 100),
          Center(
            child: Container(
              width: 150, // Set the desired width here
              child: InkWell(
                onTap: getImage,
                child: Column(
                  children: [
                    Center(
                      child: ClipOval(
                        child: _imageFile != null
                            ? buildImageWidget(
                              imageFile: _imageFile,
                              imgPath: imgPath,
                              selectImgURL: profileImage,
                              defaultImgURL: 'assets/logo/basic_logo.png',
                              radiusValue : 75.0,
                            )
                            : (user != null && profileImage != null)
                              ? Image.network(profileImage!, fit: BoxFit.cover, width: 150, height: 150)
                              : Image.asset('assets/logo/green_logo.png', fit: BoxFit.cover, width: 150, height: 150),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
          ElevatedButton(
            onPressed: (){

            },
            child: Text('기본 이미지로 변경')
          ),
          ElevatedButton(
            onPressed: (){

            },
            child: Text('이미지 변경')
          )
        ],
      ),
    );
  }

  //            if (_imageFile != null) {
//               await uploadImage();
//               await updateImageURL('artist', documentId!, imageURL!, 'artist_images');
//             }
}
