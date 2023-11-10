import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/exhibition/exhibition_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firebase_storage/image_upload.dart';
import 'package:exhibition_project/firestore_connect/exhibition_query.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/firestore_connect/user_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:exhibition_project/widget/text_and_textfield.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Map<String, dynamic>? exhibitionData; // 전시회 상세 정보
  Map<String, String> artistData = {}; // 선택할 작가 리스트
  Map<String, String> galleryData = {}; // 선택할 갤러리 리스트
  String? selectedArtist; // 작가 기본 선택 옵션
  String? selectedGallery; // 갤러리 기본 선택 옵션
  String? artistName; // 작가명
  String? galleryName; // 갤러리명

  final TextEditingController _exTitleController = TextEditingController(); // 전시회명
  final TextEditingController _phoneController = TextEditingController(); // 전화번호
  final TextEditingController _exPageController = TextEditingController();
  final TextEditingController _contentController = TextEditingController(); // 전시회설명
  List<List<TextEditingController>> feeControllers = [
    [TextEditingController(), TextEditingController()]
  ];
  DateTime? _startDate; // 전시 시작 날짜
  DateTime? _endDate; // 전시 종료 날짜
  
  bool allFieldsFilled = false; // 필수 입력 값을 입력하지 않으면 비활성화
  Map<String, String> formData = {}; // 컨테이너에 값을 넣어 파라미터로 전달
  final ImageSelector selector = ImageSelector();//이미지
  late ImageUploader uploader;
  XFile? _imageFile;
  XFile? _imageContentFile;
  String? imageURL;
  String? imageContentURL;
  String? imgPath;
  String? imgContentPath;
  String? selectImgURL;
  String? selectContentImgURL;
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

  // 수정하는 경우에 저장된 값을 필드에 출력
  Future<void> settingText() async {
    settingCollectionOption(); // 작가, 갤러리 리스트 설정
    setExhibitionData();

    if (widget.document != null) {
      Map<String, dynamic> data = getMapData(widget.document!);
      if (widget.document!.exists) {
        _exTitleController.text = data['exTitle'] != null ? data['exTitle'] : '';
        _phoneController.text = data['phone'] != null ? data['phone'] : '';
        _exPageController.text = data['exPage'] != null ? data['exPage'] : '';
        _contentController.text = data['content'] != null ? data['content'] : '';
        await settingTextList('exhibition', 'exhibition_fee', feeControllers, widget.document!.id, 'update', 'exFee', 'exKind');

        // 운영 날짜 받아오기
        Timestamp startDateTimestamp = exhibitionData!['startDate']; // Firestore에서 가져온 Timestamp
        Timestamp endDateTimestamp = exhibitionData!['endDate'];
        _startDate = startDateTimestamp.toDate(); // Timestamp를 Dart의 DateTime으로 변환
        _endDate = endDateTimestamp.toDate();

        selectImgURL = await data['imageURL'];
        selectContentImgURL = await data['cotentURL'];
        setState(() {
          allFieldsFilled = true; // 이미 정보를 입력한 사용자를 불러옴
        });
        print('기존 정보를 수정합니다.');
      } else {
        print('새로운 정보를 추가합니다.');
      }
    }
  }

  // 작가 리스트 옵션 세팅
  void settingCollectionOption() async {
    artistData = await getCollectionData('artist', 'artistName'); // Firestore에서 작가 이름과 문서 ID를 가져와 맵에 저장
    galleryData = await getCollectionData('gallery', 'galleryName');
    if (artistData.isNotEmpty) {
      setState(() {
        if (widget.document == null) {
          // 데이터를 추가할 때, 해당 없음으로 설정
          selectedArtist = '해당없음';
        } else if (widget.document != null) {
          // 데이터를 수정
          if (widget.document!['artistNo'] != null && widget.document!['artistNo'] != '') {
            selectedArtist = artistName; // 일치하는 작가를 찾아 설정
          } else {
            selectedArtist = '해당없음'; // 선택된 작가가 없다면 해당 없음으로 설정
          }
        }
      });
    }
    if (galleryData.isNotEmpty) {
      setState(() {
        if (widget.document == null) {
          // 데이터를 추가할 때, 해당 없음으로 설정
          selectedGallery = galleryData.keys.first; // 기본으로 첫 번째 갤러리를 선택
        } else if (widget.document != null) {
          selectedGallery = galleryName;
        }
      });
    }
  }

  // 작가 리스트 가져오기
  Future<Map<String, String>> getCollectionData(String collectionName, String fieldName) async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance.collection(collectionName).orderBy(fieldName, descending: false).get();

      if (snap.docs.isNotEmpty) {
        for (var doc in snap.docs) {
          if(collectionName == 'artist')
            artistData[doc[fieldName]] = doc.id;
          else if(collectionName == 'gallery')
            galleryData[doc[fieldName]] = doc.id;
        }
      }
    } catch (e) {
      print('Error fetching artist data: $e'); // 오류 발생 시 처리
    }
    artistData['해당없음'] = ''; // 선택할 작가가 없는 경우를 나타내는 옵션을 push
    if(collectionName == 'artist')
      return artistData;
    else
      return galleryData;
  }

  // 전시회의 작가와 갤러리 정보 가져오기
  void setExhibitionData() async {
    if(widget.document != null) {
      exhibitionData = getMapData(widget.document!);
      print(exhibitionData!['galleryNo']);
      if (exhibitionData != null && exhibitionData!['artistNo'] != null && exhibitionData!['artistNo'] != '') {
        getFieldName(exhibitionData!['artistNo'], 'artist', 'artistName');
      }
      if (exhibitionData != null && exhibitionData!['galleryNo'] != null && exhibitionData!['galleryNo'] != '') {
        getFieldName(exhibitionData!['galleryNo'], 'gallery', 'galleryName');
      }
    }
  }

  // 전시회 컬렉션 안에 있는 문서 id를 이용하여 이름 가져오기
  void getFieldName(String documentId, String collectionName, String fieldName) async {
    DocumentSnapshot nameDocument = await FirebaseFirestore.instance.collection(collectionName).doc(documentId).get();
    if (nameDocument.exists) {
      if(collectionName == 'artist')
        artistName = nameDocument.get(fieldName);
      else if(collectionName == 'gallery')
        galleryName = nameDocument.get(fieldName);
    } else { // 다른 컬렉션에서 문서 id가 일치하는 정보가 없을 경우
      if(collectionName == 'artist')
        artistName = '해당없음';
      else if(collectionName == 'gallery')
        galleryName = galleryData.keys.first;
      print('Document not found');
    }
  }

  // 이미지 가져오기
  Future<void> getImage(String kind) async {
    XFile? pickedFile = await selector.selectImage();
    if (pickedFile != null) {
      setState(() {
        if(kind == 'image') {
          _imageFile = pickedFile;
          imgPath = pickedFile.path;
        } else if(kind == 'contentImage'){
          _imageContentFile = pickedFile;
          imgContentPath = pickedFile.path;
        }
      });
    } else {
      print('No image selected.');
    }
  }

  // 이미지 추가
  Future<void> uploadImage(String kind) async {
    if(kind == 'image') {
      if (_imageFile != null) {
        imageURL = await uploader.uploadImage(_imageFile!);
        print('Uploaded to Firebase Storage: $imageURL');
      } else {
        print('No image selected.');
      }
    } else if(kind == 'contentImage'){
      if (_imageContentFile != null) {
        imageContentURL = await uploader.uploadImage(_imageContentFile!);
        print('Uploaded content to Firebase Storage: $imageContentURL');
      } else {
        print('No image selected.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      appBar: AppBar(
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Text('전시회 정보 관리', style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff464D40),),
          onPressed: (){
            Navigator.pop(context);
          },
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
                                onTap: (){
                                  getImage('image');
                                }, // 이미지를 선택하는 함수 호출
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
                                          ? Image.asset('assets/logo/basic_logo.png', width: 130, height: 130, fit: BoxFit.cover)//Image.network(selectImgURL!, width: 50, height: 50, fit: BoxFit.cover)
                                          : Image.asset('assets/logo/basic_logo.png', width: 130, height: 130, fit: BoxFit.cover),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          SizedBox(height: 30),
                          TextAndTextField('전시회명', _exTitleController, 'exTitle'),
                          SizedBox(height: 30),
                          if(selectedGallery != null)
                            buildDropdownRow('갤러리', selectedGallery!, galleryData, (String newValue) {
                              selectedGallery = newValue;
                            }),
                          SizedBox(height: 30),
                          if(selectedArtist != null)
                            buildDropdownRow('작가', selectedArtist!, artistData, (String newValue) {
                              selectedArtist = newValue;
                            }),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              textFieldLabel('전시일정'),
                              ElevatedButton(
                                onPressed: () {
                                  _selectDateRange(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xffdededc)), // 배경색
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // 텍스트 색상
                                  side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 1, color: Color(0xff464D40))), // 테두리 속성 추가
                                  elevation: MaterialStateProperty.all<double>(0),
                                ),
                                child: Text(
                                  _startDate != null && _endDate != null
                                      ? '${_startDate.toString().split(" ")[0]} ~ ${_endDate.toString().split(" ")[0]}'
                                      : '날짜 선택', style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          TextAndTextField('전화번호', _phoneController, 'phone'),
                          SizedBox(height: 30),
                          TextAndTextField('전시 페이지', _exPageController, 'exPage'),
                          SizedBox(height: 30),
                          TextAndTextField('전시회 설명', _contentController, 'introduce'),
                          SizedBox(height: 30),
                          textControllerBtn(context, '입장료', '금액', '대상', feeControllers, () {
                            setState(() {
                              feeControllers.add([TextEditingController(), TextEditingController()]);
                            });
                          }, (int i) {
                            setState(() {
                              feeControllers.removeAt(i);
                            });
                          }),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              textFieldLabel('상세이미지'),
                              ElevatedButton(
                                onPressed: (){
                                  getImage('contentImage');
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xffdededc)), // 배경색
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // 텍스트 색상
                                  side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 1, color: Color(0xff464D40))), // 테두리 속성 추가
                                  elevation: MaterialStateProperty.all<double>(0),
                                ),
                                child:  _imageContentFile != null
                                    ? buildImageWidget(
                                      // 이미지 빌더 호출
                                      imageFile: _imageContentFile,
                                      imgPath: imgContentPath,
                                      selectImgURL: selectContentImgURL,
                                      defaultImgURL: 'assets/logo/green_logo.png',
                                    )
                                    : (widget.document != null && selectContentImgURL != null)
                                      ? Image.asset('assets/logo/basic_logo.png', width: double.infinity, fit: BoxFit.cover)//Image.network(selectContentImgURL!, width: double.infinity, height: 50, fit: BoxFit.cover)
                                      : Text('이미지 선택'),
                              ),
                            ],
                          ),
                        ],
                      )
                  ),
                  // 추가
                  Container(
                    margin: EdgeInsets.only(right: 20, left: 20, bottom: 30, top: 10),
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

  // 옵션 선택
  Row buildDropdownRow(String label, String value, Map<String, dynamic> data, void Function(String) onChanged) {
    return Row(
      children: [
        textFieldLabel(label),
        DropdownButton<String>(
          value: value,
          items: data.keys.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              onChanged(newValue!);
            });
          },
        ),
      ],
    );
  }
  
  // 운영 시작 날짜와 종료 날짜를 선택
  void _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate?? DateTime.now(),
      end: _endDate ?? DateTime.now(),
    );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: initialDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color.fromRGBO(70, 77, 64, 1.0), // 달력의 기본 색상
            colorScheme: ColorScheme.light(primary: Color.fromRGBO(70, 77, 64, 1.0)), // 일주일의 헤더 색상
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange == null) return; // 사용자가 선택하지 않은 경우

    setState(() {
      _startDate = newDateRange.start;
      _endDate = newDateRange.end;
      updateButtonState();
    });
  }

  void updateButtonState() async {
    setState(() {
      allFieldsFilled = _exTitleController.text.isNotEmpty &&
          _startDate != null &&
          _endDate != null;
    });
  }

  // 입력된 세부 정보 추가
  Future<void> addDetails(List<List<TextEditingController>> controllers, String parentCollection, String documentId, String childCollection) async {
    for (var i = 0; i < controllers.length; i++) {
      String exFee = controllers[i][0].text;
      String exKind = controllers[i][1].text;
      if (exFee.isNotEmpty && exKind.isNotEmpty) {
        await addExhibitionDetails(parentCollection, documentId, childCollection, exFee, exKind);
      }
    }
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
          formData['exTitle'] = _exTitleController.text;
          formData['phone'] = _phoneController.text;
          formData['exPage'] = _exPageController.text;
          formData['content'] = _contentController.text;
          String? selectedArtistValue = artistData[selectedArtist]; // 선택된 작가 옵션
          String? selectedgalleryValue = galleryData[selectedGallery]; // 선택된 갤러리 옵션
          if(selectedArtistValue != null)
            formData['artistNo'] = selectedArtistValue!;
          if(selectedgalleryValue != null)
            formData['galleryNo'] = selectedgalleryValue!;

          // 파이어베이스에 정보 및 이미지 저장
          if (widget.document != null && widget.document != '' && widget.document!.exists) { // 수정
            await updateExhibition('exhibition', widget.document!, formData, _startDate!, _endDate!);
            
            // 수정하는 경우에 기존에 있던 하위 컬렉션의 정보를 삭제하고 업데이트된 내용을 삽입
            await deleteSubCollection('exhibition', widget.document!.id, 'exhibition_fee');
            // 입력한 하위 컬렉션 삽입
            if(feeControllers.isNotEmpty) await addDetails(feeControllers, 'exhibition', widget.document!.id, 'exhibition_fee'); //추가
            
            // 이미지 변경
            if (_imageFile != null) {
              await uploadImage('image');
              await updateImageURL('exhibition', widget.document!.id, imageURL!, 'exhibition_images');
            }
            if (_imageContentFile != null) {
              await uploadImage('contentImage');
              await updateImageURL('exhibition', widget.document!.id, imageURL!, 'exhibition_images');
            }
          } else { // 추가
            String documentId = await addExhibition('exhibition', formData, _startDate!, _endDate!);
            // 입력한 하위 컬렉션 삽입
            if(feeControllers.isNotEmpty) await addDetails(feeControllers, 'exhibition', documentId, 'exhibition_fee'); //추가
            
            // 이미지 업로드
            if (_imageFile != null) {
              await uploadImage('image');
              await updateImageURL('exhibition', documentId, imageContentURL!, 'exhibition_images');
              if (_imageContentFile != null) {
                await uploadImage('contentImage');
                await updateImageURL('exhibition', widget.document!.id, imageURL!, 'exhibition_images');
              }
            }
          }


          setState(() {
            _saving = false;
          });

          // 저장 완료 메세지
          Navigator.of(context).pop();
          await showMoveDialog(context, '성공적으로 저장되었습니다.', () => ExhibitionList());
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