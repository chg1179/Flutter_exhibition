
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';
import '../myPage/addAlarm.dart';

class CommentDetail extends StatefulWidget {
  final String? postId;
  final String? commentId;

  CommentDetail({required this.postId, this.commentId});

  @override
  State<CommentDetail> createState() => _CommentDetailState();
}

class _CommentDetailState extends State<CommentDetail> {

  String? _userNickName;
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


  final _replyCtr = TextEditingController();
  List<Map<String, dynamic>> _reply = [];
  final _firestore = FirebaseFirestore.instance;

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

  @override
  void initState() {
    super.initState();
    print(widget.commentId);
    print(widget.postId);
    _loadReplys();
    _loadUserData();
  }

  // 대댓글 불러오기
  Future<void> _loadReplys() async {
    try {
      final querySnapshot = await _firestore
          .collection('post')
          .doc(widget.postId)
          .collection('comment')
          .doc(widget.commentId)
          .collection('reply')
          .orderBy('write_date', descending: false)
          .get();
      final replies = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'reply': data['reply'] as String,
          'write_date': data['write_date'] as Timestamp,
          'userNickName' : data['userNickName'] as String
        };
      }).toList();
      
      setState(() {
        _reply = replies;
      });

    } catch (e) {
      print('답글을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 대댓글 추가
  Future<void> _addReply() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    String replyText = _replyCtr.text;

    if (replyText.isNotEmpty) {
      try {
        // Firestore에 대댓글 추가
        await _firestore
            .collection('post')
            .doc(widget.postId)
            .collection('comment')
            .doc(widget.commentId)
            .collection('reply')
            .add({
          'reply': replyText,
          'write_date': FieldValue.serverTimestamp(),
          'userNickName': _userNickName!,
        });

        // 이전에 작성한 함수를 활용하여 코멘트의 userNickName을 가져오기
        String? commentUserNickName = await getCommentUserNickName(widget.postId!, widget.commentId!);

        // 코멘트의 userNickName을 확인하고 null이 아니면 _userNickName에 할당
        if (commentUserNickName != null) {
          setState(() {
            _userNickName = commentUserNickName;
          });

          // 닉네임을 이용하여 유저 ID를 가져오기
          String? userId = await getUserIdByNickName(_userNickName!);

          if (userId != null) {
            // userId를 사용하여 추가적인 작업 수행
            // 예: Firestore에서 해당 유저 문서를 가져오기 등
            print('해당 닉네임을 가진 유저의 ID: $userId');

            // 알림 추가
            addAlarm(user?.userNo as String, userId, '님이 회원님의 댓글에 답글을 남겼습니다.');
          } else {
            print('해당 닉네임을 가진 유저를 찾을 수 없습니다.');
          }
        }

        // 나머지 로직은 그대로 유지
        _replyCtr.clear();
        FocusScope.of(context).unfocus();
        _showSnackBar('답글이 등록되었습니다!');

      } catch (e) {
        print('대댓글 등록 오류: $e');
      }
    }
  }
  //1. 댓글단 user에게 대댓글시 알림보내기 위한 댓글단user 닉네임 뽑기
  Future<String?> getCommentUserNickName(String postId, String commentId) async {
    try {
      DocumentSnapshot commentSnapshot = await _firestore
          .collection('post')
          .doc(postId)
          .collection('comment')
          .doc(commentId)
          .get();

      if (commentSnapshot.exists) {
        Map<String, dynamic> commentData = commentSnapshot.data() as Map<String, dynamic>;
        String userNickName = commentData['userNickName'] as String;

        // userNickName 값 반환
        return userNickName;
      } else {
        print('코멘트를 찾을 수 없습니다.');
        return null;
      }
    } catch (e) {
      print('코멘트 데이터를 불러오는 중 오류가 발생했습니다: $e');
      return null;
    }
  }
  //2. 댓글단 user 닉네임을 찾은걸로 user컬렉션에 같은닉네임을 가진 문서ID 추출
  Future<String?> getUserIdByNickName(String nickName) async {
    try {
      // 닉네임을 가진 유저를 찾기 위한 쿼리
      QuerySnapshot querySnapshot = await _firestore.collection('user').where('nickName', isEqualTo: nickName).get();

      // 쿼리 결과 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서의 ID 반환 (닉네임이 중복되지 않는 것을 가정)
        return querySnapshot.docs.first.id;
      } else {
        print('일치하는 닉네임을 가진 유저를 찾을 수 없습니다.');
        return null;
      }
    } catch (e) {
      print('닉네임으로 유저 ID를 가져오는 중 오류가 발생했습니다: $e');
      return null;
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget buildReplyForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _replyCtr,
            maxLines: null,
            decoration: InputDecoration(
              hintText: '답글을 작성해주세요',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
        ),
        TextButton(
          onPressed: _addReply,
          child: Text('등록', style: TextStyle(color: Color(0xff464D40), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // 댓글수 일정 수 이상 넘어가면 줄바꿈
  String _addLineBreaks(String text, double maxLineLength) {
    final buffer = StringBuffer();
    double currentLineLength = 0;

    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      currentLineLength++;

      if (currentLineLength >= maxLineLength) {
        buffer.write('\n'); // 글자 수가 일정 수 이상이면 줄바꿈 추가
        currentLineLength = 0;
      }
    }

    return buffer.toString();
  }

  Widget _replyList(QuerySnapshot<Object?> data) {
    if (data.docs.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.docs.map((doc) {
          final replyData = doc.data() as Map<String, dynamic>;
          final replyText = replyData['reply'] as String;
          final userNickName = replyData['userNickName'] as String;

          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.subdirectory_arrow_right,
                    size: 20,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 105,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userNickName, style: TextStyle(fontSize: 10)),
                          SizedBox(height: 5),
                          Text(
                            replyData['write_date'] != null
                                ? _formatTimestamp(replyData['write_date'] as Timestamp)
                                : '날짜 없음', // 또는 다른 대체 텍스트
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            _addLineBreaks(replyText, MediaQuery.of(context).size.width),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.more_vert,
                    size: 15,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        elevation: 0,
        centerTitle: true,
        title: Text('댓글', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('post')
                .doc(widget.postId)
                .collection('comment')
                .doc(widget.commentId)
                .snapshots(),
            builder: (context, commentSnapshot) {
              if (commentSnapshot.hasError) {
                return Text('댓글을 불러오는 중 오류가 발생했습니다: ${commentSnapshot.error}');
              }
              if (!commentSnapshot.hasData) {
                return Text('댓글이 없습니다.');
              }

              final commentData = commentSnapshot.data as DocumentSnapshot;
              final commentText = commentData['comment'] as String;
              final userNickName = commentData['userNickName'] as String;

              return Container(
                margin: EdgeInsets.only(right: 10, left: 10),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userNickName, style: TextStyle(fontSize: 13)),
                        Row(
                          children: [
                            Text(
                              commentData['write_date'] != null
                                  ? _formatTimestamp(commentData['write_date'] as Timestamp)
                                  : '날짜 없음', // 또는 다른 대체 텍스트
                              style: TextStyle(fontSize: 10),
                            ),
                            GestureDetector(
                              onTap: () {
                              },
                              child: Icon(Icons.more_vert, size: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(commentText, style: TextStyle(fontSize: 13)),
                    SizedBox(height: 5),
                  ],
                ),
              );
            },
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('post')
                .doc(widget.postId)
                .collection('comment')
                .doc(widget.commentId)
                .collection('reply')
                .orderBy('write_date', descending: false)
                .snapshots(),
            builder: (context, replySnapshot) {
              if (replySnapshot.hasError) {
                return Text('답글을 불러오는 중 오류가 발생했습니다: ${replySnapshot.error}');
              }

              if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('가장 먼저 답글을 남겨보세요!',style: TextStyle(fontSize: 13, color: Colors.grey),),
                );
              }

              final data = replySnapshot.data!;
              return _replyList(data);
            },
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: buildReplyForm(),
      ),
    );
  }
}
