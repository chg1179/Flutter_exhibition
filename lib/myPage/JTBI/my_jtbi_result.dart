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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트 사이의 간격을 조절
        children: [
          Text(
            '선호 키워드',
            style: TextStyle(
              color: Colors.black, // 검은색
              fontSize: 18, // 글씨 크기
              fontWeight: FontWeight.bold, // 굵게
            ),
          ),
          Text(
            '서정적',
            style: TextStyle(
              color: Colors.purple, // 보라색
              fontSize: 18, // 글씨 크기
              fontWeight: FontWeight.bold, // 굵게
            ),
          ),
        ],
      ),

    );
  }
}
class TemperatureBar extends StatelessWidget {
  final double temperature;

  TemperatureBar({required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature°C', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 350, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.green, // 온도바의 색상을 초록색으로 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
        ),
      ],
    );
  }
}
