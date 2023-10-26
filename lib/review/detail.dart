import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/main.dart';
import 'package:flutter/material.dart';
import 'edit_add.dart';


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
      enableDrag : true,
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
                onTap: () {
                  // 수정하기 버튼을 눌렀을 때 실행할 코드
                  Navigator.pop(context); // 시트 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReViewEdit(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제하기'),
                onTap: () {
                  // 삭제하기 버튼을 눌렀을 때 실행할 코드
                  showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          title: Text('삭제'),
                          content: Text('후기를 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  setState(() {
                                    Navigator.pop(context);  // 시트닫기
                                    Navigator.pop(context); // 상세보기로 돌아가기
                                  });
                                },
                                child: Text('취소')
                            ),
                            TextButton(
                                onPressed: (){
                                  setState(() {
                                    _deleteReview(document); // 리뷰삭제
                                    Navigator.pop(context); // 시트 닫기
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ReviewList())); // 후기 메인으로 돌아가기
                                  });
                                },
                                child: Text('삭제')
                            )
                          ],
                        );
                      }
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }


  // 리뷰 삭제
  void _deleteReview(DocumentSnapshot document) async {
    await FirebaseFirestore.instance.collection("review_tbl").doc(document.id).delete();

  }

  // 리뷰 상세보기
  _reviewDetail(){
    DocumentSnapshot document = widget.document;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _reviewDetail(),
        Text(document['title'], style: TextStyle(fontSize: 30)),
        SizedBox(height: 20,),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('ex/ex1.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(document['nickName'], style: TextStyle(fontSize: 13),),
                Text('30분 전, 비공개', style: TextStyle(fontSize: 13))
              ],
            )
          ],
        ),
        SizedBox(height: 20,),
        Image.asset('ex/ex4.jpg', width: MediaQuery.of(context).size.width, height: 400,),
        SizedBox(height: 20,),
        Text(document['content']),
        SizedBox(height: 30,),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('후기 상세보기'),
        actions: [
          IconButton(
            onPressed: _showMenu,
            icon: Icon(Icons.menu)
          )
        ],
        backgroundColor: Color(0xFF464D40),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _reviewDetail()
      ),
    );
  }
}
