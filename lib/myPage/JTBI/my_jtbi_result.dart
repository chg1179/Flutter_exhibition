import 'package:exhibition_project/myPage/JTBI/jbti1.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(JtbiResult2());
}

class JtbiResult2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JtbiResult(),
    );
  }
}

class JtbiResult extends StatefulWidget {
  JtbiResult({super.key});

  @override
  State<JtbiResult> createState() => _JtbiResultState();
}

class _JtbiResultState extends State<JtbiResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나의 취향분석',
          style: TextStyle(
            color: Colors.black, // 텍스트 색상 검은색
            fontSize: 18, // 글씨 크기 조정
          ),
        ),
        centerTitle: true, // 가운데 정렬
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
