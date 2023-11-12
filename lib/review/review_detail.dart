
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_profile.dart';
import 'package:exhibition_project/review/review_edit.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';

class ReviewDetail extends StatefulWidget {
  final String? document;
  final String? userNickName;
  ReviewDetail({required this.document , this.userNickName});

  @override
  State<ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _hashtags = [];

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
  String? _userNickName;
  Future<void> _getProfileImg() async {
    try {
      final userQuerySnapshot = await FirebaseFirestore.instance.collection('user').where('nickName', isEqualTo: widget.userNickName).get();
      final userId = userQuerySnapshot.docs.first.id;
      final userProfileSnapshot = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      final userProfileImage = userProfileSnapshot['profileImage'];

      setState(() {
        _userProfileImage = userProfileImage;
      });
      print('해당유저프로필: $_userProfileImage');
    } catch (error) {
      print('유저데이터 불러오는데 오류 발생: $error');
    }
  }

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

  Future<void> _getHashtags() async {
    try {
      final querySnapshot = await _firestore
          .collection('review')
          .doc(widget.document)
          .collection('hashtag')
          .get();
      final hashtags = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return data['tag_name'] as String;
      }).toList();
      print(hashtags);
      setState(() {
        _hashtags = hashtags;
      });
    } catch (e) {
      print('해시태그를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHashtags();
    _getProfileImg();
    _loadUserData();
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
                  _confirmDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제 완료'),
          content: Text('후기가 삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewList(),
                  ),
                );
              },
              child: Text('확인', style: TextStyle(color: Color(0xff464D40))),
            ),
          ],
        );
      },
    );
  }


  // 리뷰 삭제 확인 대화상자 표시
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제',  style: TextStyle(color: Color(0xff464D40))),
          content: Text('후기를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소',  style: TextStyle(color: Color(0xff464D40))),
            ),
            TextButton(
              onPressed: () {
                _deleteReview(widget.document!);
                Navigator.pop(context);
                _showSuccessDialog(); // 성공 다이얼로그 표시
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }


  // 리뷰 삭제
  void _deleteReview(String documentId) async {
    try {
      // 해당 리뷰(document) 삭제
      await FirebaseFirestore.instance.collection("review").doc(documentId).delete();

      // 해당 리뷰에 연결된 해시태그 삭제
      await FirebaseFirestore.instance
          .collection("review")
          .doc(documentId)
          .collection("hashtag")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // 해당 리뷰에 연결된 좋아요 정보 삭제
      await FirebaseFirestore.instance
          .collection("review")
          .doc(documentId)
          .collection("likes")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      _showSuccessDialog(); // 성공 다이얼로그 표시
    } catch (error) {
      print('삭제 중 오류 발생: $error');
    }
  }



  // 리뷰 상세 정보 위젯
  Widget _reviewDetailWidget() {
    final document = widget.document;
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("review").doc(document).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitWave( // FadingCube 모양 사용
              color: Color(0xff464D40), // 색상 설정
              size: 20.0, // 크기 설정
              duration: Duration(seconds: 3), //속도 설정
            ); // 데이터를 가져오는 동안 로딩 표시
          }

          if (snapshot.hasError) {
            return Text('에러 발생: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Text('데이터 없음');
          }

          final data = snapshot.data?.data() as Map<String, dynamic>;
          final title = data['title'] as String;
          final content = data['content'] as String;
          final imageURL = data['imageURL'] as String?;
          final nickName = data['userNickName'] as String;

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
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName:nickName)));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                    radius: 20,
                                    backgroundImage: _userProfileImage != null
                                        ? NetworkImage(_userProfileImage!)
                                        : AssetImage('assets/logo/green_logo.png') as ImageProvider,
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
                              if (_userNickName == nickName)
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
                          child: _hashtags.isNotEmpty
                              ? Wrap(
                            spacing: 5,
                            runSpacing: -10,
                            children: _hashtags
                                .map(
                                  (hashtag) => ElevatedButton(
                                onPressed: () {},
                                child: Text('# $hashtag'),
                                style: _btnStyle(),
                              ),
                            ).toList(),
                          )
                              : Container(), // 해시태그가 없을 경우 빈 컨테이너 반환한다.
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
                            radius: 30,
                            backgroundImage: _userProfileImage != null
                                ? NetworkImage(_userProfileImage!)
                                : AssetImage('assets/logo/green_logo.png') as ImageProvider,
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

  ButtonStyle _btnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(5, 30)),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.all<double>(0),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
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
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
      ),
      body: _reviewDetailWidget(),
    );
  }
}