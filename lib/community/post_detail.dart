import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/comment_detail.dart';
import 'package:exhibition_project/community/post_edit.dart';
import 'package:exhibition_project/community/post_main.dart';
import 'package:exhibition_project/community/post_profile.dart';
import 'package:exhibition_project/myPage/addAlarm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';

class CommentData {
  String userNickName;
  String userProfileImage;
  CommentData(this.userNickName, this.userProfileImage);
}

class CommDetail extends StatefulWidget {
  final String document;
  CommDetail({required this.document});

  @override
  State<CommDetail> createState() => _CommDetailState();
}

class _CommDetailState extends State<CommDetail> {
  bool _dataLoaded = false;
  Map<String, bool> isLikedMap = {};

  final _commentCtr = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  Map<String, dynamic>? _postData;
  List<Map<String, dynamic>> _comments = [];
  int commentCnt = 0;

  String _formatTimestamp(Timestamp timestamp) {
    final currentTime = DateTime.now();
    final commentTime = timestamp.toDate();

    final difference = currentTime.difference(commentTime);

    if (difference.inDays > 0) {
      return DateFormat('yyyy년 MM월 dd일').format(commentTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  ButtonStyle _unPushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 25)),
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

  String? _userNickName;
  String? _alarmNickName;
  String? _userProfileImage;
  String? _thisUserNickName;
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


  // 유저 프로필 이미지 가져오기
  Future<void> _getProfileImg() async {
    try {
      final userQuerySnapshot = await FirebaseFirestore.instance.collection('user').where('nickName', isEqualTo: _thisUserNickName).get();
      final userId = userQuerySnapshot.docs.first.id;
      final userProfileSnapshot = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      final userProfileImage = userProfileSnapshot['profileImage'];

      setState(() {
        _userProfileImage = userProfileImage;
      });
      print('유저닉네임=====> $_thisUserNickName');
      print('해당유저프로필=====> $_userProfileImage');
    } catch (error) {
      print('유저데이터 불러오는데 오류 발생: $error');
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    getCommentCnt();
    _getProfileImg();
    _scrollController.addListener(() {
      if (_scrollController.offset > 3) {
        setState(() {
          _showFloatingButton = true;
        });
      } else {
        setState(() {
          _showFloatingButton = false;
        });
      }
    });
  }

  Future<void> _loadData() async {
    if (!_dataLoaded) {
      await _getPostData();
      await _loadComments();
      setState(() {
        _dataLoaded = true;
      });
      await _loadUserData();

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('post').get();
      final List<String> postIds = querySnapshot.docs.map((doc) => doc.id).toList();
      _likeCheck(postIds);
    }
  }
  Future<void> _getPostData() async {
    try {
      final documentSnapshot = await _firestore.collection('post').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _postData = documentSnapshot.data() as Map<String, dynamic>;
          final timestamp = _postData?['write_date'] as Timestamp;
          final formattedDate = _formatTimestamp(timestamp);
          _postData?['write_date'] = formattedDate;

          _alarmNickName = _postData?['userNickName'] as String;
          _thisUserNickName = _postData?['userNickName'] as String;

          _dataLoaded = true;
        });
      } else {
        print('게시글을 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _loadComments() async {
    try {
      final querySnapshot = await _firestore
          .collection('post')
          .doc(widget.document)
          .collection('comment')
          .orderBy('write_date', descending: false)
          .get();
      final comments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final documentId = doc.id;
        return {
          'documentId' : documentId,
          'comment': data['comment'] as String,
          'write_date': data['write_date'] as Timestamp,
          'userNickName' : data['userNickName'] as String
        };
      }).toList();
      print(comments);
      setState(() {
        _comments = comments;
        _dataLoaded = true;
      });
    } catch (e) {
      print('댓글을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 게시글 당 댓글 수 가져오기
  void getCommentCnt() async {
    QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
        .collection('post')
        .doc(widget.document)
        .collection('comment')
        .get();

    commentCnt = commentSnapshot.docs.length;
  }


  void _addComment() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    String commentText = _commentCtr.text;

    if (commentText.isNotEmpty) {
      try {
        await _firestore.collection('post').doc(widget.document).collection('comment').add({
          'comment': commentText,
          'write_date': FieldValue.serverTimestamp(),
          'userNickName' : _userNickName
        });

        _commentCtr.clear();
        FocusScope.of(context).unfocus();

        await _loadComments();
        String? userId = await getUserIdByNickName(_alarmNickName!);
        addAlarm(user?.userNo as String, userId! , '님이 회원님의 게시글에 댓글을 남겼습니다.');
        print('유저세션 =============> ${user?.userNo}');
        print('작성자ID================>${userId}');


        // 화면 업데이트
        _loadComments();
        _showSnackBar('댓글이 등록되었습니다!');

      } catch (e) {
        print('댓글 등록 오류: $e');
      }
    }
  }

  //닉네임으로 문서ID찾기 (알림에 활용)
  Future<String?> getUserIdByNickName(String nickName) async {
    try {
      // 해당 닉네임을 가진 유저를 찾기 위한 쿼리
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

  // 좋아요 체크
  Future<void> _likeCheck(List<String> postIds) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    for (String postId in postIds) {
      final likeYnSnapshot = await FirebaseFirestore.instance
          .collection('post')
          .doc(postId)
          .collection('likes')
          .where('userId', isEqualTo: user?.userNo)
          .get();

      if (likeYnSnapshot.docs.isNotEmpty) {
        setState(() {
          isLikedMap[postId] = true;
        });
      } else {
        setState(() {
          isLikedMap[postId] = false;
        });
      }
    }
  }

  bool isTogglingLike = false;

  // 좋아요 버튼을 누를 때 호출되는 함수
  Future<void> toggleLike(String postId) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    // 추가한 부분: 좋아요 토글 중이라면 함수를 빠져나감
    if (isTogglingLike) {
      return;
    }

    // 추가한 부분: 함수가 실행 중임을 표시
    isTogglingLike = true;

    if (user != null && user.isSignIn) {
      DocumentReference postDoc = FirebaseFirestore.instance.collection('post').doc(postId);
      CollectionReference postRef = postDoc.collection('likes');

      final currentIsLiked = isLikedMap[postId] ?? false; // 현재 상태 가져오기

      if (!currentIsLiked) {
        // 좋아요 추가
        await postRef.add({'userId' : user.userNo});
        await postDoc.update({'likeCount' : FieldValue.increment(1)});

      } else {
        // 좋아요 삭제
        QuerySnapshot likeSnapshot = await postRef.where('userId', isEqualTo: user.userNo).get();
        for (QueryDocumentSnapshot doc in likeSnapshot.docs) {
          await doc.reference.delete();
          await postDoc.update({'likeCount' : FieldValue.increment(-1)});
        }
      }

      // 좋아요 수 업데이트
      QuerySnapshot likeSnapshot = await postRef.get();
      int likeCount = likeSnapshot.size;
      await postDoc.update({
        'likeCount': likeCount,
      });

      // 추가한 부분: 함수 실행이 끝났음을 표시
      isTogglingLike = false;

      // 좋아요 수 업데이트 후에 isLikedMap 업데이트
      setState(() {
        isLikedMap[postId] = !currentIsLiked; // 현재 상태를 토글합니다.
      });
    }
  }

  // 게시글 좋아요 버튼을 표시하는 부분
  Widget buildLikeButton(String docId, int likeCount) {
    final currentIsLiked = isLikedMap[docId] ?? false; // 현재 상태 가져오기

    return GestureDetector(
      onTap: () {
        toggleLike(docId); // 해당 게시물의 좋아요 토글 함수 호출
      },
      child: buildIconsItem(
        currentIsLiked ? Icons.favorite : Icons.favorite_border,
        likeCount.toString(),
        currentIsLiked ? Colors.red : null,
      ),
    );
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
    );
  }


  Widget buildDetailContent(String title, String content, String writeDate, int viewCount, String userNickName, int likeCount) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAuthorInfo(writeDate, userNickName),
          buildTitle(title),
          buildContent(content),
          buildImage(),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('post')
                  .doc(widget.document)
                  .collection('hashtag')
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> hashtagSnap){
                if (hashtagSnap.hasError) {
                  return Center(child: Text('에러 발생: ${hashtagSnap.error}'));
                }
                if (!hashtagSnap.hasData) {
                  return Center(child: Text(''));
                }
                return Wrap(
                  spacing: 5,
                  runSpacing: -12,
                  children: hashtagSnap.data!.docs.map((doc) {
                    final keyword = doc['tag_name'] as String;

                    return ElevatedButton(
                      child: Text('#$keyword'),
                      onPressed: () {
                        // Handle hashtag button press
                      },
                      style: _unPushBtnStyle(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          buildIcons(widget.document, viewCount, likeCount),
        ],
      ),
    );
  }

  Widget buildAuthorInfo(String writeDate, String userNickName) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: userNickName)));
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
                Text(userNickName, style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
          Text(
            writeDate, style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    );
  }

  Widget buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(content, style: TextStyle(fontSize: 14),),
    );
  }

  Widget buildImage() {
    String? imagePath = _postData?['imageURL'] as String?;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: imagePath != null && imagePath.isNotEmpty
          ? Image.network(
        imagePath,
        width: 400,
        height: 400,
        fit: BoxFit.cover,
      )
          : SizedBox(width: 0, height: 0), // 이미지가 없을 때 빈 SizedBox 반환
    );
  }

  Widget buildIcons(String docId, int viewCount, int likeCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility_outlined, viewCount.toString()),
              SizedBox(width: 5),
              buildIconsItem(Icons.chat_bubble_outline_rounded, commentCnt.toString()),
              SizedBox(width: 5),
            ],
          ),
          Row(
            children: [
              buildLikeButton(docId, likeCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildIconsItem(IconData icon, String text, [Color? iconColor]) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5,),
      child: Row(
        children: [
          Icon(icon, size: 21, color: iconColor ?? Colors.grey[600]),
          SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildCommentForm() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
            child: TextField(
              controller: _commentCtr,
              maxLines: null, // 댓글이 여러 줄로 나타날 수 있도록 함
              decoration: InputDecoration(
                hintText: '댓글을 작성해주세요.',
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff464D40)), // 포커스가 있을 때의 테두리 색상
                ),
              ),
              cursorColor: Color(0xff464D40),
            ),
          ),
        ),
        Container(
        margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
              minimumSize: MaterialStateProperty.all(Size(50, 48)), // 너비 100, 높이 40으로 설정
            ),
            onPressed: _addComment,
            child: Text('등록', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }


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
                    Icon(Icons.maximize_rounded, color: Colors.black, size: 30),
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
                      builder: (context) => CommEdit(documentId: widget.document),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제하기'),
                onTap: () {
                  _confirmDelete(document);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제'),
          content: Text('게시글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Color(0xff464D40))),
            ),
            TextButton(
              onPressed: () {
                _deletePost(documentId);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                _showDeleteDialog();
              },
              child: Text('삭제', style: TextStyle(color: Color(0xff464D40))),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommMain(),
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

  void _deletePost(String documentId) async {
    try {
      final postRef = _firestore.collection("post").doc(documentId);

      // 게시글 내의 댓글 컬렉션 참조 가져오기
      final commentCollection = postRef.collection("comment");

      // 댓글 컬렉션에 속한 모든 댓글 문서 삭제
      final commentQuerySnapshot = await commentCollection.get();
      for (var commentDoc in commentQuerySnapshot.docs) {
        // 해당 댓글의 답글 컬렉션 참조 가져오기
        final replyCollection = commentCollection.doc(commentDoc.id).collection("reply");

        // 답글 컬렉션에 속한 모든 답글 문서 삭제
        final replyQuerySnapshot = await replyCollection.get();
        for (var replyDoc in replyQuerySnapshot.docs) {
          await replyDoc.reference.delete();
        }

        // 댓글 문서 삭제
        await commentDoc.reference.delete();
      }

      // 게시글 문서 삭제
      await postRef.delete();
    } catch (e) {
      print('게시글 삭제 중 오류 발생: $e');
    }
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

  Widget _commentsList(QuerySnapshot data) {
    if (_comments.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _comments.map((commentData) {
          final commentText = commentData['comment'] as String;
          final userNickName = commentData['userNickName'] as String;

          String documentId = commentData['documentId'];

          return Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: userNickName)));
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: AssetImage('assets/logo/green_logo.png'),
                          ),
                          SizedBox(width: 10),
                          Text(userNickName!, style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          commentData['write_date'] != null
                              ? _formatTimestamp(commentData['write_date'] as Timestamp)
                              : '날짜 없음', // 또는 다른 대체 텍스트
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        SizedBox(width: 5,),
                        if (_userNickName == userNickName)
                        GestureDetector(
                          onTap: () {
                            _showCommentMenu(commentData, documentId, commentText);
                          },
                          child: Icon(Icons.more_vert, size: 16, color: Colors.grey[500],),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  _addLineBreaks(commentText, MediaQuery.of(context).size.width),
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommentDetail(
                      commentId: documentId,
                      postId: widget.document,
                    )),
                    );
                  },
                  child: Text(
                    '답글쓰기',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: _firestore
                      .collection('post')
                      .doc(widget.document)
                      .collection('comment')
                      .doc(documentId)
                      .collection('reply')
                      .orderBy('write_date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('답글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                    }

                    if (snapshot.hasData) {
                      return _repliesList(snapshot.data!, documentId);
                    } else {
                      return Container(); // 또는 다른 로딩 표시 방식을 사용할 수 있습니다.
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Center(child: Text('댓글이 없습니다.'));
    }
  }


  void _showCommentMenu(Map<String, dynamic> commentData, String documentId, String commentText) {
    final commentId = documentId;
    final commentText = commentData['comment'] as String;

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
                    Icon(Icons.maximize_rounded, color: Colors.black, size: 30),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('댓글 수정'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCommentDialog(widget.document, commentId, commentText);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('댓글 삭제'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteComment(documentId, commentId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCommentDialog(String documentId, String commentId, String initialText) {
    final TextEditingController editCommentController = TextEditingController(text: initialText);
    documentId = widget.document;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('댓글 수정'),
          content: TextField(
            controller: editCommentController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff464D40)), // 포커스가 있을 때의 테두리 색상
              ),
            ),

          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Color(0xff464D40))),
            ),
            TextButton(
              onPressed: () {
                String updatedComment = editCommentController.text;
                _editComment(commentId, updatedComment);
                Navigator.pop(context);
              },
              child: Text('저장', style: TextStyle(color: Color(0xff464D40))),
            ),
          ],
        );
      },
    );
  }

  void _editComment(String commentId, String updatedComment) async {
    try {
      await _firestore.collection('post').doc(widget.document).collection('comment').doc(commentId).update({
        'comment': updatedComment,
      });

      // 화면 업데이트
      _loadComments();
      _showSnackBar('댓글이 수정되었습니다!');
    } catch (e) {
      print('댓글 수정 오류: $e');
    }
  }

  void _confirmDeleteComment(String documentId, String commentId) {
    showDialog(
      context: context,
      builder: (context) {
        documentId = widget.document;
        return AlertDialog(
          title: Text('댓글 삭제'),
          content: Text('댓글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 현재 다이얼로그 닫기
                _deleteComment(documentId, commentId); // 삭제 동작 수행
              },
              child: Text('삭제',style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('댓글이 삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }


  void _deleteComment(String documentId, String commentId) async {
    try {
      // 먼저 해당 문서를 삭제
      await _firestore.collection('post').doc(documentId).collection('comment').doc(commentId).delete();

      // 그런 다음 해당 댓글에 연결된 모든 답글 컬렉션을 가져옵니다.
      final replyCollection = _firestore.collection('post').doc(documentId).collection('comment').doc(commentId).collection('reply');

      // 해당 답글 컬렉션을 삭제하기 전에 모든 답글을 가져와서 삭제합니다.
      final replyDocs = await replyCollection.get();
      for (final doc in replyDocs.docs) {
        await replyCollection.doc(doc.id).delete();
      }

      // 마지막으로 댓글 삭제 후, 화면에서 해당 댓글을 업데이트합니다.
      _loadComments();

      // 댓글이 삭제되었음을 사용자에게 알리는 다이얼로그를 표시합니다.
      _showDeleteCommentDialog();
    } catch (e) {
      print('댓글 삭제 오류: $e');
    }
  }

  int _visibleReplyCount = 1;
  bool _showAllReplies = false; // 모든 답글을 표시할지 여부

  void _showReplyMenu(Map<String, dynamic> replyData, String commentId, String replyText, String replyId) {
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
                    Icon(Icons.maximize_rounded, color: Colors.black, size: 30),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('답글 수정'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditReplyDialog(widget.document, commentId, replyId, replyText);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('답글 삭제'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteReply(widget.document, commentId, replyId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditReplyDialog(String documentId, String commentId, String replyId, String initialText) {
    final TextEditingController editReplyController = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('답글 수정'),
          content: TextField(
            controller: editReplyController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Color(0xff464D40)),),
            ),
            TextButton(
              onPressed: () {
                String updatedReply = editReplyController.text;
                _editReply(commentId, replyId, updatedReply);
                Navigator.pop(context);
              },
              child: Text('저장', style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  void _editReply(String commentId, String replyId, String updatedReply) async {
    try {
      await _firestore.collection('post').doc(widget.document).collection('comment').doc(commentId).collection('reply').doc(replyId).update({
        'reply': updatedReply,
      });

      // 화면 업데이트
      _loadComments();
      _showSnackBar('답글이 수정되었습니다!');
    } catch (e) {
      print('답글 수정 오류: $e');
    }
  }

  void _confirmDeleteReply(String documentId, String commentId, String replyId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('답글 삭제'),
          content: Text('답글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Color(0xff464D40))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteReply(documentId, commentId, replyId);
              },
              child: Text('삭제', style: TextStyle(color: Color(0xff464D40))),
            ),
          ],
        );
      },
    );
  }

  void _deleteReply(String documentId, String commentId, String replyId) async {
    try {
      await _firestore.collection('post').doc(documentId).collection('comment').doc(commentId).collection('reply').doc(replyId).delete();

      // UI 업데이트
      _loadComments();

      // 사용자에게 답글이 삭제되었음을 알리는 다이얼로그 표시
      _showDeleteReplyDialog();
    } catch (e) {
      print('답글 삭제 오류: $e');
    }
  }

  void _showDeleteReplyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('답글이 삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인', style: TextStyle(color: Color(0xff464D40))),
            ),
          ],
        );
      },
    );
  }

  Widget _repliesList(QuerySnapshot<Object?> data, String commentId) {
    if (data.docs.isNotEmpty) {
      final replies = data.docs.map((doc) {
        final replyData = doc.data() as Map<String, dynamic>;
        final replyText = replyData['reply'] as String;
        final userNickName = replyData['userNickName'] as String;
        final replyDate = replyData['write_date'];
        return {
          'replyText': replyText,
          'userNickName' : userNickName,
          'write_date' : replyDate,
          'id' : doc.id
        };
      }).toList();
      if (!_showAllReplies) {
        replies.removeRange(_visibleReplyCount, replies.length);
      }
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 댓글 1개 이상이면 접기
            for (int i = 0; i < replies.length; i++) _buildReplyRow(replies[i], commentId),
            if (data.docs.length > _visibleReplyCount)
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: ReplyToggleButton(
                  showAllReplies: _showAllReplies,
                  onTap: () {
                    setState(() {
                      _showAllReplies = !_showAllReplies;
                    });
                  },
                ),
              )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildReplyRow(Map<String, dynamic> replyData, String commentId) {
    final replyText = replyData['replyText'] as String;
    final userNickName = replyData['userNickName'] as String?;
    final replyId = replyData['id'] as String; // 답글 ID 추가

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
              size: 20, color: Colors.grey,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 90,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: userNickName)));
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: AssetImage('assets/logo/green_logo.png'),
                              ),
                              SizedBox(width: 10),
                              Text(userNickName!, style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          replyData['write_date'] != null
                              ? _formatTimestamp(replyData['write_date'] as Timestamp)
                              : '날짜 없음', // 또는 다른 대체 텍스트
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        SizedBox(width: 5),
                        if (_userNickName == userNickName)
                          GestureDetector(
                            onTap: () {
                              _showReplyMenu(replyData, commentId, replyText, replyId);
                            },
                            child: Icon(Icons.more_vert, size: 15, color: Colors.grey,),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  _addLineBreaks(replyText, MediaQuery.of(context).size.width),
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            //_onBackPressed();
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        elevation: 0,
        title: Text('COMMUNITY', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
            },
            child: Icon(Icons.home, color: Color(0xff464D40), size: 20),
          ),
          SizedBox(width: 15),
          if (_userNickName == _postData?['userNickName']) // 닉네임 비교
            GestureDetector(
              onTap: _showMenu,
              child: Icon(Icons.more_vert, color: Colors.grey, size: 20),
            ),
          SizedBox(width: 15),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                StreamBuilder(
                    stream: _firestore
                        .collection('post')
                        .doc(widget.document)
                        .snapshots(),
                    builder: (context, snapshot){
                      if (snapshot.hasError) {
                        return Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                      }
                      if(snapshot.hasData){
                        final postData = snapshot.data;
                        final title = postData?['title'] as String;
                        final content = postData?['content'] as String;
                        final nickName = postData?['userNickName'] as String;
                        int viewCount = postData?['viewCount'] as int? ?? 0;
                        int likeCount = postData?['likeCount'] as int? ?? 0;
                        return buildDetailContent(
                          title,
                          content,
                          _formatTimestamp(postData?['write_date'] as Timestamp),
                          viewCount,
                          nickName,
                          likeCount
                        );
                      } else {
                        return Container();
                      }
                    }
                ),
                StreamBuilder(
                  stream: _firestore
                      .collection('post')
                      .doc(widget.document)
                      .collection('comment')
                      .orderBy('write_date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                    }
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        child: _commentsList(snapshot.data as QuerySnapshot<Object?>),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? Container(
        padding: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0.0,
              duration: Duration(milliseconds: 2),
              curve: Curves.easeInOut,
            );
          },
          child: Icon(Icons.arrow_upward),
          backgroundColor: Color(0xff464D40),
          mini: true,
        ),
      )
          : null,
      bottomSheet: Container(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: buildCommentForm(),
      ),
    );
  }
}


//////답글 더보기/ 접기 버튼
class ReplyToggleButton extends StatefulWidget {
  final bool showAllReplies;
  final VoidCallback onTap;

  ReplyToggleButton({
    required this.showAllReplies,
    required this.onTap,
  });

  @override
  _ReplyToggleButtonState createState() => _ReplyToggleButtonState();
}

class _ReplyToggleButtonState extends State<ReplyToggleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Text(
        widget.showAllReplies ? '답글 접기' : '답글 더보기',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
    );
  }
}