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
            Text('커뮤니티', style: TextStyle(color: Color(0xff464D40), fontSize: 13),
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
          buildInteractions(),
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
              Text('전시광', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          Text('방금 전', style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold),
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
  
  // 조회수, 댓글수 아이콘
  Widget buildInteractions() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 10, right: 10, bottom: 10),
      child: Row(
        children: [
          buildInteractionItem(Icons.visibility, '1'),
          SizedBox(width: 5),
          buildInteractionItem(Icons.chat_bubble_rounded, '0'),
          SizedBox(width: 5),
          buildInteractionItem(Icons.favorite, '0'),
        ],
      ),
    );
  }
  
  // 조회수, 댓글수 아이콘
  Widget buildInteractionItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0xffD4D8C8),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15),
          Text(text),
        ],
      ),
    );
  }


  // 댓글 작성 폼
  Widget buildCommentForm() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff464D40)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
            onPressed: () {},
            child: Text('등록', style: TextStyle(color: Color(0xff464D40), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
                    builder: (context){
                      return AlertDialog(
                        content: Text('삭제되었습니다.'),
                        actions: [
                          TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommMain(),
                                  ),
                                );
                              },
                              child: Text('확인')
                          )
                        ],
                      );
                    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: buildTitleButton(context),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.share, color: Color(0xff464D40)),
          ),
          IconButton(
              onPressed: _showMenu,
              icon: Icon(Icons.more_vert),
              color: Color(0xff464D40)
          ),
        ],
      ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('post').doc(widget.document).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('에러 발생: ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              final documentData = snapshot.data!.data() as Map<String, dynamic>;

              final title = documentData['title'] as String;
              final content = documentData['content'] as String;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 기존 상세 정보
                    buildDetailContent(title, content),
                    // 댓글 작성 폼
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: buildCommentForm(),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text('데이터 없음'));
            }
          },
        )
    );
  }
}
