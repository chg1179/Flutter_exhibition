import 'package:exhibition_project/myPage/JTBI/jbti1.dart';
import 'package:flutter/material.dart';

class CommDetail extends StatefulWidget {
  const CommDetail({super.key});

  @override
  State<CommDetail> createState() => _CommDetailState();
}

class _CommDetailState extends State<CommDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('커뮤니티 게시글 상세보기')),
      body: Column(
        children: [
          Text('글 제목'),
          Text('글 내용')
        ]
      ),
    );
  }
}
