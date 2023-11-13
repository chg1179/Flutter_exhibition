import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firebase_storage/image_upload.dart';
import 'package:exhibition_project/firestore_connect/artist_query.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/firestore_connect/user_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:exhibition_project/widget/text_and_textfield.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ArtistEditProfilePage extends StatelessWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동
  final DocumentSnapshot? document;
  const ArtistEditProfilePage({Key? key, required this.moveToNextTab, required this.document,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ArtistEditProfile(moveToNextTab: moveToNextTab, document: document);
  }
}

class ArtistEditProfile extends StatefulWidget {
  final Function moveToNextTab;
  final DocumentSnapshot? document;
  const ArtistEditProfile({Key? key, required this.moveToNextTab, required this.document}) : super(key: key);

  @override
  _ArtistEditProfileState createState() => _ArtistEditProfileState();
}

class _ArtistEditProfileState extends State<ArtistEditProfile> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  Country? _country; // 국가
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _englishNameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();
  bool allFieldsFilled = false; // 모든 값을 입력하지 않으면 비활성화
  Map<String, String> formData = {}; // 컨테이너에 값을 넣어 파라미터로 전달
  final ImageSelector selector = ImageSelector();//이미지
  late ImageUploader uploader;
  XFile? _imageFile;
  String? imageURL;
  String? imgPath;
  String? selectImgURL;
  bool _saving = false; // 저장 로딩

  @override
  void initState() {
    super.initState();
    _init();
    uploader = ImageUploader('artist_images');
    settingText();
  }

  // 수정하는 경우에 저장된 값을 필드에 출력
  Future<void> settingText() async {
    if (widget.document != null) {
      Map<String, dynamic> data = getMapData(widget.document!);
      if (widget.document!.exists) {
        _nameController.text = data['artistName'];
        _englishNameController.text = data['artistEnglishName'];
        _nationalityController.text = data['artistNationality'];
        _expertiseController.text = data['expertise'];
        _introduceController.text = data['artistIntroduce'];
        selectImgURL = await data['imageURL'];
        print(selectImgURL);
        setState(() {
          allFieldsFilled = true; // 이미 모든 정보를 입력한 사용자를 불러옴
        });
        print('기존 정보를 수정합니다.');
      } else {
        print('새로운 정보를 추가합니다.');
      }
    }
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

  // 동기 맞추기
  void _init() async{
    setState(() {
      // 편리성을 위해 한국으로 국적 초기화. 국가 이름, 이미지, 국가 코드, 다이얼링 코드
      if(widget.document == null) {
        _country = Country('Korea (Republic of)', 'assets/flags/kr_flag.png', 'KR', '82');
        _nationalityController.text = _country?.name ?? ''; // Null check
      }
      _nameController.addListener(updateButtonState);
      _englishNameController.addListener(updateButtonState);
      _nationalityController.addListener(updateButtonState);
      _expertiseController.addListener(updateButtonState);
      _introduceController.addListener(updateButtonState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      body: Container(
        child: Center(
          child: Form(
            key: _key,
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
                          SizedBox(height: 10),
                          Center(
                            child: InkWell(
                              onTap: getImage, // 이미지를 선택하는 함수 호출
                              child: Column(
                                children: [
                                  ClipOval(
                                    child:
                                      _imageFile != null
                                        ? buildImageWidget(
                                          // 이미지 빌더 호출
                                          imageFile: _imageFile,
                                          imgPath: imgPath,
                                          selectImgURL: selectImgURL,
                                          defaultImgURL: 'assets/logo/basic_logo.png',
                                          radiusValue : 65.0,
                                        )
                                        : (widget.document != null && selectImgURL != null)
                                          ? Image.network(selectImgURL!, fit: BoxFit.cover, width: 130, height: 130)
                                          : Image.asset('assets/logo/basic_logo.png', fit: BoxFit.cover, width: 130, height: 130),
                                  ),
                                ],
                              )
                            ),
                          ),
                          SizedBox(height: 30),
                          TextAndTextField('작가명', _nameController, 'name'),
                          SizedBox(height: 30),
                          TextAndTextField('영어명', _englishNameController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('분　야', _expertiseController, 'expertise'),
                          SizedBox(height: 30),
                          ButtonTextAndTextField('국　적', '국가선택', _nationalityController, 'nationality', _countrySelect),
                          SizedBox(height: 30),
                          TextAndTextField('소　개', _introduceController, 'introduce'),
                        ],
                      )
                  ),
                  // 추가
                  Container(
                      margin: EdgeInsets.all(20),
                      child: submitButton()
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 국가 선택
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
        _nationalityController.text = _country!.name; // 국가의 이름 표시
      });
    }
  }

  // 텍스트 필드 값이 변경될 때마다 allFieldsFilled를 다시 계산하여 버튼의 활성화 상태를 업데이트
  void updateButtonState() async {
    setState(() {
      allFieldsFilled = _nameController.text.isNotEmpty &&
          _englishNameController.text.isNotEmpty &&
          _nationalityController.text.isNotEmpty &&
          _expertiseController.text.isNotEmpty;
    });
  }

  Widget submitButton() {
    // 모든 값을 입력하지 않으면 비활성화
    return ElevatedButton(
      onPressed: allFieldsFilled ? () async {
        try {
          // 입력한 정보 저장
          setState(() {
            _saving = true; // 저장 중
          });
          formData['name'] = _nameController.text;
          formData['englishName'] = _englishNameController.text;
          formData['expertise'] = _expertiseController.text;
          formData['nationality'] = _nationalityController.text;
          formData['introduce'] = _introduceController.text;

          // 파이어베이스에 정보 및 이미지 저장
          if (widget.document != null && widget.document!.exists) { // 수정
            await updateArtist('artist', widget.document!, formData);
            String documentId = widget.document!.id;
            if (_imageFile != null) {
              await uploadImage();
              await updateImageURL('artist', widget.document!.id, imageURL!, 'artist_images', 'imageURL');
            }
            widget.moveToNextTab(documentId, 'update'); // 다음 탭으로 이동
          } else { // 추가
            String documentId = await addArtist('artist', formData);
            if (_imageFile != null) {
              await uploadImage();
              await updateImageURL('artist', documentId!, imageURL!, 'artist_images', 'imageURL');
            }
            widget.moveToNextTab(documentId, 'add'); // 다음 탭으로 이동
          }

          // 저장 완료 후 페이지 전환
          setState(() {
            _saving = false;
          });
        } on FirebaseAuthException catch (e) {
          firebaseException(e);
        } catch (e) {
          print(e.toString());
        }
      } : null, // 버튼이 비활성 상태인 경우 onPressed를 null로 설정
      style: allFieldsFilled ? fullGreenButtonStyle() : fullGreyButtonStyle(), // 모든 값을 입력했다면 그린 색상으로 활성화,
      child: boldGreyButtonContainer('정보 저장'),
    );
  }
}