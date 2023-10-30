import 'package:flutter/material.dart';

class CommAdd extends StatefulWidget {
  const CommAdd({super.key});

  @override
  State<CommAdd> createState() => _CommAddState();
}

class _CommAddState extends State<CommAdd> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  bool _isPublic = false;

  // 글 등록 폼
  Widget buildCommForm() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
          color: Color(0xffD4D8C8),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: TextField(
              controller: _titleCtr,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 20, right: 10, left: 20, bottom: 10),
                hintText: '제목을 입력해주세요.',
                hintStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(right: 20, left: 20),
              height:2.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.black12
          ),
          SizedBox(height: 10),
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
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: TextField(
              maxLines: 8,
              maxLength: 1000,
              controller: _contentCtr,
              decoration: InputDecoration(
                hintText: '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
                hintStyle: TextStyle(
                  color: Colors.black38, // 원하는 색상으로 변경
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: <Widget>[
            Center(
              child: Text(
                '글 작성',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            Spacer(), // 텍스트를 아이콘과 수직 정렬
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildCommForm(),
            ),
          ],
        ),
      ),
    );
  }
}
