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
  bool _showCustomHashtagInput = false;

  List<String> _selectTag = [];
  List<Widget> textFields = [];
  List<Widget> imageFields = [];

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
      final documentSnapshot =
      await FirebaseFirestore.instance.collection('review').doc(documentId).get();

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
      } else {
        print('리뷰를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _loadHashtags(String postId) async {
    final CollectionReference postsCollection = FirebaseFirestore.instance.collection('post');
    final QuerySnapshot hashtagQuery = await postsCollection.doc(postId).collection('hashtag').get();

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
  }

  Future<void> updateHashtags(List<String> hashtags, String postId) async {
    final CollectionReference postsCollection = FirebaseFirestore.instance.collection('post');

    // 기존 해시태그 문서들을 모두 삭제
    final QuerySnapshot existingHashtags = await postsCollection.doc(postId).collection('hashtag').get();
    for (final doc in existingHashtags.docs) {
      await doc.reference.delete();
    }

    // 새로운 선택 해시태그를 추가
    for (String hashtag in hashtags) {
      final DocumentReference hashtagDocRef = postsCollection.doc(postId).collection('hashtag').doc();

      await hashtagDocRef.set({
        'tag_name': hashtag,
      });
    }
  }

  Future<void> addHashtags(List<String> hashtags, String reviewId) async {
    final CollectionReference reviewCollection = FirebaseFirestore.instance.collection('review');

    for (String hashtag in hashtags) {
      final DocumentReference hashtagDocRef = reviewCollection.doc(reviewId).collection('hashtag').doc(); // 문서 ID 자동 생성

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

  // 선택된 해시태그를 추가하는 함수
  void addSelectedTag(String tagName) {
    if (!_selectTag.contains(tagName)) {
      setState(() {
        _selectTag.add(tagName);
      });
    }
  }

  // 선택된 해시태그를 제거하는 함수
  void removeSelectedTag(String tagName) {
    if (_selectTag.contains(tagName)) {
      setState(() {
        _selectTag.remove(tagName);
      });
    }
  }

  void toggleCustomHashtagInput() {
    setState(() {
      if (_showCustomHashtagInput) {
        if (_customHashtagCtr.text.isNotEmpty) {
          addCustomHashtagToList();
        }
      }
      _showCustomHashtagInput = !_showCustomHashtagInput;
    });
  }

  void addCustomHashtagToList() {
    if (_customHashtagCtr.text.isNotEmpty) {
      final customHashtag = _customHashtagCtr.text;

      if (!_selectTag.contains(customHashtag)) {
        addSelectedTag(customHashtag);
      }

      _customHashtagCtr.text = '';
      toggleCustomHashtagInput();
    }
  }

  Future<void> _saveReview() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty && _imageFile != null) {
      CollectionReference post = FirebaseFirestore.instance.collection("review");

      if (_imageFile != null) {
        try {
          await uploadImage();
        } catch (e) {
          print('이미지 업로드 중 오류 발생: $e');
          return;
        }
      }

      try {
        if (widget.documentId != null) {
          await post.doc(widget.documentId!).update({
            'title': _titleCtr.text,
            'content': _contentCtr.text,
            if(downloadURL != null) 'imageURL' : downloadURL
          });

          // // 업데이트된 선택 해시태그를 저장
          // await updateHashtags(_selectTag, widget.documentId!);

        } else {
          await _loadUserData();

          DocumentReference newReviewRef = await post.add({
            'title': _titleCtr.text,
            'content': _contentCtr.text,
            'write_date': DateTime.now(),
            'imageURL': downloadURL,
            'viewCount': 0,
            'likeCount' : 0,
            'userNickName': _userNickName,
          });

          if(downloadURL != null){
            await newReviewRef.update({'imageURL' : downloadURL});
          }

          if (_selectTag.isNotEmpty) {
            // 선택된 해시태그를 추가
            await addHashtags(_selectTag, newReviewRef.id);
          }
        }

        _titleCtr.clear();
        _contentCtr.clear();
        _imageFile = null;

        final message = widget.documentId != null ? '후기가 수정되었습니다!' : '후기가 등록되었습니다!';
        _showDialog(message);

        // 수정 버튼일 경우 ReviewDetail 페이지로 이동
        if (widget.documentId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetail(document: widget.documentId)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
        }

      } catch (e) {
        print('데이터 저장 중 오류가 발생했습니다: $e');
      }
    } else {
      if (_titleCtr.text.isEmpty && _contentCtr.text.isEmpty) {
        _showDialog('제목과 내용을 입력해주세요');
      } else if (_titleCtr.text.isEmpty) {
        _showDialog('제목을 입력해주세요');
      } else if (_contentCtr.text.isEmpty) {
        _showDialog('내용을 입력해주세요');
      }
      print('후기 등록 실패 왜? ');
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
      print('이미지를 선택하지 않았습니다. 이미지를 선택하지 않은 상태에서 글을 저장합니다.');
      downloadURL = null;
    }
  }

  Widget _selectTagForm() {
    return Wrap(
      spacing: 9,
      runSpacing: 5,
      children: _selectTag.map((selectTag) {
        return Wrap(
          spacing: 2,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xff464D40),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '# $selectTag',
                  style: TextStyle(
                    color: Color(0xffD4D8C8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                removeSelectedTag(selectTag);
              },
              child: Container(
                width: 15,
                height: 15,
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
    );
  }

  // 태그 입력 폼
  Widget _buildCustomHashtagInput() {
    return Container(
      height: 40,
      child: TextField(
        controller: _customHashtagCtr,
        decoration: InputDecoration(
          hintText: '# 직접 태그를 입력해보세요! (#은 제외)',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 13,
          ),
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(),
        ),
        cursorColor: Color(0xff464D40),
      ),
    );
  }

  Widget buildCommForm() {
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
              padding: const EdgeInsets.all(10.0),
              child: _buildDivider(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
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
              padding: const EdgeInsets.all(10.0),
              child: _selectTagForm(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildContentInput(),
            ),
            if (_showCustomHashtagInput)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  _buildCustomHashtagInput(),
                  SizedBox(height: 5),
                  ElevatedButton(
                    child: Text('추가'),
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
      decoration: InputDecoration(
        hintText: '제목을 입력해주세요.',
        hintStyle: TextStyle(
          color: Colors.black38,
          fontSize: 18,
        ),
        border: InputBorder.none,

      ),
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
      maxLines: 10,
      maxLength: 300,
      controller: _contentCtr,
      decoration: InputDecoration(
        hintText: '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
        hintStyle: TextStyle(
          color: Colors.black38,
          fontSize: 13,
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
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(txt),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('확인', style: TextStyle(color: Colors.black87),)
              )
            ],
          );
        }
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
          style: TextStyle(color: Colors.black, fontSize: 15),
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
                child: buildCommForm(),
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
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: toggleCustomHashtagInput,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Color(0xffD4D8C8),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(
                        child: Text('#', style: TextStyle(fontSize: 20, color: Colors.black38, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
