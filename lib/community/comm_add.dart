import 'package:cloud_firestore/cloud_firestore.dart';
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


  // 글 등록
  void _addPost() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference post = FirebaseFirestore.instance.collection("post");

      await post.add({
        'title': _titleCtr.text,
        'content': _contentCtr.text,
        'write_date' : DateTime.now()
      });

      _titleCtr.clear();
      _contentCtr.clear();
    } else {
      print("제목과 내용을 입력해주세요");
    }
  }

  // 글 등록 폼
  Widget buildCommForm() {
    return SingleChildScrollView( // 싱글 차일드 스크롤뷰 추가
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Color(0xffD4D8C8),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleInput(),
            _buildDivider(),
            SizedBox(height: 10),
            _buildLocationButton(),
            _buildContentInput(),
            _buildAddImageButton(),
          ],
        ),
      ),
    );
  }

  // 제목
  Widget _buildTitleInput() {
    return Container(
      child: TextField(
        controller: _titleCtr,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, right: 10, left: 20, bottom: 10),
          hintText: '제목을 입력해주세요.',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 중간 라인
  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      height: 2.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.black12,
    );
  }

  // 위치 추가
  Widget _buildLocationButton() {
    return Container(
      width: 100,
      child: TextButton(
        onPressed: () {},
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.black26),
            Text(
              '위치 추가',
              style: TextStyle(color: Colors.black26, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // 내용
  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: TextField(
        maxLines: 8,
        maxLength: 300,
        controller: _contentCtr,
        decoration: InputDecoration(
          hintText: '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 이미지
  Widget _buildAddImageButton() {
    return Container(
      alignment: Alignment.bottomLeft,
      child: IconButton(
        onPressed: () {},
        icon: Icon(Icons.image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '글 작성',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: (){
              _addPost();
            },
            child: Text(
              '등록',
              style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView( // SingleChildScrollView를 여기에 추가
        child: Container(
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
      ),
    );
  }
}
