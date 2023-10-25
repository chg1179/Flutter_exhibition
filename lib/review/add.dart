import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewAdd extends StatefulWidget {
  const ReviewAdd({super.key});
  @override
  State<ReviewAdd> createState() => _ReviewAddState();
}

class _ReviewAddState extends State<ReviewAdd> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();

  void _addReview() async{
    if(_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty){
      CollectionReference review = FirebaseFirestore.instance.collection("review_tbl");

      await review.add({
        'title' : _titleCtr.text,
        'content' : _contentCtr.text
      });

      _titleCtr.clear();
      _contentCtr.clear();

    } else {
      print("제목과 내용을 입력해주세요");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('후기 작성 페이지'),),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text('이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?이미지등록어케해요?'),
            SizedBox(height: 30),
            TextField(
              controller: _titleCtr,
              decoration: InputDecoration(
                labelText: 'Review Title',
              ),
            ),
            TextField(
              controller: _contentCtr,

              decoration: InputDecoration(
                labelText: 'Review Content',
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _addReview,
              child: Text('후기 등록')
            )
          ],
        ),
      ),
    );
  }
}
