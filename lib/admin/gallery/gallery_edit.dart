import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/gallery/gallery_list.dart';
import 'package:exhibition_project/firebase_storage/img_upload.dart';
import 'package:exhibition_project/firestore_connect/gallery_query.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/firestore_connect/user_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:exhibition_project/widget/text_and_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryEditPage extends StatelessWidget {
  final DocumentSnapshot? document;
  const GalleryEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return GalleryEdit(document: document);
  }
}

class GalleryEdit extends StatefulWidget {
  final DocumentSnapshot? document;
  const GalleryEdit({super.key, required this.document});

  @override
  State<GalleryEdit> createState() => _GalleryEditState();
}

class _GalleryEditState extends State<GalleryEdit> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  final TextEditingController _galleryNameController = TextEditingController(); // 갤러리명
  final TextEditingController _addrController = TextEditingController(); // 주소
  final TextEditingController _detailsAddressController = TextEditingController(); // 상세주소
  final TextEditingController _galleryCloseController = TextEditingController(); // 휴관일
  final TextEditingController _startTimeController = TextEditingController(); // 운영 시작 시간
  final TextEditingController _endTimeController = TextEditingController(); // 운영 종료 시간
  final TextEditingController _galleryPhoneController = TextEditingController(); // 연락처
  final TextEditingController _galleryEmailController = TextEditingController(); // 이메일
  final TextEditingController _webSiteController = TextEditingController(); // 홈페이지
  final TextEditingController _galleryIntroduceController = TextEditingController(); // 소개
  bool allFieldsFilled = false; // 필수 입력 값을 입력하지 않으면 비활성화
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
    uploader = ImageUploader('gallery_images');
    settingText();
  }

  // 수정하는 경우에 저장된 값을 필드에 출력
  Future<void> settingText() async {
    if (widget.document != null) {
      Map<String, dynamic> data = getMapData(widget.document!);
      if (widget.document!.exists) {
        _galleryNameController.text = data['galleryName'] != null ? data['galleryName'] : '';
        _addrController.text = data['addr'] != null ? data['addr'] : '';
        _detailsAddressController.text = data['detailsAddress'] != null ? data['detailsAddress'] : '';
        _galleryCloseController.text = data['galleryClose'] != null ? data['galleryClose'] : '';
        _startTimeController.text = data['startTime'] != null ? data['startTime'] : '';
        _endTimeController.text = data['endTime'] != null ? data['endTime'] : '';
        _galleryPhoneController.text = data['galleryPhone'] != null ? data['galleryPhone'] : '';
        _galleryEmailController.text = data['galleryEmail'] != null ? data['galleryEmail'] : '';
        _webSiteController.text = data['webSite'] != null ? data['webSite'] : '';
        _galleryIntroduceController.text = data['galleryIntroduce'] != null ? data['galleryIntroduce'] : '';

        selectImgURL = await data['imageURL'];
        setState(() {
          allFieldsFilled = true; // 이미 정보를 입력한 사용자를 불러옴
        });
        print(selectImgURL);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      appBar: AppBar(
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '갤러리 정보 수정',
            style: TextStyle(
                color: Color.fromRGBO(70, 77, 64, 1.0),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
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
                                      child: _imageFile != null
                                          ? buildImageWidget(
                                            // 이미지 빌더 호출
                                            imageFile: _imageFile,
                                            imgPath: imgPath,
                                            selectImgURL: selectImgURL,
                                            defaultImgURL: 'assets/ex/ex1.png',
                                          )
                                          : (widget.document != null && selectImgURL != null)
                                            ? Image.network(selectImgURL!, width: 50, height: 50, fit: BoxFit.cover)
                                            : Image.asset('assets/ex/ex1.png', width: 50, height: 50, fit: BoxFit.cover),
                                    ),
                                    Text('갤러리 이미지', style: TextStyle(fontSize: 13),)
                                  ],
                                )
                            ),
                          ),
                          SizedBox(height: 30),
                          TextAndTextField('갤러리명', _galleryNameController, 'name'),
                          SizedBox(height: 30),
                          TextAndTextField('주소', _addrController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('상세주소', _detailsAddressController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('휴관일', _galleryCloseController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('시작시간', _startTimeController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('마감시간', _endTimeController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('연락처', _galleryPhoneController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('이메일', _galleryEmailController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('웹사이트', _webSiteController, 'englishName'),
                          SizedBox(height: 30),
                          TextAndTextField('소개', _galleryIntroduceController, 'introduce'),
                          SizedBox(height: 30),
                       ],
                    )
                  ),
                  // 추가
                  Container(
                      margin: EdgeInsets.all(20),
                      //child: submitButton()
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 텍스트 필드 값이 변경될 때마다 allFieldsFilled를 다시 계산하여 버튼의 활성화 상태를 업데이트
  void updateButtonState() async {
    setState(() {
      allFieldsFilled = _galleryNameController.text.isNotEmpty &&
          _addrController.text.isNotEmpty &&
          _detailsAddressController.text.isNotEmpty &&
          _galleryCloseController.text.isNotEmpty &&
          _startTimeController.text.isNotEmpty &&
          _endTimeController.text.isNotEmpty &&
          _galleryPhoneController.text.isNotEmpty &&
          _galleryEmailController.text.isNotEmpty &&
          _webSiteController.text.isNotEmpty &&
          _galleryIntroduceController.text.isNotEmpty;
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
          String region = (_addrController.text).split(' ')[0]; // _addrController.text = 서울 종로구 ... --> 서울
          formData['galleryName'] = _galleryNameController.text;
          formData['region'] = region;
          formData['addr'] = _addrController.text;
          formData['detailsAddress'] = _detailsAddressController.text;
          formData['galleryClose'] = _galleryCloseController.text;
          formData['startTime'] = _startTimeController.text;
          formData['endTime'] = _endTimeController.text;
          formData['galleryPhone'] = _galleryPhoneController.text;
          formData['galleryEmail'] = _galleryEmailController.text;
          formData['webSite'] = _webSiteController.text;
          formData['galleryIntroduce'] = _galleryIntroduceController.text;

          // 파이어베이스에 정보 및 이미지 저장
          if (widget.document != null && widget.document!.exists) { // 수정
            await updateGallery('gallery', widget.document!, formData);
            if (_imageFile != null) {
              await uploadImage();
              await updateImageURL('gallery', widget.document!.id, imageURL!, 'gallery_images');
            }
          } else { // 추가
            String documentId = await addGallery('gallery', formData);
            if (_imageFile != null) {
              await uploadImage();
              await updateImageURL('gallery', documentId!, imageURL!, 'gallery_images');
            }
          }

          setState(() {
            _saving = false;
          });

          // 저장 완료 메세지 띄우기. 스택을 쌓지 않고 리스트 페이지로 돌아감
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('성공적으로 저장되었습니다.'))
          );
          //Navigator.pop(context);
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GalleryListPage()),
          );
          //await showMoveDialog(context, '성공적으로 저장되었습니다.', () => ArtistList());
        } on FirebaseAuthException catch (e) {
          firebaseException(e);
        } catch (e) {
          print(e.toString());
        }
      } : null, // 버튼이 비활성 상태인 경우 onPressed를 null로 설정
      style: allFieldsFilled
          ? fullGreenButtonStyle()
          : ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey), // 모든 값을 입력했다면 그린 색상으로 활성화
      ),
      child: boldGreyButtonContainer('정보 저장'),
    );
  }
}
