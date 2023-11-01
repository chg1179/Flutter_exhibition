
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/comm_add.dart';
import 'package:exhibition_project/community/comm_main.dart';
import 'package:flutter/material.dart';

class CommDetail extends StatefulWidget {
  final String document;
  CommDetail({required this.document});

  @override
  State<CommDetail> createState() => _CommDetailState();
}

class _CommDetailState extends State<CommDetail> {
  final _commentCtr = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  Map<String, dynamic>? _postData;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _getPostData();
    _loadComments();

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

  void _getPostData() async {
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

  void _loadComments() async {
    try {
      final querySnapshot = await _firestore
          .collection('post')
          .doc(widget.document)
          .collection('comment')
          .orderBy('write_date', descending: false)
          .get();
      final comments = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'comment': data['comment'] as String,
          'write_date': data['write_date'] as Timestamp,
        };
      }).toList();

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
          buildIcons(),
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
    String? imagePath = _postData?['imagePath'] as String?;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: imagePath != null && imagePath.isNotEmpty
          ? Image.file(
        File(imagePath),
        width: 400,
        height: 400,
        fit: BoxFit.cover,
      )
          : SizedBox(width: 0, height: 0), // 이미지가 없을 때 빈 SizedBox 반환
    );
  }

  Widget buildIcons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility, '0'),
              SizedBox(width: 5),
              buildIconsItem(Icons.chat_bubble_rounded, '0'),
              SizedBox(width: 5),
            ],
          ),
          GestureDetector(
            onTap: () {
              // 좋아요 카운트 증가 코드 작성
            },
            child: buildIconsItem(Icons.favorite, '0'),
          ),
        ],
      ),
    );
  }

  Widget buildIconsItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Color(0xff464D40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white),
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
                      builder: (context) => CommAdd(),
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
      // 해당 게시글의 댓글 컬렉션 참조를 가져옵니다.
      final commentCollection = FirebaseFirestore.instance.collection("post").doc(documentId).collection("comment");

      // 게시글의 댓글 컬렉션에 속한 모든 댓글 문서를 삭제합니다.
      final commentQuerySnapshot = await commentCollection.get();
      for (var commentDoc in commentQuerySnapshot.docs) {
        await commentDoc.reference.delete();
      }

      // 게시글 문서를 삭제합니다.
      await FirebaseFirestore.instance.collection("post").doc(documentId).delete();


    } catch (e) {
      print('게시글 삭제 중 오류 발생: $e');
    }
  }

  Widget _commentsList(QuerySnapshot<Object?> data) {
    if (_comments.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: _comments.map((commentData) {
            final commentText = commentData['comment'] as String;
            final timestamp = commentData['write_date'] as Timestamp;
            final commentDate = timestamp.toDate();

            return ListTile(
              title: Text(commentText, style: TextStyle(fontSize: 15)),
              subtitle: Text(commentDate.toString()),
            );
          }).toList(),
        ),
      );
    } else {
      return Center(child: Text('댓글이 없습니다.'));
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
                ? Center(child: CircularProgressIndicator())
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
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                    }
                    return _commentsList(snapshot.data as QuerySnapshot);
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
