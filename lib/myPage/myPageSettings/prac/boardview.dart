import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//게시글 상세보기
class BoardView extends StatefulWidget {
  final DocumentSnapshot document;
  const BoardView({required this.document});

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제목 : ${data['title']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('작성일 : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(data['timestamp'].toDate())}'),
            SizedBox(height: 16),
            Text( '내용 : ${data['content']}',
              style: TextStyle(
                fontSize: 18,
              ),),
          ],
        ),
      ),
    );
  }
}