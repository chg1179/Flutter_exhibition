import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 리뷰 등록
class ReViewEdit extends StatefulWidget {
  const ReViewEdit({super.key});

  @override
  State<ReViewEdit> createState() => _ReViewEditState();
}

class _ReViewEditState extends State<ReViewEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();

  // 후기 등록
  void _addReview() async{
    if(_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty){
      CollectionReference review = FirebaseFirestore.instance.collection("review_tbl");

      await review.add({
        'title' : _titleCtr.text,
        'content' : _contentCtr.text,
      });

      _titleCtr.clear();
      _contentCtr.clear();

    } else {
      print("제목과 내용을 입력해주세요");
    }
  }

  // 리뷰 수정
  void _editReview(DocumentSnapshot document) async {
    if(_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty){
      CollectionReference review = FirebaseFirestore.instance.collection("review_tbl");

      _titleCtr.clear();
      _contentCtr.clear();

    } else {
      print("제목과 내용을 입력해주세요");
    }
    // 수정할 리뷰의 데이터 가져오기

  }

  // 리뷰 등록
  _addReviewWidget(){
    return Container(
      height: 500,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [

          // title
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _titleCtr,
              decoration: InputDecoration(
                hintText: '제목을 입력해주세요',
              ),
            ),
          ),

          // content
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              maxLines: 15,
              maxLength: 300,
              controller: _contentCtr,
              decoration: InputDecoration(
                hintText:
                '본문에 #를 입력하면 작품 검색이 가능해요',
                border: InputBorder.none
              ),
            ),
          ),

          // image
          Container(
            alignment: Alignment.bottomLeft,
            child: IconButton(
                onPressed: (){},
                icon: Icon(Icons.image)
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('후기 작성 페이지'),
        actions: [
          TextButton(
              onPressed: _addReview,
              child: Text('저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))
        ],
        backgroundColor: Color(0xFF464D40),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children:[
            ElevatedButton(
              onPressed: (){

              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('옵션', style: TextStyle(color: Colors.black54),),
                  Icon(Icons.expand_more, color: Colors.black54,)
                ],
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero
              ),
            ), 
            _addReviewWidget()
          ]
        ) 
        
      ),
    );
  }
}

