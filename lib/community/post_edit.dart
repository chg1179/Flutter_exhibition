import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../firebase_storage/image_upload.dart';
import '../model/user_model.dart';
import 'post_detail.dart';
import 'post_main.dart';

class CommEdit extends StatefulWidget {
  final String? documentId;

  CommEdit({Key? key, this.documentId}) : super(key: key);

  @override
  _CommEditState createState() => _CommEditState();
}

class _CommEditState extends State<CommEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  final _customHashtagCtr = TextEditingController();

  final ImageSelector selector = ImageSelector();
  late ImageUploader uploader;
  XFile? _imageFile;
  String? downloadURL;
  List<String> _selectTag = [];
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



  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      _loadPostData(widget.documentId!);
      _loadHashtags(widget.documentId!);
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

  Future<void> _loadPostData(String documentId) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance.collection('post').doc(documentId).get();

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
        print('게시글을 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _savePost() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference post = FirebaseFirestore.instance.collection("post");

      if (_imageFile != null) {
        try {
          await uploadImage();
        } catch (e) {
          print('이미지 업로드 중 오류 발생: $e');
        }
      }

      try {
        if (widget.documentId != null) {
          await post.doc(widget.documentId!).update({
            'title': _titleCtr.text,
            'content': _contentCtr.text,
            'imageURL': downloadURL,
          });

          // 업데이트된 선택 해시태그를 저장
          await updateHashtags(_selectTag, widget.documentId!);

        } else {
          await _loadUserData();

          DocumentReference newPostRef = await post.add({
            'title': _titleCtr.text,
            'content': _contentCtr.text,
            'write_date': DateTime.now(),
            'imageURL': downloadURL,
            'viewCount': 0,
            'likeCount' : 0,
            'userNickName': _userNickName,
          });

          if (_selectTag.isNotEmpty) {
            // 선택된 해시태그를 추가
            await addHashtags(_selectTag, newPostRef.id);
          }
        }

        _titleCtr.clear();
        _contentCtr.clear();
        downloadURL = null;
        _imageFile = null;
      } catch (e) {
        print('데이터 저장 중 오류가 발생했습니다: $e');
      }


    } else {
      print("제목과 내용을 입력해주세요");

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

  Future<void> addHashtags(List<String> hashtags, String postId) async {
    final CollectionReference postsCollection = FirebaseFirestore.instance.collection('post');

    for (String hashtag in hashtags) {
      final DocumentReference hashtagDocRef = postsCollection.doc(postId).collection('hashtag').doc(); // 문서 ID 자동 생성

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
        final uploader = ImageUploader('post_images');
        downloadURL = await uploader.uploadImage(_imageFile!);
        print('Uploaded to Firebase Storage: $downloadURL');
      } catch (e) {
        print('이미지 업로드 중 오류 발생: $e');
      }
    } else {
      // 이미지를 선택하지 않은 경우
      print('이미지를 선택하지 않았습니다. 이미지를 선택하지 않은 상태에서 글을 저장합니다.');
      downloadURL = null;
    }
  }

  Widget buildCommForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.8, color: Color(0xff464D40)),
              borderRadius: BorderRadius.circular(5)
            ),
            child: Column(
              children: [
                _buildTitleInput(),
                _buildDivider(),
                SizedBox(height: 10),
                _buildContentInput(),
                SizedBox(height: 20,)
                ],
            ),
          ),
          SizedBox(height: 20),
          _buildImgButton(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildSelectedImage(),
                  Positioned(
                    top: 14,
                    right: 4,
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
          SizedBox(height: 20),
          SizedBox(height: 20),
          _hashTagList(),
        ],
      ),
    );
  }

  Widget _buildSelectedImage() {
    if (_imageFile != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Image.file(
          File(_imageFile!.path),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    } else if (downloadURL != null && downloadURL!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Image.network(
          downloadURL!,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // 이미지가 선택되지 않은 경우에는 빈 컨테이너 반환
      return Container();
    }
  }
  Widget _buildTitleInput() {
    return Container(
      child: TextField(
        controller: _titleCtr,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, right: 10, left: 20, bottom: 10),
          hintText: '제목을 입력해주세요.',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }


  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      height: 0.8,
      width: MediaQuery.of(context).size.width,
      color: Colors.black45,
    );
  }

  Widget _buildImgButton() {
    return InkWell(
      onTap: getImage,
      child: Container(
        width: 100,
        height: 25,
        decoration: BoxDecoration(
            color: Color(0xffD4D8C8),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("이미지 선택", style: TextStyle(fontSize: 12, color: Color(0xff464D40))),
            SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.image_rounded, color: Color(0xff464D40), size: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        maxLines: 10,
        maxLength: 300,
        controller: _contentCtr,
        decoration: InputDecoration(
          hintText: '내용을 입력해주세요.',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 13,
          ),
          border: InputBorder.none,
        ),
      ),
    );
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

  void addCustomHashtagToList() {
    if (_customHashtagCtr.text.isNotEmpty) {
      final customHashtag = _customHashtagCtr.text;

      if (!_selectTag.contains(customHashtag)) {
        addSelectedTag(customHashtag);
      }

      _customHashtagCtr.text = '';
    }
  }

  Widget _hashTagList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('추천 태그', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text('태그를 선택하거나 입력해주세요. (최대 30개)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 5,),
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
        Divider(),
        SizedBox(height: 5),
        Text('나의 태그', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        SizedBox(height: 5),
        _selectTagForm(),
        SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
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
      ],
    );
  }

  Widget _selectTagForm() {
    if(_selectTag.length > 0){
      return Container(
        child: Column(
          children: [
            Wrap(
              spacing: 9,
              runSpacing: 9,
              crossAxisAlignment: WrapCrossAlignment.center,
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
        ),
      );
    }else{
      return Container(
        child: Text("태그를 입력 또는 선택해주세요.", style: TextStyle(color: Colors.grey, fontSize: 12),),
      );
    }
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
          TextButton(
            onPressed: () {
              _savePost().then((value) {
                if (widget.documentId != null) {
                  // 수정 버튼일 경우
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CommDetail(document: widget.documentId!)));
                } else {
                  // 등록 버튼일 경우
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                }
              });
            },
            child: Text(
              widget.documentId != null ? '수정' : '등록',
              style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildCommForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
