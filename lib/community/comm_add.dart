import 'package:flutter/material.dart';

class CommAdd extends StatefulWidget {
  const CommAdd({super.key});

  @override
  State<CommAdd> createState() => _CommAddState();
}

class _CommAddState extends State<CommAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('글 작성', style: TextStyle(color: Colors.black, fontSize: 15)),
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
