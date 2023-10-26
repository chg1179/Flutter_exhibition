import 'package:flutter/material.dart';

class AddViewDetail extends StatefulWidget {
  final String title;
  final String subtitle;

  AddViewDetail({required this.title, required this.subtitle});

  @override
  State<AddViewDetail> createState() => _AddViewDetailState();
}

class _AddViewDetailState extends State<AddViewDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black, // 화살표 아이콘의 색상을 검은색으로 설정
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("어떤 전시회가 좋을지 고민된다면?🤔", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0, // 그림자를 제거합니다.
      ),
        body: Column(
        children: [
          SizedBox(height: 16),
          Center(child: Text(widget.title,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
          SizedBox(height: 16),
          Center(child: Text(widget.subtitle,style: TextStyle(fontSize: 12,color: Colors.grey))),
        ],
      ),
    );
  }
}
