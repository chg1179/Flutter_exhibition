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

  @override
  void initState() {
    super.initState();

    // 스크롤 위치 감지를 위한 리스너 등록
    _scrollController.addListener(() {
      if (_scrollController.offset > 3) {
        // 스크롤 위치가 0보다 크면 플로팅 버튼 표시
        setState(() {
          _showFloatingButton = true;
        });
      } else {
        // 스크롤 위치가 0 이하이면 플로팅 버튼 숨김
        setState(() {
          _showFloatingButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // 스크롤 컨트롤러 정리
    _scrollController.dispose();
    super.dispose();
  }

  // 댓글 등록 로직
  void _addComment() async {
    String commentText = _commentCtr.text;

    if (commentText.isNotEmpty) {
      try {
        await _firestore.collection('post').doc(widget.document).collection('comment').add({
          'comment': commentText,
          'write_date': FieldValue.serverTimestamp()
        });

        _commentCtr.clear();
        FocusScope.of(context).unfocus();

        _showSnackBar('댓글이 등록되었습니다!');
      } catch (e) {
        print('댓글 등록 오류: $e');
      }
    }
  }

  // 스낵바 함수
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
      ),
    );
  }

  // 커뮤니티 홈 버튼
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

  // 게시글 리스트 출력
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


  // 작성자, 날짜
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

  // 글 제목
  Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // 글 내용
  Widget buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content, style: TextStyle(fontSize: 15),),
    );
  }

  // 글 이미지
  Widget buildImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset('assets/ex/ex3.png', width: 400, height: 400, fit: BoxFit.cover),
    );
  }

  // 조회수, 댓글, 하트 수
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

  // 좋아요, 댓글, 하트 수
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

  // 수정 삭제 메뉴
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

  // 게시글 삭제 다이얼로그
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

  // 삭제 후 다이얼로그
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

  // 게시글 삭제 로직
  void _deletePost(String documentId) async {
    await FirebaseFirestore.instance.collection("post").doc(documentId).delete();
  }

  // 댓글 리스트 출력
  Widget _commentsList(QuerySnapshot? comments) {
    if (comments != null && comments.docs.isNotEmpty) {
      return Column(
        children: comments.docs.map((doc) {
          final commentData = doc.data() as Map<String, dynamic>;
          final commentText = commentData['comment'] as String;
          final timestamp = commentData['write_date'] as Timestamp?;
          final commentDate = timestamp != null ? timestamp.toDate() : null;

          return ListTile(
            title: Text(commentText, style: TextStyle(fontSize: 15),),
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('post').doc(widget.document).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: ${snapshot.error}'));
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
                  return Center(child: Text('게시글을 찾을 수 없습니다.'));
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: _firestore.collection('post')
                  .doc(widget.document)
                  .collection('comment').orderBy('write_date', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  return _commentsList(snapshot.data as QuerySnapshot);
                } else {
                  return Center(child: Text('댓글이 없습니다.'));
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 80),
              child: Text('오늘의 인기 게시글'),
            ),
          )
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? Container(
            padding: EdgeInsets.only(bottom: 30),
            child: FloatingActionButton(
              onPressed: () {
                // 페이지의 최상단으로 스크롤
                _scrollController.animateTo(
                  0.0,
                  duration: Duration(milliseconds: 2), // 스크롤 애니메이션 지속 시간
                  curve: Curves.easeInOut, // 애니메이션 효과
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
