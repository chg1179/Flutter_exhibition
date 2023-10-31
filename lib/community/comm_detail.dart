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

  void _addComment() async {
    String commentText = _commentCtr.text;

    if (commentText.isNotEmpty) {
      try {
        await _firestore.collection('post').doc(widget.document).collection('comment').add({
          'comment': commentText,
          'write_date': FieldValue.serverTimestamp()
        });

        // 댓글 입력창 초기화
        _commentCtr.clear();

        // 키보드 숨기기
        FocusScope.of(context).unfocus();

        // 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글이 등록되었습니다!', style: TextStyle(color: Colors.black),),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.white,
          ),
        );
      } catch (e) {
        print('댓글 등록 오류: $e');
      }
    }
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

  // 작성자, 글 게시시간
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
          Text('방금 전',
            style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 제목
  Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // 내용
  Widget buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content),
    );
  }

  // 이미지
  Widget buildImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset('assets/ex/ex3.png', width: 400, height: 400, fit: BoxFit.cover),
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
              buildIconsItem(Icons.visibility, '47'),
              SizedBox(width: 5),
              buildIconsItem(Icons.chat_bubble_rounded, '1'),
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

  // 조회수, 댓글수 아이콘
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
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // 댓글 작성 폼
  Widget buildCommentForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentCtr,
            decoration: InputDecoration(
              hintText: '댓글을 작성해주세요',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none, // 테두리를 없애기 위해 InputBorder.none을 사용
            ),
          ),
        ),
        TextButton(
          onPressed: _addComment
          ,
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

  // 게시글 삭제 확인 대화상자 표시
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
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 게시글 삭제
  void _deletePost(String documentId) async {
    await FirebaseFirestore.instance.collection("post").doc(documentId).delete();
  }

  Widget _commentsList(QuerySnapshot? comments) {
    if (comments != null && comments.docs.isNotEmpty) {
      return Column(
        children: comments.docs.map((doc) {
          final commentData = doc.data() as Map<String, dynamic>;
          final commentText = commentData['comment'] as String;
          final timestamp = commentData['write_date'] as Timestamp?;
          final commentDate = timestamp != null ? timestamp.toDate() : null;

          return ListTile(
            title: Text(commentText),
            subtitle: Text(commentDate != null ? commentDate.toString() : '날짜 없음'),
          );
        }).toList(),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('post').doc(widget.document).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('에러 발생: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final documentData = snapshot.data?.data() as Map<String, dynamic>;

                  final title = documentData['title'] as String;
                  final content = documentData['content'] as String;

                  return Column(
                    children: [
                      buildDetailContent(title, content),
                    ],
                  );
                } else {
                  return Center(child: Text('데이터 없음'));
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: StreamBuilder(
                stream: _firestore.collection('post')
                    .doc(widget.document)
                    .collection('comment').orderBy('write_date', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('댓글을 불러오는 중 오류 발생: ${snapshot.error}');
                  }

                  if (snapshot.hasData) {
                    return _commentsList(snapshot.data as QuerySnapshot);
                  } else {
                    return Center(child: Text('댓글이 없습니다.'));
                  }
                },
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: buildCommentForm(),
      ),
    );
  }
}
