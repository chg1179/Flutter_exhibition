import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewDetail extends StatefulWidget {
  final DocumentSnapshot document;
  ReviewDetail({required this.document});

  @override
  State<ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {

  // 이미지 리스트
  final _imgList = [
    'ex/ex1.png',
    'ex/ex2.png',
    'ex/ex3.png',
    'ex/ex4.jpg',
    'ex/ex5.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot document = widget.document;

    return Scaffold(
      appBar: AppBar(title: Text('후기 상세보기'),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _reviewDetail(),
            Text(document['title'], style: TextStyle(fontSize: 30)),
            SizedBox(height: 20,),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('test/test.jpg'),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('hj', style: TextStyle(fontSize: 13),),
                    Text('30분 전, 비공개', style: TextStyle(fontSize: 13))
                  ],
                )
              ],
            ),
            SizedBox(height: 20,),
            Image.asset('test/test.jpg'),
            SizedBox(height: 20,),
            Text(document['content']),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }

  // Widget _reviewDetail(){
  //   DocumentSnapshot document = widget.document;
  //     return ListTile(
  //       leading: Image.asset('test/test.jpg'),
  //       title: Text(document['title']), // title 필드에서 데이터 가져오기
  //       subtitle: Text(document['content']), // content 필드에서 데이터 가져오기
  //     );
  //   }
}
