import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artwork/artwork_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firebase_storage/image_upload.dart';
import 'package:exhibition_project/firestore_connect/artist_artwork_query.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/firestore_connect/user_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/image_widgets.dart';
import 'package:exhibition_project/widget/text_and_textfield.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ArtworkEditPage extends StatelessWidget {
  final DocumentSnapshot? parentDocument;
  final Map<String, dynamic>? childData;
  const ArtworkEditPage({super.key, required this.parentDocument, required this.childData});

  @override
  Widget build(BuildContext context) {
    return ArtworkEdit(parentDocument: parentDocument, childData: childData);
  }
}

class ArtworkEdit extends StatefulWidget {
  final DocumentSnapshot? parentDocument;
  final Map<String, dynamic>? childData;
  const ArtworkEdit({super.key, required this.parentDocument, required this.childData});

  @override
  State<ArtworkEdit> createState() => _ArtworkEditState();
}

class _ArtworkEditState extends State<ArtworkEdit> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  Map<String, String> artistData = {}; // 선택할 작가 리스트
  String? selectedArtist; // 기본 선택 옵션
  final TextEditingController _artTitleController = TextEditingController(); // 갤러리명
  final TextEditingController _artDateController = TextEditingController(); // 주소
  final TextEditingController _artTypeAddressController = TextEditingController(); // 상세주소
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
    uploader = ImageUploader('artwork_images');
  }

  // 동기 맞추기
  void _init() async{
    setState(() {
      _artTitleController.addListener(updateButtonState);
      _artDateController.addListener(updateButtonState);
      _artTypeAddressController.addListener(updateButtonState);
    });
  }

  Future<void> settingText() async {
    settingArtistOption(); // 작가 리스트 설정

    // 수정하는 경우에 저장된 값을 필드에 출력
    if (widget.parentDocument != null && widget.childData != null) {
      Map<String, dynamic> parentData = getMapData(widget.parentDocument!);
      if (widget.parentDocument!.exists && widget.childData!.isNotEmpty) {
        _artTitleController.text = widget.childData!['artTitle'];
        _artDateController.text = widget.childData!['artDate'];
        _artTypeAddressController.text = widget.childData!['artType'];
        selectImgURL = await widget.childData!['imageURL'];
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

  // 작가 리스트 옵션 세팅
  void settingArtistOption() async {
    artistData = await getArtistData(); // Firestore에서 작가 이름과 문서 ID를 가져와 맵에 저장
    setState(() {
      if (artistData.isNotEmpty && widget.parentDocument == null) {
        selectedArtist = artistData.keys.first; // 첫 번째 작가를 선택한 작가로 설정
      } else if(widget.parentDocument != null){
        String? artistName = widget.parentDocument!['artistName'];
        selectedArtist = artistName;
        print('작가명: $selectedArtist');

      }
    });
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
    return artistData;
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
            '작품 정보 관리',
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
                                        defaultImgURL: 'assets/logo/basic_logo.png',
                                      )
                                          : (widget.childData != null && selectImgURL != null)
                                          ? Image.network(selectImgURL!, width: 50, height: 50, fit: BoxFit.cover)
                                          : Image.asset('assets/logo/basic_logo.png', width: 50, height: 50, fit: BoxFit.cover),
                                    ),
                                    Text('작품 이미지', style: TextStyle(fontSize: 13),)
                                  ],
                                )
                            ),
                          ),
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
                          SizedBox(height: 30),
                          TextAndTextField('작품명', _artTitleController, 'artTitle'),
                          SizedBox(height: 30),
                          TextAndTextField('제작 연도', _artDateController, 'artDate'),
                          SizedBox(height: 30),
                          TextAndTextField('타입', _artTypeAddressController, 'artType'),
                          SizedBox(height: 30),
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

  // 텍스트 필드 값이 변경될 때마다 allFieldsFilled를 다시 계산하여 버튼의 활성화 상태를 업데이트
  void updateButtonState() async {
    setState(() {
      allFieldsFilled = _artTitleController.text.isNotEmpty &&
          _artDateController.text.isNotEmpty &&
          _artTypeAddressController.text.isNotEmpty;
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

          // 입력된 정보
          String? selectedArtistValue = artistData[selectedArtist]; // 선택된 작가 옵션
          formData['artTitle'] = _artTitleController.text;
          formData['artDate'] = _artDateController.text;
          formData['artType'] = _artTypeAddressController.text;

          // 파이어베이스에 정보 및 이미지 저장
          if (widget.parentDocument != null && widget.childData != null && widget.parentDocument!.exists && widget.childData!.isNotEmpty) {
            String parentDocumentId =  widget.parentDocument!.toString(); // 기존의 작가 정보를 받아옴
            // 정보 수정
            if(selectedArtistValue != widget.parentDocument!.id){
              // 작가를 변경했을 경우, 기존 정보를 삭제하고 새로 추가
              deleteArtistArtwork('artist', widget.parentDocument!.id, 'artist_artwork', widget.childData!['documentId']); // 해당 내역 삭제
              String childDocumentId = await addArtistArtwork('artist', selectedArtistValue!, 'artist_artwork', formData);
              if (_imageFile != null) {
                await uploadImage();
                await updateChildImageURL('artist', selectedArtistValue!, 'artist_artwork', childDocumentId, imageURL!, 'artwork_images');
              }
            } else {
              // 동일한 작가를 선택했을 경우, 기존 정보를 수정
              String childDocumentId = widget.childData!['documentId']!.toString();
              await updateArtistArtwork('artist', selectedArtistValue!, 'artist_artwork', childDocumentId, formData);
              if (_imageFile != null) {
                await uploadImage();
                await updateChildImageURL('artist', selectedArtistValue!, 'artist_artwork', childDocumentId, imageURL!, 'artwork_images');
              }
            }
          } else {
            // 정보 추가
            String childDocumentId = await addArtistArtwork('artist', selectedArtistValue!, 'artist_artwork', formData);
            if (_imageFile != null) {
              await uploadImage();
              await updateChildImageURL('artist', selectedArtistValue!, 'artist_artwork', childDocumentId, imageURL!, 'artwork_images');
            }
          }

          setState(() {
            _saving = false;
          });

          // 저장 완료 메세지
          Navigator.of(context).pop();
          await showMoveDialog(context, '성공적으로 저장되었습니다.', () => ArtworkList());
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
