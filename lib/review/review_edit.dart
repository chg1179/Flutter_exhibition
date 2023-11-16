import 'package:exhibition_project/review/review_detail.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../firebase_storage/image_upload.dart';
import '../model/user_model.dart';

class ReviewEdit extends StatefulWidget {
  final String? documentId;
  ReviewEdit({Key? key, this.documentId}) : super(key: key);

  @override
  _ReviewEditState createState() => _ReviewEditState();
}

class _ReviewEditState extends State<ReviewEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  final _customHashtagCtr = TextEditingController();
  int maxTitleLength = 100;
  List<String> _selectTag = [];
  List<Widget> textFields = [];
  List<Widget> imageFields = [];
  List<String> _tagList = [
    '전시',
    '설치미술',
    '온라인전시',
    '유화',
    '미디어',
    '사진',
    '조각',
    '특별전시',
  ];

  final ImageSelector selector = ImageSelector();
  late ImageUploader uploader;
  XFile? _imageFile;
  String? downloadURL;

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      _loadReviewData(widget.documentId!);
    }
  }

  late String _userNickName;

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      DocumentSnapshot _userDocument;

      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname'; // 닉네임이 없을 경우 기본값 설정
        print('닉네임: $_userNickName');
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  Future<void> _loadReviewData(String documentId) async {
    try {
      if (documentId.isNotEmpty) {
        final documentSnapshot =
        await FirebaseFirestore.instance.collection('review')
            .doc(documentId)
            .get();

        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final title = data['title'] as String;
          final content = data['content'] as String;
          final imageURL = data['imageURL'] as String?;

          setState(() {
            _titleCtr.text = title;
            _contentCtr.text = content;
            downloadURL = imageURL;
          });
          final CollectionReference reviewCollection = FirebaseFirestore
              .instance.collection('review');
          final QuerySnapshot hashtagQuery = await reviewCollection.doc(
              documentId).collection('hashtag').get();

          if (hashtagQuery.docs.isNotEmpty) {
            final List<String> selectedHashtags = [];

            for (final doc in hashtagQuery.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final hashtagName = data['tag_name'] as String;

              selectedHashtags.add(hashtagName);
            }

            setState(() {
              _selectTag = selectedHashtags;
            });
          }
        } else {
          print('리뷰를 찾을 수 없습니다.');
        }
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> updateHashtags(List<String> hashtags, String docId) async {
    final CollectionReference postsCollection = FirebaseFirestore.instance.collection('review');

    // 기존 해시태그 문서들을 모두 삭제
    final QuerySnapshot existingHashtags = await postsCollection.doc(docId).collection('hashtag').get();
    for (final doc in existingHashtags.docs) {
      await doc.reference.delete();
    }

    // 새로운 선택 해시태그를 추가
    for (String hashtag in hashtags) {
      final DocumentReference hashtagDocRef = postsCollection.doc(docId).collection('hashtag').doc();

      await hashtagDocRef.set({
        'tag_name': hashtag,
      });
    }
  }

  Future<void> addHashtags(List<String> hashtags, String docId) async {
    final CollectionReference reviewCollection = FirebaseFirestore.instance.collection('review');

    // 이미 존재하는 해시태그를 담을 Set
    final existingHashtags = Set<String>();

    // 기존 해시태그 조회
    final existingHashtagQuery = await reviewCollection.doc(docId).collection('hashtag').get();
    for (final doc in existingHashtagQuery.docs) {
      final data = doc.data();
      final hashtagName = data['tag_name'] as String;

      existingHashtags.add(hashtagName);
    }

    // 새로운 선택 해시태그를 추가
    for (String hashtag in hashtags) {
      if (!existingHashtags.contains(hashtag)) {
        final DocumentReference hashtagDocRef = reviewCollection.doc(docId).collection('hashtag').doc();

        // hashtag 문서가 이미 있는지 확인
        final hashtagSnapshot = await hashtagDocRef.get();
        if (!hashtagSnapshot.exists) {
          // hashtag 문서가 없으면 추가
          await hashtagDocRef.set({
            'tag_name': hashtag,
          });
        }
      }
    }
  }

  // 선택된 해시태그를 추가하는 함수
  void addSelectedTag(String tagName) {
    if (!_selectTag.contains(tagName)) {
      setState(() {
        _selectTag.add(tagName);
      });
      print('추가시 Selected Tags: $_selectTag'); // 로그로 확인
    }
  }


  // 선택된 해시태그를 제거하는 함수
  void removeSelectedTag(String tagName) {
    if (_selectTag.contains(tagName)) {
      setState(() {
        _selectTag.remove(tagName);
      });
      print('삭제시 Selected Tags: $_selectTag'); // 로그로 확인
    }
  }


  void addCustomHashtagToList() {
    if (_customHashtagCtr.text.isNotEmpty) {
      final customHashtag = _customHashtagCtr.text;

      if (!_selectTag.contains(customHashtag)) {
        addSelectedTag(customHashtag);
        addHashtags([customHashtag], widget.documentId ?? '');
      }

      _customHashtagCtr.text = '';
    }
  }

  Future<void> _saveReview() async {
    if (_titleCtr.text.isEmpty || _contentCtr.text.isEmpty) {
      _showDialog('제목과 내용을 입력해주세요');
      return;
    }

    if (_imageFile == null && (downloadURL == null || downloadURL!.isEmpty)) {
      _showDialog('이미지를 등록해주세요');
      return;
    }

    CollectionReference review = FirebaseFirestore.instance.collection("review");

    if (_imageFile != null) {
      try {
        await uploadImage();
      } catch (e) {
        print('이미지 업로드 중 오류 발생: $e');
        _showDialog('이미지 업로드 중 오류가 발생했습니다');
        return;
      }
    }

    try {
      if (widget.documentId != null) {
        await review.doc(widget.documentId!).update({
          'title': _titleCtr.text,
          'content': _contentCtr.text,
          if(downloadURL != null && _imageFile == null) 'imageURL' : downloadURL
        });

        // 기존 해시태그 삭제
        await updateHashtags(_selectTag, widget.documentId!);

        // 수정 완료 다이얼로그
        _showEditDialog('후기가 수정되었습니다.');
      } else {
        await _loadUserData();

        DocumentReference newReviewRef = await review.add({
          'title': _titleCtr.text,
          'content': _contentCtr.text,
          'write_date': DateTime.now(),
          'imageURL': downloadURL,
          'viewCount': 0,
          'likeCount': 0,
          'userNickName': _userNickName,
        });

        String reviewDocumentId = newReviewRef.id;

        if (downloadURL != null) {
          await newReviewRef.update({'imageURL': downloadURL});
        }

        // 새로운 선택 해시태그 추가
        await addHashtags(_selectTag, reviewDocumentId);

        // 등록 완료 다이얼로그
        _showEditDialog('후기가 등록되었습니다.');
      }



      _titleCtr.clear();
      _contentCtr.clear();
      _imageFile = null;

    } catch (e) {
      print('데이터 저장 중 오류가 발생했습니다: $e');
    }
  }



  Future<void> getImage() async {
    XFile? pickedFile = await selector.selectImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      print('이미지가 선택되지 않음');
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile != null) {
      try {
        final uploader = ImageUploader('review_images');
        downloadURL = await uploader.uploadImage(_imageFile!);
        print('Uploaded to Firebase Storage: $downloadURL');
      } catch (e) {
        print('이미지 업로드 중 오류 발생: $e');
      }
    } else {
      print('이미지를 선택하지 않았습니다.');
      downloadURL = null;
    }
  }

  Widget _selectTagForm() {
    if(_selectTag.length > 0){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('나의 태그', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 8,),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: _selectTag.map((selectTag) {
              return Wrap(
                spacing: 2,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0xff464D40),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '#$selectTag',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      removeSelectedTag(selectTag);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xffD4D8C8),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.clear,
                          size: 10,
                          color: Color(0xff464D40),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    }else{
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('나의 태그', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 5,),
          Text("태그를 입력 또는 선택해주세요.", style: TextStyle(color: Colors.grey, fontSize: 12),),
        ],
      );
    }
  }

  ButtonStyle _unPushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 13,
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xff464D40)),
        ),
      ),
    );
  }

  ButtonStyle _pushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xff464D40)),
        ),
      ),
    );
  }

  Widget _hashTagList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('추천 태그', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text('태그를 선택하거나 입력해주세요. (최대 30개)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        Wrap(
            spacing: 4,
            runSpacing: -9,
            children: _tagList.map((tagName) {
              return ElevatedButton(
                child: Text('#$tagName'),
                onPressed: () {
                  setState(() {
                    if (_selectTag.contains(tagName)) {
                      // 선택 해제된 해시태그를 제거
                      removeSelectedTag(tagName);
                    } else {
                      // 선택된 해시태그를 추가
                      addSelectedTag(tagName);
                    }
                  });
                },
                style: _selectTag.contains(tagName) ? _pushBtnStyle() : _unPushBtnStyle(),
              );
            }).toList()
        ),
      ],
    );
  }

  // 태그 입력 폼
  Widget _buildCustomHashtagInput() {
    return Container(
      height: 40,
      child: TextField(
        controller: _customHashtagCtr,
        decoration: InputDecoration(
          hintText: '# 직접 태그를 입력해보세요!',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 13,
          ),
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff464D40))
          )
        ),
        cursorColor: Color(0xff464D40),
      ),
    );
  }

  Widget buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
              child: _buildTitleInput(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: _buildDivider(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _buildSelectedImage(),
                      Positioned(
                        top: 1,
                        right: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _imageFile = null;
                              downloadURL = null;
                            });
                          },
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Color(0xffD4D8C8),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(Icons.clear, size: 10, color: Color(0xff464D40)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
              child: _buildContentInput(),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10,  top: 5),
              child: _hashTagList(),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, ),
              child: _selectTagForm(),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomHashtagInput(),
                  SizedBox(height: 5),
                  ElevatedButton(
                    child: Text('추 가', style: TextStyle(fontSize: 15),),
                    onPressed: addCustomHashtagToList,
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size( MediaQuery.of(context).size.width, 40)),
                      backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Color(0xff464D40)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSelectedImage() {
    if (_imageFile != null) {
      return  Image.file(
        File(_imageFile!.path),
        width: MediaQuery.of(context).size.width,
        height: 400,
        fit: BoxFit.cover,
      );
    } else if (downloadURL != null && downloadURL!.isNotEmpty) {
      return Image.network(
        downloadURL!,
        width: MediaQuery.of(context).size.width,
        height: 400,
        fit: BoxFit.cover,
      );
    } else {
      // 이미지가 선택되지 않은 경우에는 빈 컨테이너 반환
      return Container();
    }
  }


  Widget _buildTitleInput() {
    return TextField(
      controller: _titleCtr,
      maxLines: null,
      decoration: InputDecoration(
        hintText: '제목을 입력해주세요.',
        hintStyle: TextStyle(
          color: Colors.black38,
          fontSize: 18,
        ),
        border: InputBorder.none,
      ),
      onChanged: (text){
        if(text.length > 100){
          _showMaxLengthExceededDialog();
        }
      },
    );
  }

  void _showMaxLengthExceededDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('제목은 100자 이하로 입력해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인', style: TextStyle(color: Color(0xff464D40))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.black12,
    );
  }

  Widget _buildImgButton() {
    return InkWell(
      onTap: getImage,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Color(0xffD4D8C8),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Icon(Icons.image_rounded, color: Colors.black26, size: 20),
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return TextField(
      maxLines: 15,
      controller: _contentCtr,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: '내용을 입력해주세요.',
        hintStyle: TextStyle(
          color: Colors.black38,
          fontSize: 14,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return TextButton(
      onPressed: () {
        _saveReview();
      },
      child: Text(
        widget.documentId != null ? '수정' : '등록',
        style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showDialog(String txt) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(txt),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인',  style: TextStyle(color: Color(0xff464D40))),
            )
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(String txt) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(txt),
          actions: [
            TextButton(
              onPressed: () {
                if (widget.documentId != null) {
                   Navigator.of(context).pop();
                   Navigator.of(context).pop();
                } else {
                  // 등록 버튼일 경우 ReviewList 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewList()),
                  );
                }
              },
              child: Text('확인',  style: TextStyle(color: Color(0xff464D40))),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.documentId != null ? '글 수정' : '글 작성',
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
        actions: [
          _buildSubmitButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: buildReviewForm(),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 1, // 라인의 높이 설정
              child: Container(
                color: Colors.black12, // 라인의 색상 설정
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  _buildImgButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
