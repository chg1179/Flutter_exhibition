import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/review_edit.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class ReviewDetail extends StatefulWidget {
  final String? document;
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
                      builder: (context) => ReviewEdit(documentId: document),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제하기'),
                onTap: () {
                  _confirmDelete(document as DocumentSnapshot<Object?>);
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
    await FirebaseFirestore.instance.collection("review").doc(document.id).delete();
  }

  // 리뷰 상세 정보 위젯
  Widget _reviewDetailWidget() {
    final document = widget.document;
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("review").doc(document).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // 데이터를 가져오는 동안 로딩 표시
          }

          if (snapshot.hasError) {
            return Text('에러 발생: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Text('데이터 없음');
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final title = data['title'] as String;
          final content = data['content'] as String;
          final imageURL = data['imageURL'] as String?;

          return SingleChildScrollView(
              child : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 25.0)),
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
                  if (imageURL != null && imageURL.isNotEmpty)
                    Image.network(imageURL),
                  SizedBox(height: 20),
                  Text(content),
                  SizedBox(height: 30),
                ],
              )
          );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true, // 이 속성을 추가하여 타이틀을 가운데 정렬
        title: Text('후기 상세보기', style: TextStyle(color: Colors.black, fontSize: 20)),
        leading: null, // 뒤로가기 버튼을 제거합니다.
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _reviewDetailWidget(),
      ),
    );
  }
}