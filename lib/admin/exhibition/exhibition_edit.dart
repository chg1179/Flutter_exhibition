import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firebase_storage/img_upload.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ExhibitionEditPage extends StatelessWidget {
  final DocumentSnapshot? document;
  const ExhibitionEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return ExhibitionEdit(document: document);
  }
}

class ExhibitionEdit extends StatefulWidget {
  final DocumentSnapshot? document;
  const ExhibitionEdit({super.key, required this.document});

  @override
  State<ExhibitionEdit> createState() => _ExhibitionEditState();
}

class _ExhibitionEditState extends State<ExhibitionEdit> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  final TextEditingController _exTitleController = TextEditingController(); // 갤러리명
  bool allFieldsFilled = false; // 필수 입력 값을 입력하지 않으면 비활성화
  Map<String, String> formData = {}; // 컨테이너에 값을 넣어 파라미터로 전달
  final ImageSelector selector = ImageSelector();//이미지
  late ImageUploader uploader;
  XFile? _imageFile;
  String? imageURL;
  String? imgPath;
  String? selectImgURL;
  bool _saving = false; // 저장 로딩
  String selectedArtist = '작가1'; // 기본 선택 옵션


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
        _exTitleController.text = data['exTitle'] != null ? data['exTitle'] : '';

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
            '전시회 정보 수정',
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
                                    Text('전시회 이미지', style: TextStyle(fontSize: 13),),
                                    DropdownButton<String>(
                                      value: selectedArtist,
                                      items: <String>['작가1', '작가2', '작가3'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedArtist = newValue!;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    Text('선택된 옵션: $selectedArtist'),
                                  ],
                                )
                            ),
                          ),
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
}
