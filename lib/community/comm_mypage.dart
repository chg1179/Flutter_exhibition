import 'package:flutter/material.dart';

class CommMyPage extends StatefulWidget {
  const CommMyPage({super.key});

  @override
  State<CommMyPage> createState() => _CommMyPageState();
}

class _CommMyPageState extends State<CommMyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('내 활동 내역',
            style: TextStyle(color: Colors.black)
            ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
          },
        ),
      )
    );
  }
}
