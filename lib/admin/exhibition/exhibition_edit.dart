import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firebase_storage/image_upload.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:exhibition_project/widget/text_and_textfield.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

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
  Map<String, String> artistData = {}; // 선택할 작가 리스트
  String? selectedArtist; // 작가 기본 선택 옵션
  Map<String, dynamic>? exhibitionData; // 전시회 상세 정보
  String? artistName; // 작가의 이름
  final TextEditingController _exTitleController = TextEditingController(); // 전시회명
  final TextEditingController _phoneController = TextEditingController(); // 전화번호
  final TextEditingController _webSiteController = TextEditingController();
  final TextEditingController _contentController = TextEditingController(); // 전시회설명
  List<List<TextEditingController>> feeControllers = [
    [TextEditingController(), TextEditingController()]
  ];

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
    _init();
    settingText();
    uploader = ImageUploader('exhibition_images');
  }

  // 동기 맞추기
  void _init() async{
    setState(() {
      _exTitleController.addListener(updateButtonState);
    });
  }

  // 작가 리스트 옵션 세팅
  void settingArtistOption() async {
    artistData = await getArtistData(); // Firestore에서 작가 이름과 문서 ID를 가져와 맵에 저장
    if(artistData.isNotEmpty) {
      setState(() {
        if (artistData.isNotEmpty && widget.document == null) {
          selectedArtist = '해당없음'; // 첫 번째 작가를 선택한 작가로 설정
        } else if (widget.document != null) {
          if (widget.document!['artistNo'] != null && widget.document!['artistNo'] != '') {
            selectedArtist = artistName;
            print('작가명: $selectedArtist');
          }
        }
      });
    }
  }

  // 작가 리스트 가져오기
  Future<Map<String, String>> getArtistData() async {
    try {
      QuerySnapshot artistSnapshot = await FirebaseFirestore.instance.collection('artist').orderBy('artistName', descending: false).get();

      if (artistSnapshot.docs.isNotEmpty) {
        for (var doc in artistSnapshot.docs) {
          artistData[doc['artistName']] = doc.id;
        }
      }
    } catch (e) {
      print('Error fetching artist data: $e'); // 오류 발생 시 처리
    }
    artistData['해당없음'] = ''; // 선택할 작가가 없는 경우를 나타내는 옵션
    return artistData;
  }

  // 수정하는 경우에 저장된 값을 필드에 출력
  Future<void> settingText() async {
    settingArtistOption(); // 작가 리스트 설정
    setExhibitionData();

    if (widget.document != null) {
      Map<String, dynamic> data = getMapData(widget.document!);
      if (widget.document!.exists) {
        _exTitleController.text = data['exTitle'] != null ? data['exTitle'] : '';
        _phoneController.text = data['phone'] != null ? data['phone'] : '';
        _webSiteController.text = data['webSite'] != null ? data['webSite'] : '';
        _contentController.text = data['content'] != null ? data['content'] : '';
        await settingTextList('exhibition', 'exhibition_fee', feeControllers, widget.document!.id, 'update', 'exFee', 'exKind');
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

  // 전시회, 작가 정보 가져오기
  void setExhibitionData() async {
    if(widget.document != null) {
      exhibitionData = getMapData(widget.document!);
      if (exhibitionData != null && exhibitionData!['artistNo'] != null && exhibitionData!['artistNo'] != '') {
        getArtistName(exhibitionData!['artistNo']);
      }
    }
  }

  // 전시회 컬렉션 안에 있는 작가의 문서 id를 이용하여 작가 이름 가져오기
  void getArtistName(String documentId) async {
    DocumentSnapshot artistDocument = await FirebaseFirestore.instance.collection('artist').doc(documentId).get();
    if (artistDocument.exists) {
      artistName = artistDocument.get('artistName');
      setState(() {
        print('Artist Name: $artistName');
      });
    } else { // 작가 컬렉션에서 문서 id가 일치하는 작가가 없을 경우
      artistName = '해당없음';
      print('Document not found');
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
          child: Text('전시회 정보 관리', style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0), fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        child: Center(
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(20),
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
                                            defaultImgURL: 'assets/logo/basic_logo.png',
                                          )
                                          : (widget.document != null && selectImgURL != null)
                                          ? Image.network(selectImgURL!, width: 50, height: 50, fit: BoxFit.cover)
                                          : Image.asset('assets/logo/basic_logo.png', width: 50, height: 50, fit: BoxFit.cover),
                                    ),
                                    Text('전시회 이미지', style: TextStyle(fontSize: 13),),
                                  ],
                                )
                            ),
                          ),
                          SizedBox(height: 30),
                          SizedBox(height: 30),
                          TextAndTextField('전시회명', _exTitleController, 'exTitle'),
                          SizedBox(height: 30),
                          TextAndTextField('전화번호', _phoneController, 'phone'),
                          SizedBox(height: 30),
                          TextAndTextField('전시페이지', _webSiteController, 'webSite'),
                          SizedBox(height: 30),
                          TextAndTextField('전시회설명', _contentController, 'introduce'),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              textFieldLabel('작가'),
                              DropdownButton<String>(
                                value: selectedArtist,
                                items: artistData.keys.map((String value) {
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
                            ],
                          ),
                          SizedBox(height: 20),
                          Text('선택된 옵션: $selectedArtist'),
                          textControllerBtn(context, '입장료', '금액', '대상', feeControllers, () {
                            setState(() {
                              feeControllers.add([TextEditingController(), TextEditingController()]);
                            });
                          }, (int i) {
                            setState(() {
                              feeControllers.removeAt(i);
                            });
                          },
                          ),
                          ElevatedButton(
                            onPressed: () async {

                              DateTime? _dateTime = DateTime.now();

                              initializeTimeZones(); // 타임스탬프를 위한 타임존 데이터

                              var seoul = getLocation('Asia/Seoul');  // 서울의 타임존 데이터

                              // 서울의 타임존을 가지는 TZDateTime으로 변환
                              var selectedDate = TZDateTime.from(_dateTime, seoul);

                              // DateTime을 Firestore Timestamp로 변환
                              var firestoreTimestamp = Timestamp.fromDate(selectedDate);

                              print(_dateTime);
                              // Firestore에 타임스탬프 추가
                              await  FirebaseFirestore.instance.collection('test').add({
                                'testTime': firestoreTimestamp,
                              });
                            },
                            child: Text("타임스탬프"),
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

  void updateButtonState() async {
    setState(() {
      allFieldsFilled = _exTitleController.text.isNotEmpty &&
          _contentController.text.isNotEmpty;
    });
  }
}
