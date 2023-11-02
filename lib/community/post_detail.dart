
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/comment_detail.dart';
import 'package:exhibition_project/community/post_edit.dart';
import 'package:exhibition_project/community/post_main.dart';
import 'package:flutter/material.dart';


class CommDetail extends StatefulWidget {
  final String document;
  CommDetail({required this.document});

  @override
  State<CommDetail> createState() => _CommDetailState();
}

class _CommDetailState extends State<CommDetail> {
  bool isLiked = false;

  final _commentCtr = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  Map<String, dynamic>? _postData;
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _replies = [];


  @override
  void initState() {
    super.initState();
    _getPostData();
    _loadComments();
    loadCommentCounts();

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

  Future<void> _getPostData() async {
    try {
      final documentSnapshot = await _firestore.collection('post').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _postData = documentSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('게시글을 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<List<String>> getCommentIds() async {
    try {
      final QuerySnapshot commentQuerySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.document)
          .collection('comment')
          .get();
      final List<String> commentIds = commentQuerySnapshot.docs.map((doc) => doc.id).toList();
      return commentIds;
    } catch (e) {
      print('댓글 ID를 불러오는 동안 오류 발생: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> getRepliesForComment(String commentId) async {
    try {
      final QuerySnapshot replyQuerySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.document)
          .collection('comment')
          .doc(commentId)
          .collection('reply')
          .orderBy('write_date', descending: false)
          .get();

      final replies = replyQuerySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          final reply = data['reply'] as String;
          final writeDate = data['write_date'] as Timestamp;
          // 나머지 코드
        }
        return {
          'reply': data?['reply'] as String,
          'write_date': data?['write_date'] as Timestamp,
        };
      }).toList();

      return replies;
    } catch (e) {
      print('댓글의 답글을 불러오는 동안 오류 발생: $e');
      return null;
    }
  }

