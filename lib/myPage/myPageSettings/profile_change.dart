import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firebase_storage/image_upload.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/firestore_connect/user_query.dart';
import 'package:exhibition_project/model/user_model.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            SizedBox(height: 100),
            Center(
                child: Container(
                  width: 150,
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
            SizedBox(height: 70),
            // 이미지를 선택했으나, 기본 이미지로 변경하고 싶을 때
            if(profileImage != 'https://firebasestorage.googleapis.com/v0/b/exhibitionproject-fdba1.appspot.com/o/artist_images%2Fgreen_logo.png?alt=media&token=504ba42a-5385-484e-9a00-fa1ca7006363')
              basicImageChangeButton(),
            SizedBox(height: 15),
            imageChangeButton()
          ],
        ),
      ),
    );
  }


  Widget basicImageChangeButton() {
    return  ElevatedButton(
        onPressed: () async {
          bool check = await chooseMessageDialog(context, '기본 이미지로 변경하시겠습니까?', '변경');
          if(check) {
            await updateImageURL('user', (user.userNo).toString(), 'https://firebasestorage.googleapis.com/v0/b/exhibitionproject-fdba1.appspot.com/o/artist_images%2Fgreen_logo.png?alt=media&token=504ba42a-5385-484e-9a00-fa1ca7006363', 'user_images', 'profileImage');
            // 저장 완료 메세지
            await showMoveDialog(context, '성공적으로 저장되었습니다.', () => MyPage());
          }
        },
        style: fullLightGreenButtonStyle(),
        child: boldGreenButtonContainer('기본 이미지로 변경')
    );
  }

  Widget imageChangeButton() {
    // 새롭게 이미지를 선택하지 않으면 비활성화
    return ElevatedButton(
      onPressed: _imageFile != null ? () async {
        try {
          bool check = await chooseMessageDialog(context, '프로필 이미지를 변경하시겠습니까?', '변경');
          if(check) {
            await uploadImage();
            await updateImageURL('user', (user.userNo).toString(), imageURL!, 'user_images', 'profileImage');
            // 저장 완료 메세지
            await showMoveDialog(context, '성공적으로 저장되었습니다.', () => MyPage());
          }
        } on FirebaseAuthException catch (e) {
          firebaseException(e);
        } catch (e) {
          print(e.toString());
        }
      } : null, // 버튼이 비활성 상태인 경우 onPressed를 null로 설정
      style: _imageFile != null ? fullGreenButtonStyle() : fullGreyButtonStyle(), // 모든 값을 입력했다면 그린 색상으로 활성화,
      child: boldGreyButtonContainer('이미지 변경하기'),
    );
  }
}
