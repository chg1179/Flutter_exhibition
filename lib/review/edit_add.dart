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
  bool _isPublic = false;


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              onPressed: _selectBar,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('발행 옵션', style: TextStyle(color: Colors.black54),),
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

  // 리뷰 등록
  _addReviewWidget(){
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black26,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Container(
            width: 100,
            child: TextButton(
                onPressed: (){},
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.black26),
                    Text('위치 추가', style: TextStyle(color: Colors.black26, fontSize: 13),)
                  ],
                )
            ),
          ),
          // content
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              maxLines: 8,
              maxLength: 300,
              controller: _contentCtr,
              decoration: InputDecoration(
                  hintText:
                  '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
                  border: InputBorder.none
              ),
            ),
          ),

          // image
          Container(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              onPressed: (){},
              icon: Icon(Icons.image),
            ),
          )
        ],
      ),
    );
  }

  // 셀렉트바
  _selectBar() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      enableDrag : true,
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('발행 옵션', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 10),
                    child: Text('공개 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  Text('모든 사람이 이 글을 볼 수 있습니다.',
                      style: TextStyle(fontSize: 13, color: Colors.black26,fontWeight: FontWeight.bold)
                  ),
                  SizedBox(width: 20),
                  Switch(
                    value: _isPublic,
                    onChanged: (bool? value){
                      setState(() {
                        _isPublic = value!;
                      });
                    }
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