  Widget buildCommentWithReplies(Map<String, dynamic> commentData) {
    final commentId = commentData['documentId'];
    final commentText = commentData['comment'] as String;

    return Column(
      children: [
        // 댓글 내용 표시
        Text(commentText),
        // 해당 댓글의 답글을 표시
        FutureBuilder(
          future: getRepliesForComment(commentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('답글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final replies = snapshot.data as List<Map<String, dynamic>>?;
              if (replies != null && replies.isNotEmpty) {
                return Column(
                  children: replies.map((replyData) {
                    final replyText = replyData['reply'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(replyText),
                    );
                  }).toList(),
                );
              } else {
                return SizedBox(); // 답글이 없을 경우 빈 공간을 반환
              }
            }
            return SizedBox(); // 데이터가 없을 경우 빈 공간을 반환
          },
        ),
      ],
    );
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
        };
      }).toList();
      print(comments);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      print('댓글을 불러오는 중 오류가 발생했습니다: $e');
    }
  }


  void _addComment() async {
    String commentText = _commentCtr.text;

    if (commentText.isNotEmpty) {
      try {
        await _firestore.collection('post').doc(widget.document).collection('comment').add({
          'comment': commentText,
          'write_date': FieldValue.serverTimestamp(),
        });

        _commentCtr.clear();
        FocusScope.of(context).unfocus();

        // 화면 업데이트
        loadCommentCounts();
        _loadComments();
        _showSnackBar('댓글이 등록되었습니다!');

      } catch (e) {
        print('댓글 등록 오류: $e');
      }
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

  Widget buildTitleButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
      },
      child: Container(
        alignment: Alignment.center,
        width: 80,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff464D40), width: 1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: Color(0xff464D40), size: 20),
            Text(
              '커뮤니티',
              style: TextStyle(color: Color(0xff464D40), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailContent(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAuthorInfo(),
          buildTitle(title),
          buildContent(content),
          buildImage(),
          buildIcons(widget.document, commentCounts[widget.document] ?? 0),
        ],
      ),
    );
  }

  Widget buildAuthorInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('assets/ex/ex1.png'),
              ),
              SizedBox(width: 5),
              Text('userNicname', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            '방금 전',
            style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content, style: TextStyle(fontSize: 15),),
    );
  }



  Widget buildImage() {
    String? imagePath = _postData?['imageURL'] as String?;
    return Padding(
      padding: const EdgeInsets.all(8.0),
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

  Map<String, int> commentCounts = {};

  //게시글 아이디 불러오기
  Future<List<String>> getPostDocumentIds() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('post').get();
      final List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
      return documentIds;
    } catch (e) {
      print('게시물 ID를 불러오는 동안 오류 발생: $e');
      return [];
    }
  }

  // 해당 게시글 아이디별 댓글수
  Future<void> calculateCommentCounts(List<String> documentIds) async {
    for (String documentId in documentIds) {
      try {
        final QuerySnapshot commentQuery = await FirebaseFirestore.instance
            .collection('post')
            .doc(documentId)
            .collection('comment')
            .get();
        int commentCount = commentQuery.docs.length;
        commentCounts[documentId] = commentCount;
        setState(() {});
      } catch (e) {
        print('댓글 수 조회 중 오류 발생: $e');
        commentCounts[documentId] = 0;
      }
    }
  }

  Future<void> loadCommentCounts() async {
    List<String> documentIds = await getPostDocumentIds();
    await calculateCommentCounts(documentIds);
  }

  Widget buildIcons(String docId, int commentCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility, '0'),
              SizedBox(width: 5),
              buildIconsItem(
                Icons.chat_bubble_rounded,
                commentCount.toString(),
              ),
              SizedBox(width: 5),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
            child: buildIconsItem(
              isLiked ? Icons.favorite : Icons.favorite_border,
              '0',
              isLiked ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIconsItem(IconData icon, String text, [Color? iconColor]) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Color(0xff464D40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: iconColor ?? Colors.white),
          SizedBox(width: 2),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildCommentForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentCtr,
            maxLines: null, // 댓글이 여러 줄로 나타날 수 있도록 함
            decoration: InputDecoration(
              hintText: '댓글을 작성해주세요',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
        ),
        TextButton(
          onPressed: _addComment,
          child: Text('등록', style: TextStyle(color: Color(0xff464D40), fontWeight: FontWeight.bold)),
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
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _deletePost(documentId);
                Navigator.pop(context);
                _showDeleteDialog();
              },
              child: Text('삭제'),
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
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(String documentId) async {
    try {
      final postRef = FirebaseFirestore.instance.collection("post").doc(documentId);

      // 해당 게시글의 댓글 컬렉션 참조 가져오기
      final commentCollection = postRef.collection("comment");

      // 게시글의 댓글 컬렉션에 속한 모든 댓글 문서 삭제
      final commentQuerySnapshot = await commentCollection.get();
      for (var commentDoc in commentQuerySnapshot.docs) {
        // 해당 댓글의 답글 컬렉션 참조 가져오기
        final replyCollection = commentCollection.doc(commentDoc.id).collection("reply");

        // 댓글의 답글 컬렉션에 속한 모든 답글 문서 삭제
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


  Widget _commentsList(QuerySnapshot<Object?> data) {
    if (_comments.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _comments.map((commentData) {
          final commentText = commentData['comment'] as String;
          final timestamp = commentData['write_date'] as Timestamp;
          final commentDate = timestamp.toDate();
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
                Text('hj',style: TextStyle(fontSize: 13)),
                GestureDetector(
                  onTap: () {

                  },
                  child: Icon(Icons.more_vert, size: 15)
                )
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  commentDate.toString(),
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  _addLineBreaks(commentText, MediaQuery.of(context).size.width),
                  style: TextStyle(fontSize: 13),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommentDetail(
                          commentId: documentId,
                          postId: widget.document
                        )
                      )
                      );
                    },
                    child: Text(
                        '답글쓰기',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            decoration: TextDecoration.underline
                        )
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('post')
                      .doc(widget.document)
                      .collection('comment')
                      .doc(documentId)
                      .collection('reply')
                      .orderBy('write_date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('답글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                    }
                    // 변경된 부분: 답글 리스트를 출력하는 _repliesList 함수를 호출합니다.
                    return _repliesList(snapshot.data as QuerySnapshot);
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


  void _showCommentMenu(Map<String, dynamic> commentData, String documentId) {
    final commentId = commentData['reference'].id;
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
                  _showEditCommentDialog(commentId, commentText, commentText);
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('댓글 수정'),
          content: TextField(
            controller: editCommentController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                String updatedComment = editCommentController.text;
                _editComment(commentId, updatedComment);
                Navigator.pop(context);
              },
              child: Text('저장'),
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
        return AlertDialog(
          title: Text('댓글 삭제'),
          content: Text('댓글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _deleteComment(documentId, commentId);
                Navigator.pop(context);
                _showDeleteCommentDialog();
              },
              child: Text('삭제'),
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
      await _firestore.collection('post').doc(documentId).collection('comment').doc(commentId).delete();
      // 화면 업데이트
      _loadComments();
    } catch (e) {
      print('댓글 삭제 오류: $e');
    }
  }


  Widget _repliesList(QuerySnapshot<Object?> data) {
    if (data.docs.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.docs.map((doc) {
          final replyData = doc.data() as Map<String, dynamic>;
          final replyText = replyData['reply'] as String;
          final timestamp = replyData['write_date'] as Timestamp;
          final replyDate = timestamp.toDate();

          return Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left:30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('hj', style: TextStyle(fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        // Implement your action when the more button is tapped
                      },
                      child: Icon(Icons.more_vert, size: 15),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  replyDate.toString(),
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  replyText,
                  style: TextStyle(fontSize: 13),
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        title: buildTitleButton(context),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.share, color: Color(0xff464D40))),
          IconButton(
            onPressed: _showMenu,
            icon: Icon(Icons.more_vert),
            color: Color(0xff464D40),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _postData == null
              ? CircularProgressIndicator()
              : Column(
                children: [
                  buildDetailContent(_postData!['title'] as String, _postData!['content'] as String),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('post')
                        .doc(widget.document)
                        .collection('comment')
                        .orderBy('write_date', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: _commentsList(snapshot.data as QuerySnapshot),
                      );
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
