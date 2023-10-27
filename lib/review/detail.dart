import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/edit_add.dart';
import 'package:exhibition_project/review/main.dart';
import 'package:flutter/material.dart';

class ReviewDetail extends StatefulWidget {
  final DocumentSnapshot document;
  ReviewDetail({required this.document});

  @override
  State<ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {

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
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(''),
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewEdit(),
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
    await FirebaseFirestore.instance.collection("review_tbl").doc(document.id).delete();
  }

  // 리뷰 상세 정보 위젯
  Widget _reviewDetailWidget() {
    final document = widget.document;
    return SingleChildScrollView(
      child : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(document['title'], style: TextStyle(fontSize: 25)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/ex/ex1.png'),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('hj', style: TextStyle(fontSize: 15)),
                        //Text(document['nickName'], style: TextStyle(fontSize: 13)),
                        Text('2023. 10. 19. 22:09 · 비공개', style: TextStyle(fontSize: 12, color: Colors.black45)),
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
          SizedBox(height: 20),
          Container(
              height:1.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.black12
          ),
          SizedBox(height: 20),
          Image.asset('assets/ex/ex4.jpg', width: MediaQuery.of(context).size.width, height: 400),
          SizedBox(height: 20),
          Text(document['content']),
          SizedBox(height: 30),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
            child: Text('후기 상세보기', style: TextStyle(color: Colors.black, fontSize: 20))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _reviewDetailWidget(),
      ),
    );
  }
}
