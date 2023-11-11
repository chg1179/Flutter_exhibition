
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_profile.dart';
import 'package:exhibition_project/review/review_edit.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';

class ReviewDetail extends StatefulWidget {
  final String? document;
  ReviewDetail({required this.document});

  @override
  State<ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _hashtags = [];

  String _formatTimestamp(Timestamp timestamp) {
    final currentTime = DateTime.now();
    final commentTime = timestamp.toDate();
    final difference = currentTime.difference(commentTime);

    if (difference.inDays > 0) {
      return DateFormat('yyyy-MM-dd').format(commentTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  String? _userProfileImage;

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      DocumentSnapshot _userDocument;

      setState(() {
        _userDocument = document;
        _userProfileImage = _userDocument.get('profileImage');
        print('임이지: $_userProfileImage');
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  Future<void> _getHashtags() async {
    try {
      final querySnapshot = await _firestore
          .collection('review')
          .doc(widget.document)
          .collection('hashtag')
          .get();
      final hashtags = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'tag_name': data['tag_name'] as String,
        };
      }).toList();
      print(hashtags);
      setState(() {
        _hashtags = hashtags;
      });
    } catch (e) {
      print('댓글을 불러오는 중 오류가 발생했습니다: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHashtags();
  }
  // 메뉴 아이콘 클릭
  void _showMenu() {
    final document = widget.document;
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enableDrag: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 10),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.maximize_rounded, color: Colors.black, size: 30,)
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewEdit(documentId: document),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제하기'),
                onTap: () {
                  _confirmDelete(document as DocumentSnapshot<Object?>);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 리뷰 삭제 확인 대화상자 표시
  void _confirmDelete(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제'),
          content: Text('후기를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _deleteReview(document);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewList(),
                  ),
                );
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 리뷰 삭제
  void _deleteReview(DocumentSnapshot document) async {
    await FirebaseFirestore.instance.collection("review").doc(document.id).delete();
  }

  // 리뷰 상세 정보 위젯
  Widget _reviewDetailWidget() {
    final document = widget.document;
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("review").doc(document).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // 데이터를 가져오는 동안 로딩 표시
          }

          if (snapshot.hasError) {
            return Text('에러 발생: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Text('데이터 없음');
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final title = data['title'] as String;
          final content = data['content'] as String;
          final imageURL = data['imageURL'] as String?;
          final nickName = data['userNickName'] as String;

          List<String> hashtags = [];

          if (data.containsKey('hashtag')) {
            var hashtagDocs = data['hashtag'] as List<dynamic>;
            hashtags = List<String>.from(hashtagDocs);
          }


          return SingleChildScrollView(
              child : Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                          child: Text(title, style: TextStyle(fontSize: 25.0)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nickName, style: TextStyle(fontSize: 13)),
                                        Row(
                                          children: [
                                            Text(
                                              '${data['write_date'] != null ? _formatTimestamp(data['write_date'] as Timestamp) : "날짜없음"}',
                                              style: TextStyle(fontSize: 12, color: Colors.black45),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  onPressed: _showMenu,
                                  icon: Icon(Icons.more_vert, size: 20,),
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                          child: Container(
                              height:1.0,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black12
                          ),
                        ),
                        if (imageURL != null && imageURL.isNotEmpty)
                          Padding(
                            padding: const  EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
                            child: Image.network(imageURL),
                          ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                          child: Text(content),
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Color(0xff464D40),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tag, color: Color(0xffD4D8C8), size: 15),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                            height:1.0,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black12
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName:nickName)));
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/ex/ex1.png'),
                          ),
                          SizedBox(height: 10),
                          Text(nickName, style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                      height:1.0,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black12
                  ),
                ],
              )
          );
      }
    );
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReviewList()));
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Icon(Icons.list_alt,color: Colors.black87,),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: _onBackPressed
        ),
      ),
      body: _reviewDetailWidget(),
    );
  }
}