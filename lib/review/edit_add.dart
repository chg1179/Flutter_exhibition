import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewEdit extends StatefulWidget {
  const ReviewEdit({super.key});

  @override
  State<ReviewEdit> createState() => _ReviewEditState();
}

class _ReviewEditState extends State<ReviewEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  bool _isPublic = false;

  // 옵션 셀렉바
  Widget buildSelectBar() {
    return TextButton(
      onPressed: _showPublishOptions,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('옵션', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
          Icon(Icons.expand_more, color: Colors.black),
        ],
      ),
    );
  }

  // 리뷰 폼
  Widget buildReviewForm() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _titleCtr,
              decoration: InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(
                  color: Colors.black26, // 원하는 색상으로 변경
                  fontSize: 25, // 원하는 크기로 변경
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
              height:1.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.black12
          ),
          SizedBox(height: 20),
          Container(
            width: 100,
            child: TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.black26),
                  Text('위치 추가', style: TextStyle(color: Colors.black26, fontSize: 13),),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              maxLines: 8,
              maxLength: 1000,
              controller: _contentCtr,
              decoration: InputDecoration(
                hintText: '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
                hintStyle: TextStyle(
                  color: Colors.black26, // 원하는 색상으로 변경
                  fontSize: 15, // 원하는 크기로 변경
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.image),
            ),
          ),
        ],
      ),
    );
  }

  // 옵션 하단 시트
  void _showPublishOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enableDrag: true,
      context: context,
      builder: (context) {
        return _buildPublishOptionsSheet();
      },
    );
  }

  // 하단 시트 디자인
  Widget _buildPublishOptionsSheet() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '옵션',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildPublishOptionRow(),
        ],
      ),
    );
  }

  // 공개 설정
  Widget _buildPublishOptionRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Text(
            '공개 설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          child: Text(
            _isPublic
                ? '모든 사람이 이 글을 볼 수 있습니다.'
                : '이 글은 나만 볼 수 있습니다.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 20),
        Container(
          child: Switch(
            value: _isPublic,
            onChanged: (bool? value) {
              setState(() {
                _isPublic = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // 후기 등록
  void _addReview() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference review = FirebaseFirestore.instance.collection("review_tbl");

      await review.add({
        'title': _titleCtr.text,
        'content': _contentCtr.text,
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: buildSelectBar(),
        ),
        actions: [
          TextButton(
            onPressed: _addReview,
            child: Text(
              '등록',
              style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
            ),
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildReviewForm(),
            ),
          ],
        ),
      ),
    );
  }
}
