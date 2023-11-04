
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
  bool _dataLoaded = false;
  bool isLiked = false;

  final _commentCtr = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  Map<String, dynamic>? _postData;
  List<Map<String, dynamic>> _comments = [];


  @override
  void initState() {
    super.initState();
    if (!_dataLoaded) {
      _getPostData();
      _loadComments();
      _loadCommentCounts();
    }
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

  Future<void> _loadCommentCounts() async {
    List<String> documentIds = await getPostDocumentIds();
    await calculateCommentCounts(documentIds);
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
        _loadCommentCounts();
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


  Widget buildDetailContent(String title, String content, int viewCount) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAuthorInfo(),
          buildTitle(title),
          buildContent(content),
          buildImage(),
          buildIcons(widget.document, commentCounts[widget.document] ?? 0, viewCount),
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



  Widget buildIcons(String docId, int commentCount, int viewCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility, viewCount.toString()),
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
          child: Container(
            margin: EdgeInsets.all(5),
            child: TextField(
              controller: _commentCtr,
              maxLines: null, // 댓글이 여러 줄로 나타날 수 있도록 함
              decoration: InputDecoration(
                hintText: '댓글을 작성해주세요',
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
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
            minimumSize: MaterialStateProperty.all(Size(50, 5)), // 너비 100, 높이 40으로 설정
          ),
          onPressed: _addComment,
          child: Text('등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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


  Widget _commentsList(QuerySnapshot data) {
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
                  onTap: (){
                    _showCommentMenu(commentData ,documentId, commentText);
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
                  style: TextStyle(fontSize: 12),
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
                    if (snapshot.hasError) {
                      return Text('답글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                    }

                    if (snapshot.hasData) {
                      return _repliesList(snapshot.data!);
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
                  _showEditCommentDialog(widget.document!, commentId, commentText);
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
        documentId = widget.document;
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
                Navigator.pop(context); // 현재 다이얼로그 닫기
                _deleteComment(documentId, commentId); // 삭제 동작 수행
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



  Widget _repliesList(QuerySnapshot<Object?> data) {
    if (data.docs.isNotEmpty) {
      final replies = data.docs.map((doc) {
        final replyData = doc.data() as Map<String, dynamic>;
        final replyText = replyData['reply'] as String;
        final timestamp = replyData['write_date'] as Timestamp?;
        final replyDate = timestamp != null ? timestamp.toDate() : null;
        return {
          'replyText': replyText,
          'replyDate': replyDate,
        };
      }).toList();

      if (!_showAllReplies) {
        replies.removeRange(_visibleReplyCount, replies.length);
      }

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < replies.length; i++) _buildReplyRow(replies[i]),
            if (data.docs.length > _visibleReplyCount)
              Padding(
                padding: const EdgeInsets.only(left: 53),
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

  Widget _buildReplyRow(Map<String, dynamic> replyData) {
    final replyText = replyData['replyText'] as String;
    final replyDate = replyData['replyDate'] as DateTime?;

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
                    Text('hj', style: TextStyle(fontSize: 13)),
                    SizedBox(height: 5),
                    if (replyDate != null)
                      Text(
                        replyDate.toString(),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        elevation: 0,
        title: Center(child: Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.bold),)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
              onTap: (){},
              child: Icon(Icons.share, color: Color(0xff464D40),size: 20,)
          ),
          SizedBox(width: 15),
          GestureDetector(
            onTap: _showMenu,
            child: Icon(Icons.more_vert, color: Color(0xff464D40),size: 20),
          ),
          SizedBox(width: 15,)
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
                children: [
                  if (_postData != null)
                    buildDetailContent(
                      _postData?['title'] ?? '',
                      _postData?['content'] ?? '',
                      _postData?['viewCount'] ?? 0,
                    ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
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
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: _commentsList(snapshot.data as QuerySnapshot<Object?>),
                        );
                      } else {
                        return Container(); // 또는 다른 로딩 표시 방식을 사용할 수 있습니다.
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
          fontSize: 10,
          color: Colors.grey,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}