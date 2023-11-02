import 'dart:io';
import 'package:exhibition_project/firebase_storage/img_upload.dart';
import 'package:exhibition_project/firestore_connect/artist.dart';
import 'package:exhibition_project/firestore_connect/user.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ArtistEditProfilePage extends StatelessWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동하는 함수
  const ArtistEditProfilePage({Key? key, required this.moveToNextTab});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEditProfile(moveToNextTab: moveToNextTab)
    );
  }
}

class ArtistEditProfile extends StatefulWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동하는 함수
  const ArtistEditProfile({Key? key, required this.moveToNextTab});

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
  Map<String, String> formData = {};
  final ImageSelector selector = ImageSelector();//이미지
  late ImageUploader uploader;
  XFile? _imageFile;
  String? imageURL;
  String? imgPath;
  bool _saving = false; // 저장 로딩

  @override
  void initState() {
    super.initState();
    _init();
    uploader = ImageUploader('artist_images');
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
    final country = await getDefaultCountry(context);
    setState(() {
      _country = country;
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
        margin: EdgeInsets.all(20),
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
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageWidget(),
                          SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed : getImage,
                              child: Text('이미지 선택'),
                            ),
                          ),
                          SizedBox(height: 30),
                          textAndTextField('작가명', _nameController, 'name'),
                          SizedBox(height: 30),
                          textAndTextField('영어명', _englishNameController, 'englishName'),
                          SizedBox(height: 30),
                          textAndTextField('분　야', _expertiseController, 'expertise'),
                          SizedBox(height: 30),
                          textAndTextField('국　적', _nationalityController, 'nationality'),
                          SizedBox(height: 30),
                          textAndTextField('소　개', _introduceController, 'introduce'),
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

  // 이미지 미리보기
  Widget _buildImageWidget() {
    if (imgPath != null) {
      if (kIsWeb) {
        // 웹 플랫폼에서는 Image.network 사용
        return Center(
          child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imgPath!),
          ),
        );
      } else {
        // 앱에서는 Image.file 사용
        return Center(
          child: CircleAvatar(
            radius: 40,
            backgroundImage: FileImage(File(imgPath!)),
          ),
        );
      }
    } else {
      return SizedBox(); // 이미지가 없을 때 빈 SizedBox 반환 또는 다른 대체 위젯
    }
  }

  // 텍스트 필드 값이 변경될 때마다 allFieldsFilled를 다시 계산하여 버튼의 활성화 상태를 업데이트
  void updateButtonState() async {
    setState(() {
      allFieldsFilled = _nameController.text.isNotEmpty &&
          _englishNameController.text.isNotEmpty &&
          _nationalityController.text.isNotEmpty &&
          _expertiseController.text.isNotEmpty &&
          _introduceController.text.isNotEmpty;
    });
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

  Widget textAndTextField(String txt, final ctr, String kind){
    return Row(
      children: [
        textFieldLabel('$txt'),
        Expanded(
          child: textFieldInput(ctr, kind),
        ),
        if(kind == 'nationality') SizedBox(width: 30),
        if(kind == 'nationality')
          ElevatedButton(
            onPressed: () => _countrySelect(),
            child: Text("국가선택")
          ),
      ],
    );
  }


  TextFormField textFieldInput(final ctr, String kind) {
    final isIntroduce = kind == 'introduce';
    final isNationality = kind == 'nationality';
    final borderSide = BorderSide(
      color: Color.fromRGBO(70, 77, 64, 1.0),
      width: 1.0,
    );

    return TextFormField(
        enabled: !isNationality,
        controller: ctr,
        autofocus: true,
        maxLines: isIntroduce ? 5 : 1, // 소개 입력란은 세로가 넓게 지정
        inputFormatters: [
          isIntroduce ? LengthLimitingTextInputFormatter(1000) : LengthLimitingTextInputFormatter(30), // 최대 길이 설정
        ],
        decoration: InputDecoration(
          hintText: isNationality ? '국가를 선택해주세요.' : null,
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: isIntroduce
              ? OutlineInputBorder(borderSide: borderSide)
              : UnderlineInputBorder(borderSide: borderSide),
          enabledBorder: isIntroduce
              ? OutlineInputBorder(borderSide: borderSide)
              : UnderlineInputBorder(borderSide: borderSide),
        ),
    );
  }

  Widget submitButton() {
    // 모든 값을 입력하지 않으면 비활성화
    return ElevatedButton(
      onPressed: allFieldsFilled ? () async {
        try {
          // 입력한 정보 저장
          // 저장 중에 로딩 표시
          setState(() {
            _saving = true;
          });
          formData['name'] = _nameController.text;
          formData['englishName'] = _englishNameController.text;
          formData['expertise'] = _expertiseController.text;
          formData['nationality'] = _nationalityController.text;
          formData['introduce'] = _introduceController.text;

          // 파이어베이스에 정보 및 이미지 저장
          String documentId = await addArtist('artist',formData);
          if (_imageFile != null) {
            await uploadImage();
            await addArtistImg('artist', 'artist_image', documentId, imageURL!, 'artist_images');
          }

          // 저장 완료 후 로딩 표시 비활성화 및 페이지 전환
          setState(() {
            _saving = false;
          });
          widget.moveToNextTab(documentId); // 다음 탭으로 이동
        } on FirebaseAuthException catch (e) {
          firebaseException(e);
        } catch (e) {
          print(e.toString());
        }
      } : null, // 버튼이 비활성 상태인 경우 onPressed를 null로 설정
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(allFieldsFilled ? Colors.green : Colors.grey), // 모든 값을 입력했다면 그린 색상으로 활성화
      ),
      child: boldGreyButtonContainer('정보 저장'),
    );
  }
}
